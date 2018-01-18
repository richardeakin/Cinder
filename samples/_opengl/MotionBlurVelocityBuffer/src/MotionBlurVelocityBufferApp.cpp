//
//	Copyright (c) 2014 David Wicks, sansumbrella.com
//	All rights reserved.
//
//	Velocity buffer blur sample application.
//	Motion blur based on the following NVIDIA papers:
//	http://graphics.cs.williams.edu/papers/MotionBlurI3D12/
//	http://graphics.cs.williams.edu/papers/MotionBlur13/
//
//	Author: David Wicks
//	License: BSD Simplified
//

#include "cinder/app/App.h"
#include "cinder/app/RendererGl.h"

#include "cinder/gl/gl.h"

#include "cinder/GeomIo.h"
#include "cinder/Rand.h"

#include "cinder/Log.h"
#include "cinder/params/Params.h"
#include "cinder/CameraUi.h"

#include "BlurrableThings.h"

using namespace ci;
using namespace ci::app;
using namespace std;

class MotionBlurVelocityBufferApp : public App {
  public:
	void setup() override;
	void keyDown( KeyEvent event ) override;
	void update() override;
	void draw() override;

	void createGeometry();
	void createBuffers();
	void loadShaders();

	// Render color and velocity into GBuffer FBO.
	void fillGBuffer();
	// Dilate velocity into VelocityDilationBuffer for use by blur shader.
	void dilateVelocity();
	// Draw final blurred content to screen.
	void drawBlurredContent();
	// Draw velocity buffers to screen for debugging/look under the hood.
	void drawVelocityBuffers();

  private:
	gl::TextureRef					mBackground;
	std::vector<BlurrableMeshRef>	mMeshes;

	gl::GlslProgRef	mVelocityProg;		// Renders RGBA color and screen-space velocity.
	gl::GlslProgRef	mTileProg;			// Downsamples velocity, preserving local maxima
	gl::GlslProgRef	mNeighborProg;		// Finds dominant velocities in downsampled map
	gl::GlslProgRef	mMotionBlurProg;	// Generates final image from color and velocity buffers

	gl::GlslProgRef	mVelocityRenderProg;		// Debug rendering of velocity to screen.

	gl::FboRef		mGBuffer;					// Full-resolution RGBA color and velocity.
	gl::FboRef		mVelocityDilationBuffer;	// Dilated, downsampled velocity and dominant region velocities.
	// Name our framebuffer attachment points.
	const GLenum G_COLOR				= GL_COLOR_ATTACHMENT0;
	const GLenum G_VELOCITY				= GL_COLOR_ATTACHMENT1;
	const GLenum DILATE_TILE_MAX		= GL_COLOR_ATTACHMENT0;
	const GLenum DILATE_NEIGHBOR_MAX	= GL_COLOR_ATTACHMENT1;

	gl::QueryTimeSwappedRef mGpuTimer;
	Timer					mCpuTimer;
	float					mAverageGpuTime = 0.0f;
	float					mAverageCpuTime = 0.0f;

#if ! defined( CINDER_GL_ES )
	params::InterfaceGlRef	mParams;
#endif

	int						mTileSize = 20;		// TileMax program samples a TileSize x TileSize region of pixels for each of its output pixels.
	int						mSampleCount = 31;	// Number of samples used when calculating motion blur. Low-movement areas skip calculation.
	float					mAnimationSpeed = 0.0f;
	float					mBlurNoise = 0.0f;
	bool					mBlurEnabled = true;
	bool					mPaused = false;
	bool					mDisplayVelocityBuffers = true;
	bool					mEnableCameraMotionBlur = true;

	ci::mat4	mPrevViewProjectionMatrix;
	CameraPersp	mCam;
	CameraUi	mCamUi;
};

void MotionBlurVelocityBufferApp::setup()
{
	mBackground = gl::Texture::create( loadImage( loadAsset( "background.jpg" ) ) );
	mGpuTimer = gl::QueryTimeSwapped::create();
	gl::enableVerticalSync();

	createGeometry();
	createBuffers();
	loadShaders();

	vec3 eye = { 0, 0, 100 };
	vec3 target = { 0, 0, 0 };
	mCam.setPerspective( 45.0f, app::getWindowAspectRatio(), 0.1f, 1000.0f );
	mCam.lookAt( eye, target, vec3( 0, 1, 0 ) );

	mCamUi = CameraUi( &mCam, getWindow(), -1 );

#if ! defined( CINDER_ANDROID )
	mParams = params::InterfaceGl::create( "Motion Blur Options", ivec2( 250, 300 ) );
	mParams->addParam( "Average GPU Draw (ms)", &mAverageGpuTime );
	mParams->addParam( "Average CPU Draw (ms)", &mAverageCpuTime );
	mParams->addSeparator();
	mParams->addParam( "Enable Blur", &mBlurEnabled );
	mParams->addParam( "Camera Blur", &mEnableCameraMotionBlur );
	mParams->addParam( "Show Velocity Buffers", &mDisplayVelocityBuffers );
	mParams->addParam( "Pause Animation", &mPaused );
	mParams->addParam( "Animation Speed", &mAnimationSpeed ).min( 0.0f ).step( 0.2f );
	mParams->addParam( "Max Samples", &mSampleCount ).min( 1 ).step( 2 );
	mParams->addParam( "Blur Noise", &mBlurNoise ).min( 0.0f ).step( 0.01f );
#endif

#if defined( CINDER_COCOA_TOUCH )
	getSignalSupportedOrientations().connect( [] { return InterfaceOrientation::LandscapeAll; } );
#endif
}

void MotionBlurVelocityBufferApp::createGeometry()
{
	for( int i = 0; i < 20; ++i )
	{	// create some randomized geometry
		vec3 bb = { 10, 10, 10 };
		vec3 pos = vec3( randFloat( - bb.x, bb.x ), randFloat( - bb.y, bb.y ), randFloat( -bb.z, bb.z ) );
		float base = randFloat( 2, 5 );
		float height = randFloat( 4, 8 );

		auto mesh = make_shared<BlurrableMesh>( gl::VboMesh::create( geom::Cone().height( height ).base( base ) ), pos );
		mesh->setAxis( randVec3() );
		mesh->setColor( ColorA( CM_HSV, randFloat( 0.05f, 0.33f ), 1.0f, 1.0f ) );
		mesh->setOscillation( vec3( randFloat( -250.0f, 250.0f ), randFloat( -300.0f, 300.0f ), randFloat( -500.0f, 200.0f ) ) * 0.2f );
		mesh->setTheta( randFloat( M_PI * 2 ) );

		mMeshes.push_back( mesh );
	}
}

void MotionBlurVelocityBufferApp::createBuffers()
{
	const int bufferWidth = getWindowWidth();
	const int bufferHeight = getWindowHeight();
	const int tileWidth = bufferWidth / mTileSize;
	const int tileHeight = bufferHeight / mTileSize;

	auto colorFormat = gl::Texture::Format().internalFormat( GL_RGBA );
	auto velocityFormat = gl::Texture::Format().internalFormat( GL_RG16F );
	auto colorBuffer = gl::Texture::create( bufferWidth, bufferHeight, colorFormat );
	auto velocityBuffer = gl::Texture::create( bufferWidth, bufferHeight, velocityFormat );

	auto tileMaxBuffer = gl::Texture::create( tileWidth, tileHeight, velocityFormat );
	auto neighborMaxBuffer = gl::Texture::create( tileWidth, tileHeight, velocityFormat );


	auto format = gl::Fbo::Format().depthBuffer();
	format.enableDepthBuffer();
	format.attachment( G_COLOR, colorBuffer );
	format.attachment( G_VELOCITY, velocityBuffer );

	mGBuffer = gl::Fbo::create( bufferWidth, bufferHeight, format );

	format = gl::Fbo::Format().disableDepth();
	format.attachment( DILATE_TILE_MAX, tileMaxBuffer );
	format.attachment( DILATE_NEIGHBOR_MAX, neighborMaxBuffer );

	mVelocityDilationBuffer = gl::Fbo::create( tileWidth, tileHeight, format );
}

void MotionBlurVelocityBufferApp::loadShaders()
{
	try
	{
		mVelocityProg = gl::GlslProg::create( gl::GlslProg::Format().vertex( loadAsset( "velocity.vs" ) )
						.fragment( loadAsset( "velocity.fs" ) ) );
		mMotionBlurProg = gl::GlslProg::create( gl::GlslProg::Format().vertex( loadAsset( "passthrough.vs" ) )
								.fragment( loadAsset( "motion-blur.fs" ) ) );
		mVelocityRenderProg	= gl::GlslProg::create( gl::GlslProg::Format().vertex( loadAsset( "passthrough.vs" ) )
								.fragment( loadAsset( "velocity-render.fs" ) ) );
		mTileProg = gl::GlslProg::create( gl::GlslProg::Format().vertex( loadAsset( "passthrough.vs" ) )
					.fragment( loadAsset( "tilemax.fs" ) ) );
		mNeighborProg = gl::GlslProg::create( gl::GlslProg::Format().vertex( loadAsset( "passthrough.vs" ) )
						.fragment( loadAsset( "neighbormax.fs" ) ) );
	}
	catch( ci::gl::GlslProgCompileExc &exc )
	{
		CI_LOG_E( "Shader load error: " << exc.what() );
	}
	catch( ci::Exception &exc )
	{
		CI_LOG_E( "Shader load error: " << exc.what() );
	}
}

void MotionBlurVelocityBufferApp::keyDown( KeyEvent event )
{
	switch ( event.getCode() )
	{
		case KeyEvent::KEY_SPACE:
			mPaused = ! mPaused;
		break;
		case KeyEvent::KEY_b:
			mBlurEnabled = ! mBlurEnabled;
		break;
		case KeyEvent::KEY_r:
			loadShaders();
		break;
		default:
		break;
	}
}

void MotionBlurVelocityBufferApp::update()
{
	if( ! mPaused )
	{
		for( auto &mesh : mMeshes ) {
			mesh->update( mAnimationSpeed / 60.0f );
		}
	}
}

void MotionBlurVelocityBufferApp::fillGBuffer()
{
	gl::enableDepthRead();
	gl::enableDepthWrite();

	gl::ScopedFramebuffer fbo( mGBuffer );
	gl::ScopedBlendAlpha blend;
	gl::clear( ColorA( 0.0f, 0.0f, 0.0f, 0.0f ) );

	gl::ScopedViewport viewport( mGBuffer->getSize() );
	gl::ScopedMatrices matrices;
	gl::setMatrices( mCam );


	gl::ScopedGlslProg prog( mVelocityProg );
	mVelocityProg->uniform( "uViewProjection", gl::getProjectionMatrix() * gl::getViewMatrix() );
	if( mEnableCameraMotionBlur ) {
		mVelocityProg->uniform( "uPrevViewProjection", mPrevViewProjectionMatrix );
		mPrevViewProjectionMatrix = gl::getProjectionMatrix() * gl::getViewMatrix();
	}
	else {
		// use current view projection
		mVelocityProg->uniform( "uPrevViewProjection", gl::getProjectionMatrix() * gl::getViewMatrix() );
	}

	for( auto &mesh : mMeshes )
	{
		gl::ScopedColor meshColor( mesh->getColor() );
		mVelocityProg->uniform( "uModelMatrix", mesh->getTransform() );
		mVelocityProg->uniform( "uPrevModelMatrix", mesh->getPreviousTransform() );
		gl::draw( mesh->getMesh() );
	}

	gl::disableDepthRead();
	gl::disableDepthWrite();
}

void MotionBlurVelocityBufferApp::dilateVelocity()
{
	gl::ScopedFramebuffer fbo( mVelocityDilationBuffer );
	gl::ScopedViewport viewport( ivec2( 0, 0 ), mVelocityDilationBuffer->getSize() );
	gl::ScopedMatrices	matrices;
	//gl::setMatricesWindowPersp( mVelocityDilationBuffer->getSize() );
	gl::setMatrices( mCam );


	{ // downsample velocity into tilemax
		gl::ScopedTextureBind tex( mGBuffer->getTexture2d( G_VELOCITY ), 0 );
		gl::ScopedGlslProg prog( mTileProg );
		gl::drawBuffer( DILATE_TILE_MAX );

		mTileProg->uniform( "uVelocityMap", 0 );
		mTileProg->uniform( "uTileSize", mTileSize );

		gl::drawSolidRect( mVelocityDilationBuffer->getBounds() );
	}
	{ // build max neighbors from tilemax
		gl::ScopedTextureBind tex( mVelocityDilationBuffer->getTexture2d( DILATE_TILE_MAX ), 0 );
		gl::ScopedGlslProg prog( mNeighborProg );
		gl::drawBuffer( DILATE_NEIGHBOR_MAX );

		mNeighborProg->uniform( "uTileMap", 0 );

		gl::drawSolidRect( mVelocityDilationBuffer->getBounds() );
	}
}

void MotionBlurVelocityBufferApp::drawBlurredContent()
{
	gl::ScopedTextureBind colorTex( mGBuffer->getTexture2d( G_COLOR ), 0 );
	gl::ScopedTextureBind velTex( mGBuffer->getTexture2d( G_VELOCITY ), 1 );
	gl::ScopedTextureBind neigborTex( mVelocityDilationBuffer->getTexture2d( DILATE_NEIGHBOR_MAX ), 2 );
	gl::ScopedGlslProg prog( mMotionBlurProg );
	gl::ScopedBlendPremult blend;

	mMotionBlurProg->uniform( "uColorMap", 0 );
	mMotionBlurProg->uniform( "uVelocityMap", 1 );
	mMotionBlurProg->uniform( "uNeighborMaxMap", 2 );
	mMotionBlurProg->uniform( "uNoiseFactor", mBlurNoise );
	mMotionBlurProg->uniform( "uSamples", mSampleCount );

	gl::drawSolidRect( getWindowBounds() );
}

void MotionBlurVelocityBufferApp::draw()
{
	mGpuTimer->begin();
	mCpuTimer.start();

	gl::clear( Color( 0, 0, 0 ) );
	gl::ScopedMatrices matrices;
	gl::setMatricesWindowPersp( getWindowSize(), 60.0f, 1.0f, 5000.0f );
	gl::ScopedViewport viewport( vec2(0), getWindowSize() );
	gl::ScopedBlend blend(false);

	//gl::draw( mBackground, getWindowBounds() );

	fillGBuffer();

	if( ! mBlurEnabled ) {

		gl::ScopedBlendAlpha blend;
		gl::draw( mGBuffer->getColorTexture() );
	}
	else {
		dilateVelocity();
		drawBlurredContent();
	}

	if( mDisplayVelocityBuffers ) {
		drawVelocityBuffers();
	}

	mCpuTimer.stop();
	mGpuTimer->end();

	mAverageCpuTime = (mCpuTimer.getSeconds() * 200) + mAverageCpuTime * 0.8f;
	mAverageGpuTime = mGpuTimer->getElapsedMilliseconds() * 0.2f + mAverageGpuTime * 0.8f;

#if ! defined( CINDER_GL_ES )
	mParams->draw();
#endif
}

void MotionBlurVelocityBufferApp::drawVelocityBuffers()
{
	gl::ScopedGlslProg prog( mVelocityRenderProg );
	gl::ScopedModelMatrix matrix;
	gl::setDefaultShaderVars();

	float width = 200.0f;
	float height = width / Rectf( mVelocityDilationBuffer->getBounds() ).getAspectRatio();
	Rectf rect( 0.0f, 0.0f, width, height );

	gl::ScopedTextureBind velTex( mGBuffer->getTexture2d( G_VELOCITY ), 0 );
	gl::translate( getWindowWidth() - width - 10.0f, 10.0f );
	gl::drawSolidRect( rect );

	gl::ScopedTextureBind tileTex( mVelocityDilationBuffer->getTexture2d( DILATE_TILE_MAX ), 0 );
	gl::translate( 0.0f, height + 10.0f );
	gl::drawSolidRect( rect );

	gl::ScopedTextureBind neigborTex( mVelocityDilationBuffer->getTexture2d( DILATE_NEIGHBOR_MAX ), 0 );
	gl::translate( 0.0f, height + 10.0f );
	gl::drawSolidRect( rect );
}

CINDER_APP( MotionBlurVelocityBufferApp, RendererGl, []( App::Settings *settings ) {
	settings->setWindowSize( 1280, 720 );
} )
