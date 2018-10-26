#!/bin/sh

OGG=1.3.3
OGG_GIT="-bc82844df068429d209e909da47b1f730b53b689"
FLAC=1.3.2
FLAC_GIT="-faafa4c82c31e5aed7bc7c0e87a379825372c6ac"
OPUS=1.3
OPUSFILE=0.11
OPUSENC=0.2.1
OPUSTOOLS=0.2

LOG=$PWD/config.log
CORES=$(grep -c ^processor /proc/cpuinfo)

export CFLAGS="-s -O2"
export CXXFLAGS="-s -O2"
export LDFLAGS="-s"

# Clean up
rm -rf libogg-$OGG
rm -rf flac-$FLAC
rm -rf opus-$OPUS
rm -rf opusfile-$OPUSFILE
rm -rf libopusenc-$OPUSENC
rm -rf opus-tools-$OPUSTOOLS

## Start
echo "Most log mesages sent to $LOG... only 'errors' displayed here"
date > $LOG

## Build Ogg first
echo "Untarring libogg-$OGG.tar.gz..."
tar -zxf libogg-${OGG}${OGG_GIT}.tar.gz
cd libogg-$OGG
echo "Configuring..."
./configure --disable-shared >> $LOG
echo "Running make..."
make -j $CORES >> $LOG
cd ..

## Build FLAC
echo "Untarring flac-$FLAC.tar.gz..."
tar zxf flac-${FLAC}${FLAC_GIT}.tar.gz >> $LOG
cd flac-$FLAC
patch -p1 < ../01-flac.patch >> $LOG
echo "Configuring..."
./configure --with-ogg-includes=$PWD/../libogg-$OGG/include --with-ogg-libraries=$PWD/../libogg-$OGG/src/.libs/ --disable-shared --disable-xmms-plugin --disable-cpplibs >> $LOG
echo "Running make"
make -j $CORES >> $LOG
cd ..

## Build Opus
echo "Untarring opus-$OPUS.tar.gz..."
tar -zxf opus-$OPUS.tar.gz
cd opus-$OPUS
echo "Configuring..."
./configure --disable-extra-programs --enable-shared=no >> $LOG
echo "Running make"
make -j $CORES >> $LOG
cd ..

## Build Opusfile
echo "Untarring opusfile-$OPUSFILE.tar.gz..."
tar -zxf opusfile-$OPUSFILE.tar.gz
cd opusfile-$OPUSFILE
echo "Configuring..."
CPF="-I$PWD/../libogg-$OGG/include -I$PWD/../opus-$OPUS/include"
LDF="-L$PWD/../libogg-$OGG/src/.libs -L$PWD/../opus-$OPUS/.libs"
./configure DEPS_CFLAGS="$CPF" DEPS_LIBS="$LDF" --enable-shared=no --disable-examples --disable-doc >> $LOG
echo "Running make"
make -j $CORES >> $LOG
cd ..

## Build OpusEnc library
echo "Untarring libopusenc-$OPUSENC.tar.gz..."
tar -zxf libopusenc-$OPUSENC.tar.gz
cd libopusenc-$OPUSENC
echo "Configuring..."
CPF="-I$PWD/../libogg-$OGG/include -I$PWD/../opus-$OPUS/include -I$PWD/../opusfile-$OPUSFILE/include"
LDF="-L$PWD/../libogg-$OGG/src/.libs -L$PWD/../opus-$OPUS/.libs -lopus -L$PWD/../opusfile-$OPUSFILE/.libs"
./configure DEPS_CFLAGS="$CPF" DEPS_LIBS="$LDF" --enable-shared=no >> $LOG
echo "Running make"
make -j $CORES >> $LOG
cd ..

## Build Opustools
echo "Untarring opus-tools-$OPUSTOOLS.tar.gz..."
tar -zxf opus-tools-$OPUSTOOLS.tar.gz
cd opus-tools-$OPUSTOOLS
echo "Configuring..."
CPF="-I$PWD/../libogg-$OGG/include -I$PWD/../opus-$OPUS/include -I$PWD/../opusfile-$OPUSFILE/include -I$PWD/../libopusenc-$OPUSENC/include -I$PWD/../flac-$FLAC/include"
LDF="-L$PWD/../opus-$OPUS/.libs -lopus -L$PWD/../opusfile-$OPUSFILE/.libs -lopusfile -lopusurl -L$PWD/../libopusenc-$OPUSENC/.libs -lopusenc -L$PWD/../flac-$FLAC/src/libFLAC/.libs -L$PWD/../libogg-$OGG/src/.libs -logg"
./configure OPUS_CFLAGS="$CPF" OPUS_LIBS="$LDF" OPUSFILE_CFLAGS="$CPF" OPUSFILE_LIBS="$LDF" OPUSURL_CFLAGS="$CPF" OPUSURL_LIBS="$LDF" LIBOPUSENC_CFLAGS="$CPF" LIBOPUSENC_LIBS="$LDF" --enable-shared=no >> $LOG
echo "Running make"
make -j $CORES >> $LOG
cd ..

#rm -rf opus-tools-$OPUSTOOLS
#rm -rf libopusenc-$OPUSENC
#rm -rf opusfile-$OPUSFILE
#rm -rf opus-$OPUS
#rm -rf flac-$FLAC
#rm -rf libogg-$OGG
