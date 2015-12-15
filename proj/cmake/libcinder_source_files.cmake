cmake_minimum_required( VERSION 3.0 FATAL_ERROR )

# ----------------------------------------------------------------------------------------------------------------------
# Cinder
# ----------------------------------------------------------------------------------------------------------------------
list( APPEND SRC_SET_CINDER_APP
	${CINDER_SRC_DIR}/cinder/app/AppBase.cpp
	${CINDER_SRC_DIR}/cinder/app/KeyEvent.cpp
	${CINDER_SRC_DIR}/cinder/app/Platform.cpp
	${CINDER_SRC_DIR}/cinder/app/Renderer.cpp
	${CINDER_SRC_DIR}/cinder/app/RendererGl.cpp
	${CINDER_SRC_DIR}/cinder/app/Window.cpp
)

if( CINDER_TARGET MATCHES "linux" )
    list( APPEND SRC_SET_CINDER_APP_LINUX
        ${CINDER_SRC_DIR}/cinder/app/linux/AppImplLinuxGlfw.cpp
        ${CINDER_SRC_DIR}/cinder/app/linux/AppLinux.cpp
        ${CINDER_SRC_DIR}/cinder/app/linux/PlatformLinux.cpp
        ${CINDER_SRC_DIR}/cinder/app/linux/RendererGlLinuxGlfw.cpp
        ${CINDER_SRC_DIR}/cinder/app/linux/WindowImplLinuxGlfw.cpp
    )
endif()

list( APPEND SRC_SET_CINDER
	${CINDER_SRC_DIR}/cinder/Area.cpp
	${CINDER_SRC_DIR}/cinder/Area.cpp
	${CINDER_SRC_DIR}/cinder/BandedMatrix.cpp
	${CINDER_SRC_DIR}/cinder/Base64.cpp
	${CINDER_SRC_DIR}/cinder/BSpline.cpp
	${CINDER_SRC_DIR}/cinder/BSplineFit.cpp
	${CINDER_SRC_DIR}/cinder/Buffer.cpp
	${CINDER_SRC_DIR}/cinder/Camera.cpp
	${CINDER_SRC_DIR}/cinder/CameraUi.cpp
	${CINDER_SRC_DIR}/cinder/Capture.cpp
	${CINDER_SRC_DIR}/cinder/Channel.cpp
	${CINDER_SRC_DIR}/cinder/CinderAssert.cpp
	${CINDER_SRC_DIR}/cinder/CinderMath.cpp
	${CINDER_SRC_DIR}/cinder/Clipboard.cpp
	${CINDER_SRC_DIR}/cinder/Color.cpp
	${CINDER_SRC_DIR}/cinder/ConvexHull.cpp
	${CINDER_SRC_DIR}/cinder/DataSource.cpp
	${CINDER_SRC_DIR}/cinder/DataTarget.cpp
	${CINDER_SRC_DIR}/cinder/Display.cpp
	${CINDER_SRC_DIR}/cinder/Exception.cpp
	${CINDER_SRC_DIR}/cinder/Font.cpp
	${CINDER_SRC_DIR}/cinder/Frustum.cpp
	${CINDER_SRC_DIR}/cinder/GeomIo.cpp
	${CINDER_SRC_DIR}/cinder/ImageFileTinyExr.cpp
	${CINDER_SRC_DIR}/cinder/ImageIo.cpp
	${CINDER_SRC_DIR}/cinder/ImageSourceFileRadiance.cpp
	${CINDER_SRC_DIR}/cinder/ImageSourceFileStbImage.cpp
	${CINDER_SRC_DIR}/cinder/ImageTargetFileStbImage.cpp
	${CINDER_SRC_DIR}/cinder/Json.cpp
	${CINDER_SRC_DIR}/cinder/Log.cpp
	${CINDER_SRC_DIR}/cinder/Matrix.cpp
	${CINDER_SRC_DIR}/cinder/ObjLoader.cpp
	${CINDER_SRC_DIR}/cinder/Path2d.cpp
	${CINDER_SRC_DIR}/cinder/Perlin.cpp
	${CINDER_SRC_DIR}/cinder/Plane.cpp
	${CINDER_SRC_DIR}/cinder/PolyLine.cpp
	${CINDER_SRC_DIR}/cinder/Rand.cpp
	${CINDER_SRC_DIR}/cinder/Ray.cpp
	${CINDER_SRC_DIR}/cinder/Rect.cpp
	${CINDER_SRC_DIR}/cinder/Serial.cpp
	${CINDER_SRC_DIR}/cinder/Shape2d.cpp
	${CINDER_SRC_DIR}/cinder/Signals.cpp
	${CINDER_SRC_DIR}/cinder/Sphere.cpp
	${CINDER_SRC_DIR}/cinder/Stream.cpp
	${CINDER_SRC_DIR}/cinder/Surface.cpp
	${CINDER_SRC_DIR}/cinder/System.cpp
	${CINDER_SRC_DIR}/cinder/Text.cpp
	${CINDER_SRC_DIR}/cinder/Timeline.cpp
	${CINDER_SRC_DIR}/cinder/TimelineItem.cpp
	${CINDER_SRC_DIR}/cinder/Timer.cpp
	${CINDER_SRC_DIR}/cinder/Triangulate.cpp
	${CINDER_SRC_DIR}/cinder/TriMesh.cpp
	${CINDER_SRC_DIR}/cinder/Tween.cpp
	${CINDER_SRC_DIR}/cinder/Unicode.cpp
	${CINDER_SRC_DIR}/cinder/Url.cpp
	${CINDER_SRC_DIR}/cinder/UrlImplCurl.cpp
	${CINDER_SRC_DIR}/cinder/Utilities.cpp
	${CINDER_SRC_DIR}/cinder/Xml.cpp
)

# ----------------------------------------------------------------------------------------------------------------------
# libpng
# ----------------------------------------------------------------------------------------------------------------------

if( PNG_FOUND )
	list( APPEND SRC_SET_CINDER
		${CINDER_SRC_DIR}/cinder/ImageSourcePng.cpp
	)
endif()

# ----------------------------------------------------------------------------------------------------------------------
# Source groups
# ----------------------------------------------------------------------------------------------------------------------
source_group( "cinder\\app"             FILES ${SRC_SET_CINDER_APP} )
source_group( "cinder\\app\\linux"      FILES ${SRC_SET_CINDER_APP_LINUX} )
source_group( "cinder" 		            FILES ${SRC_SET_CINDER} )

# ----------------------------------------------------------------------------------------------------------------------
# Combine the sources
# ----------------------------------------------------------------------------------------------------------------------
list( APPEND CINDER_SRC_FILES
	${SRC_SET_CINDER_APP}
	${SRC_SET_CINDER_APP_ANDROID}
	${SRC_SET_CINDER_APP_LINUX}
	${SRC_SET_CINDER}
)

# ----------------------------------------------------------------------------------------------------------------------
# FreeType
# ----------------------------------------------------------------------------------------------------------------------

if( NOT CINDER_FREETYPE_USE_SYSTEM )
	list( APPEND SRC_SET_FREETYPE
		${CINDER_SRC_DIR}/freetype/autofit/afangles.c
		${CINDER_SRC_DIR}/freetype/autofit/afblue.c
		${CINDER_SRC_DIR}/freetype/autofit/afblue.cin
		${CINDER_SRC_DIR}/freetype/autofit/afcjk.c
		${CINDER_SRC_DIR}/freetype/autofit/afdummy.c
		${CINDER_SRC_DIR}/freetype/autofit/afglobal.c
		${CINDER_SRC_DIR}/freetype/autofit/afhints.c
		${CINDER_SRC_DIR}/freetype/autofit/afindic.c
		${CINDER_SRC_DIR}/freetype/autofit/aflatin2.c
		${CINDER_SRC_DIR}/freetype/autofit/aflatin.c
		${CINDER_SRC_DIR}/freetype/autofit/afloader.c
		${CINDER_SRC_DIR}/freetype/autofit/afmodule.c
		${CINDER_SRC_DIR}/freetype/autofit/afpic.c
		${CINDER_SRC_DIR}/freetype/autofit/afranges.c
		${CINDER_SRC_DIR}/freetype/autofit/afwarp.c
		${CINDER_SRC_DIR}/freetype/autofit/autofit.c
		${CINDER_SRC_DIR}/freetype/autofit/hbshim.c
		${CINDER_SRC_DIR}/freetype/base/basepic.c
		${CINDER_SRC_DIR}/freetype/base/ftadvanc.c
		${CINDER_SRC_DIR}/freetype/base/ftapi.c
		${CINDER_SRC_DIR}/freetype/base/ftbase.c
		${CINDER_SRC_DIR}/freetype/base/ftbbox.c
		${CINDER_SRC_DIR}/freetype/base/ftbdf.c
		${CINDER_SRC_DIR}/freetype/base/ftbitmap.c
		${CINDER_SRC_DIR}/freetype/base/ftcalc.c
		${CINDER_SRC_DIR}/freetype/base/ftcid.c
		${CINDER_SRC_DIR}/freetype/base/ftdbgmem.c
		${CINDER_SRC_DIR}/freetype/base/ftdebug.c
		${CINDER_SRC_DIR}/freetype/base/ftfntfmt.c
		${CINDER_SRC_DIR}/freetype/base/ftfstype.c
		${CINDER_SRC_DIR}/freetype/base/ftgasp.c
		${CINDER_SRC_DIR}/freetype/base/ftgloadr.c
		${CINDER_SRC_DIR}/freetype/base/ftglyph.c
		${CINDER_SRC_DIR}/freetype/base/ftgxval.c
		${CINDER_SRC_DIR}/freetype/base/ftinit.c
		${CINDER_SRC_DIR}/freetype/base/ftlcdfil.c
		${CINDER_SRC_DIR}/freetype/base/ftmac.c
		${CINDER_SRC_DIR}/freetype/base/ftmm.c
		${CINDER_SRC_DIR}/freetype/base/ftobjs.c
		${CINDER_SRC_DIR}/freetype/base/ftotval.c
		${CINDER_SRC_DIR}/freetype/base/ftoutln.c
		${CINDER_SRC_DIR}/freetype/base/ftpatent.c
		${CINDER_SRC_DIR}/freetype/base/ftpfr.c
		${CINDER_SRC_DIR}/freetype/base/ftpic.c
		${CINDER_SRC_DIR}/freetype/base/ftrfork.c
		${CINDER_SRC_DIR}/freetype/base/ftsnames.c
		${CINDER_SRC_DIR}/freetype/base/ftstream.c
		${CINDER_SRC_DIR}/freetype/base/ftstroke.c
		${CINDER_SRC_DIR}/freetype/base/ftsynth.c
		${CINDER_SRC_DIR}/freetype/base/ftsystem.c
		${CINDER_SRC_DIR}/freetype/base/fttrigon.c
		${CINDER_SRC_DIR}/freetype/base/fttype1.c
		${CINDER_SRC_DIR}/freetype/base/ftutil.c
		${CINDER_SRC_DIR}/freetype/base/ftwinfnt.c
		${CINDER_SRC_DIR}/freetype/base/md5.c
		${CINDER_SRC_DIR}/freetype/bdf/bdf.c
		${CINDER_SRC_DIR}/freetype/bdf/bdfdrivr.c
		${CINDER_SRC_DIR}/freetype/bdf/bdflib.c
		${CINDER_SRC_DIR}/freetype/bzip2/ftbzip2.c
		${CINDER_SRC_DIR}/freetype/cache/ftcache.c
		${CINDER_SRC_DIR}/freetype/cache/ftcbasic.c
		${CINDER_SRC_DIR}/freetype/cache/ftccache.c
		${CINDER_SRC_DIR}/freetype/cache/ftccmap.c
		${CINDER_SRC_DIR}/freetype/cache/ftcglyph.c
		${CINDER_SRC_DIR}/freetype/cache/ftcimage.c
		${CINDER_SRC_DIR}/freetype/cache/ftcmanag.c
		${CINDER_SRC_DIR}/freetype/cache/ftcmru.c
		${CINDER_SRC_DIR}/freetype/cache/ftcsbits.c
		${CINDER_SRC_DIR}/freetype/cff/cf2arrst.c
		${CINDER_SRC_DIR}/freetype/cff/cf2blues.c
		${CINDER_SRC_DIR}/freetype/cff/cf2error.c
		${CINDER_SRC_DIR}/freetype/cff/cf2font.c
		${CINDER_SRC_DIR}/freetype/cff/cf2ft.c
		${CINDER_SRC_DIR}/freetype/cff/cf2hints.c
		${CINDER_SRC_DIR}/freetype/cff/cf2intrp.c
		${CINDER_SRC_DIR}/freetype/cff/cf2read.c
		${CINDER_SRC_DIR}/freetype/cff/cf2stack.c
		${CINDER_SRC_DIR}/freetype/cff/cff.c
		${CINDER_SRC_DIR}/freetype/cff/cffcmap.c
		${CINDER_SRC_DIR}/freetype/cff/cffdrivr.c
		${CINDER_SRC_DIR}/freetype/cff/cffgload.c
		${CINDER_SRC_DIR}/freetype/cff/cffload.c
		${CINDER_SRC_DIR}/freetype/cff/cffobjs.c
		${CINDER_SRC_DIR}/freetype/cff/cffparse.c
		${CINDER_SRC_DIR}/freetype/cff/cffpic.c
		${CINDER_SRC_DIR}/freetype/cid/cidgload.c
		${CINDER_SRC_DIR}/freetype/cid/cidload.c
		${CINDER_SRC_DIR}/freetype/cid/cidobjs.c
		${CINDER_SRC_DIR}/freetype/cid/cidparse.c
		${CINDER_SRC_DIR}/freetype/cid/cidriver.c
		${CINDER_SRC_DIR}/freetype/cid/type1cid.c
		${CINDER_SRC_DIR}/freetype/gxvalid/gxvalid.c
		${CINDER_SRC_DIR}/freetype/gxvalid/gxvbsln.c
		${CINDER_SRC_DIR}/freetype/gxvalid/gxvcommn.c
		${CINDER_SRC_DIR}/freetype/gxvalid/gxvfeat.c
		${CINDER_SRC_DIR}/freetype/gxvalid/gxvfgen.c
		${CINDER_SRC_DIR}/freetype/gxvalid/gxvjust.c
		${CINDER_SRC_DIR}/freetype/gxvalid/gxvkern.c
		${CINDER_SRC_DIR}/freetype/gxvalid/gxvlcar.c
		${CINDER_SRC_DIR}/freetype/gxvalid/gxvmod.c
		${CINDER_SRC_DIR}/freetype/gxvalid/gxvmort0.c
		${CINDER_SRC_DIR}/freetype/gxvalid/gxvmort1.c
		${CINDER_SRC_DIR}/freetype/gxvalid/gxvmort2.c
		${CINDER_SRC_DIR}/freetype/gxvalid/gxvmort4.c
		${CINDER_SRC_DIR}/freetype/gxvalid/gxvmort5.c
		${CINDER_SRC_DIR}/freetype/gxvalid/gxvmort.c
		${CINDER_SRC_DIR}/freetype/gxvalid/gxvmorx0.c
		${CINDER_SRC_DIR}/freetype/gxvalid/gxvmorx1.c
		${CINDER_SRC_DIR}/freetype/gxvalid/gxvmorx2.c
		${CINDER_SRC_DIR}/freetype/gxvalid/gxvmorx4.c
		${CINDER_SRC_DIR}/freetype/gxvalid/gxvmorx5.c
		${CINDER_SRC_DIR}/freetype/gxvalid/gxvmorx.c
		${CINDER_SRC_DIR}/freetype/gxvalid/gxvopbd.c
		${CINDER_SRC_DIR}/freetype/gxvalid/gxvprop.c
		${CINDER_SRC_DIR}/freetype/gxvalid/gxvtrak.c
		${CINDER_SRC_DIR}/freetype/gzip/adler32.c
		${CINDER_SRC_DIR}/freetype/gzip/ftgzip.c
		${CINDER_SRC_DIR}/freetype/gzip/infblock.c
		${CINDER_SRC_DIR}/freetype/gzip/infcodes.c
		${CINDER_SRC_DIR}/freetype/gzip/inflate.c
		${CINDER_SRC_DIR}/freetype/gzip/inftrees.c
		${CINDER_SRC_DIR}/freetype/gzip/infutil.c
		${CINDER_SRC_DIR}/freetype/gzip/zutil.c
		${CINDER_SRC_DIR}/freetype/lzw/ftlzw.c
		${CINDER_SRC_DIR}/freetype/lzw/ftzopen.c
		${CINDER_SRC_DIR}/freetype/otvalid/otvalid.c
		${CINDER_SRC_DIR}/freetype/otvalid/otvbase.c
		${CINDER_SRC_DIR}/freetype/otvalid/otvcommn.c
		${CINDER_SRC_DIR}/freetype/otvalid/otvgdef.c
		${CINDER_SRC_DIR}/freetype/otvalid/otvgpos.c
		${CINDER_SRC_DIR}/freetype/otvalid/otvgsub.c
		${CINDER_SRC_DIR}/freetype/otvalid/otvjstf.c
		${CINDER_SRC_DIR}/freetype/otvalid/otvmath.c
		${CINDER_SRC_DIR}/freetype/otvalid/otvmod.c
		${CINDER_SRC_DIR}/freetype/pcf/pcf.c
		${CINDER_SRC_DIR}/freetype/pcf/pcfdrivr.c
		${CINDER_SRC_DIR}/freetype/pcf/pcfread.c
		${CINDER_SRC_DIR}/freetype/pcf/pcfutil.c
		${CINDER_SRC_DIR}/freetype/pfr/pfr.c
		${CINDER_SRC_DIR}/freetype/pfr/pfrcmap.c
		${CINDER_SRC_DIR}/freetype/pfr/pfrdrivr.c
		${CINDER_SRC_DIR}/freetype/pfr/pfrgload.c
		${CINDER_SRC_DIR}/freetype/pfr/pfrload.c
		${CINDER_SRC_DIR}/freetype/pfr/pfrobjs.c
		${CINDER_SRC_DIR}/freetype/pfr/pfrsbit.c
		${CINDER_SRC_DIR}/freetype/psaux/afmparse.c
		${CINDER_SRC_DIR}/freetype/psaux/psaux.c
		${CINDER_SRC_DIR}/freetype/psaux/psauxmod.c
		${CINDER_SRC_DIR}/freetype/psaux/psconv.c
		${CINDER_SRC_DIR}/freetype/psaux/psobjs.c
		${CINDER_SRC_DIR}/freetype/psaux/t1cmap.c
		${CINDER_SRC_DIR}/freetype/psaux/t1decode.c
		${CINDER_SRC_DIR}/freetype/pshinter/pshalgo.c
		${CINDER_SRC_DIR}/freetype/pshinter/pshglob.c
		${CINDER_SRC_DIR}/freetype/pshinter/pshinter.c
		${CINDER_SRC_DIR}/freetype/pshinter/pshmod.c
		${CINDER_SRC_DIR}/freetype/pshinter/pshpic.c
		${CINDER_SRC_DIR}/freetype/pshinter/pshrec.c
		${CINDER_SRC_DIR}/freetype/psnames/psmodule.c
		${CINDER_SRC_DIR}/freetype/psnames/psnames.c
		${CINDER_SRC_DIR}/freetype/psnames/pspic.c
		${CINDER_SRC_DIR}/freetype/raster/ftraster.c
		${CINDER_SRC_DIR}/freetype/raster/ftrend1.c
		${CINDER_SRC_DIR}/freetype/raster/raster.c
		${CINDER_SRC_DIR}/freetype/raster/rastpic.c
		${CINDER_SRC_DIR}/freetype/sfnt/pngshim.c
		${CINDER_SRC_DIR}/freetype/sfnt/sfdriver.c
		${CINDER_SRC_DIR}/freetype/sfnt/sfnt.c
		${CINDER_SRC_DIR}/freetype/sfnt/sfntpic.c
		${CINDER_SRC_DIR}/freetype/sfnt/sfobjs.c
		${CINDER_SRC_DIR}/freetype/sfnt/ttbdf.c
		${CINDER_SRC_DIR}/freetype/sfnt/ttcmap.c
		${CINDER_SRC_DIR}/freetype/sfnt/ttkern.c
		${CINDER_SRC_DIR}/freetype/sfnt/ttload.c
		${CINDER_SRC_DIR}/freetype/sfnt/ttmtx.c
		${CINDER_SRC_DIR}/freetype/sfnt/ttpost.c
		${CINDER_SRC_DIR}/freetype/sfnt/ttsbit.c
		${CINDER_SRC_DIR}/freetype/smooth/ftgrays.c
		${CINDER_SRC_DIR}/freetype/smooth/ftsmooth.c
		${CINDER_SRC_DIR}/freetype/smooth/ftspic.c
		${CINDER_SRC_DIR}/freetype/smooth/smooth.c
		${CINDER_SRC_DIR}/freetype/truetype/truetype.c
		${CINDER_SRC_DIR}/freetype/truetype/ttdriver.c
		${CINDER_SRC_DIR}/freetype/truetype/ttgload.c
		${CINDER_SRC_DIR}/freetype/truetype/ttgxvar.c
		${CINDER_SRC_DIR}/freetype/truetype/ttinterp.c
		${CINDER_SRC_DIR}/freetype/truetype/ttobjs.c
		${CINDER_SRC_DIR}/freetype/truetype/ttpic.c
		${CINDER_SRC_DIR}/freetype/truetype/ttpload.c
		${CINDER_SRC_DIR}/freetype/truetype/ttsubpix.c
		${CINDER_SRC_DIR}/freetype/type1/t1afm.c
		${CINDER_SRC_DIR}/freetype/type1/t1driver.c
		${CINDER_SRC_DIR}/freetype/type1/t1gload.c
		${CINDER_SRC_DIR}/freetype/type1/t1load.c
		${CINDER_SRC_DIR}/freetype/type1/t1objs.c
		${CINDER_SRC_DIR}/freetype/type1/t1parse.c
		${CINDER_SRC_DIR}/freetype/type1/type1.c
		${CINDER_SRC_DIR}/freetype/type42/t42drivr.c
		${CINDER_SRC_DIR}/freetype/type42/t42objs.c
		${CINDER_SRC_DIR}/freetype/type42/t42parse.c
		${CINDER_SRC_DIR}/freetype/type42/type42.c
		${CINDER_SRC_DIR}/freetype/winfonts/winfnt.c
	)

	list( APPEND CINDER_SRC_FILES
		${SRC_SET_FREETYPE}
	)

	source_group( "freetype" 		        FILES ${SRC_SET_FREETYPE} )

endif() # ! CINDER_FREETYPE_USE_SYSTEM