/*
 Copyright (c) 2014, The Cinder Project

 This code is intended to be used with the Cinder C++ library, http://libcinder.org

 Redistribution and use in source and binary forms, with or without modification, are permitted provided that
 the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and
	the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and
	the following disclaimer in the documentation and/or other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
 WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
*/

#include "cinder/audio/OutputNode.h"
#include "cinder/audio/Context.h"
#include "cinder/audio/Utilities.h"
#include "cinder/audio/Exception.h"

using namespace std;

namespace cinder { namespace audio {

// ----------------------------------------------------------------------------------------------------
// MARK: - OutputNode
// ----------------------------------------------------------------------------------------------------

OutputNode::OutputNode( const Format &format )
	: Node( format ), mClipDetectionEnabled( true ), mClipThreshold( 2 ), mLastClip( 0 )
{
	if( boost::indeterminate( format.getAutoEnable() ) )
		setAutoEnabled( false );
}

void OutputNode::connect( const NodeRef &output )
{
	CI_ASSERT_MSG( 0, "OutputNode does not support connecting to other outputs" );
}

uint64_t OutputNode::getLastClip()
{
	uint64_t result = mLastClip;
	mLastClip = 0;
	return result;
}

void OutputNode::enableClipDetection( bool enable, float threshold )
{
	lock_guard<mutex> lock( getContext()->getMutex() );

	mClipDetectionEnabled = enable;
	mClipThreshold = threshold;
}

bool OutputNode::checkNotClipping()
{
	if( mClipDetectionEnabled ) {
		size_t recordedFrame;
		if( thresholdBuffer( *getInternalBuffer(), mClipThreshold, &recordedFrame ) ) {
			mLastClip = getContext()->getNumProcessedFrames() + recordedFrame;
			return true;
		}
	}
	
	return false;
}

// ----------------------------------------------------------------------------------------------------
// MARK: - OutputDeviceNode
// ----------------------------------------------------------------------------------------------------

OutputDeviceNode::OutputDeviceNode( const DeviceRef &device, const Format &format )
	: OutputNode( format ), mDevice( device )
{
	CI_ASSERT( mDevice );

	size_t deviceNumChannels = mDevice->getNumOutputChannels();

	// If number of channels hasn't been specified, default to 2 (or 1 if that is all that is available).
	if( getChannelMode() != ChannelMode::SPECIFIED ) {
		setChannelMode( ChannelMode::SPECIFIED );
		setNumChannels( std::min( deviceNumChannels, (size_t)2 ) );
	}

	// Double check the device has enough channels to support what was requested, which may not be the case if the user asked for more than what is available.
	if( deviceNumChannels < getNumChannels() )
		throw AudioFormatExc( string( "Device cannot accommodate " ) + to_string( deviceNumChannels ) + " output channels." );

	// listen to the notifications sent by device property changes in order to update the audio graph.
	mParamsWillChangeConn = mDevice->getSignalParamsWillChange().connect( bind( &OutputDeviceNode::deviceParamsWillChange, this ) );
	mParamsDidChangeConn = mDevice->getSignalParamsDidChange().connect( bind( &OutputDeviceNode::deviceParamsDidChange, this ) );

	// list to notifications related to system device changes
	if( mDevice->isDefaultOutput() ) {
		CI_LOG_V( "registering default out changed signal for update" );
		mDefaultDeviceChangedConn = Device::getSignalDefaultOutputChanged().connect( bind( &OutputDeviceNode::onDefaultDeviceChanged, this ) );
	}
}

void OutputDeviceNode::deviceParamsWillChange()
{
	mWasEnabledBeforeParamsChange = isEnabled();

	getContext()->disable();
	getContext()->uninitializeAllNodes();
}

void OutputDeviceNode::deviceParamsDidChange()
{
	getContext()->initializeAllNodes();

	getContext()->setEnabled( mWasEnabledBeforeParamsChange );
}

void OutputDeviceNode::onDefaultDeviceChanged()
{
	CI_LOG_V( "bang" );

	// refresh default device
	auto previousDevice = mDevice;
	mDevice = Device::getDefaultOutput();

	auto ctx = getContext();

	bool wasEnabled = isEnabled();
	ctx->disable();

	// re-initialize impl, possibly causes reconfiguration if params have changed
	auto thisRef = shared_from_this();
	ctx->uninitializeNode( thisRef );
	ctx->initializeNode( thisRef );

	getContext()->setEnabled( wasEnabled );
}

} } // namespace cinder::audio
