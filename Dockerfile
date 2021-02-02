FROM ubuntu:18.04

ENV AQT_VERSION=0.11.1
ENV DEBIAN_FRONTEND=noninteractive
ENV PY7ZR_VERSION=0.11.3
ENV QT_MIRROR=http://ftp.jaist.ac.jp/pub/qtproject/
ENV QT_VERSION=5.12.10
ENV TZ=Australia/Melbourne

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    libgl1-mesa-dev \
    libpulse-dev \
    libxkbcommon-x11-0 \
    python3-pip \
    python3.8 \
    python3.8-dev \
    python3.8-distutils \
    python3.8-venv \
    rpm

RUN python3 -m pip install \
    setuptools \
    wheel
    
RUN python3 -m pip install \
    py7zr==$PY7ZR_VERSION \
    aqtinstall==$AQT_VERSION

RUN python3 -m aqt install \
    $QT_VERSION \
    linux \
    desktop \
    -O /app/Qt \
    -b $QT_MIRROR

ENV LD_LIBRARY_PATH=/app/Qt/$QT_VERSION/gcc_64/lib
ENV Qt5_Dir=/app/Qt/$QT_VERSION/gcc_64
ENV Qt5_DIR=/app/Qt/$QT_VERSION/gcc_64
ENV QT_PLUGIN_PATH=/app/Qt/$QT_VERSION/gcc_64/plugins
ENV QML2_IMPORT_PATH=/app/Qt/$QT_VERSION/gcc_64/qml

ADD ./ /app/brewtarget

RUN mkdir -p /app/build
WORKDIR /app/build

RUN cmake \
    /app/brewtarget \
    -DCMAKE_PREFIX_PATH=/app/Qt/$QT_VERSION/gcc_64 \
    && make package

ENV APPDIR=/app/AppDir
## install the app & apply app image hacks
RUN make install DESTDIR=$APPDIR \
    && mkdir -p $APPDIR/usr/share/icons/hicolor/256x256/apps \
    && cp \
        /app/brewtarget/build-scripts/linux/resources/brewtarget.png \
        $APPDIR/usr/share/icons/hicolor/256x256/apps

## install app builder
RUN apt install -y \
    desktop-file-utils \
    fakeroot \
    libgdk-pixbuf2.0-dev \
    patchelf \
    python3-setuptools \
    strace \
    wget \
    && wget \
        https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage \
        -O /usr/local/bin/appimagetool \
    && chmod +x /usr/local/bin/appimagetool \
    && wget \
        https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage \
        -O /usr/local/bin/linuxdeploy \
    && chmod +x /usr/local/bin/linuxdeploy \
    && wget \
        https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage \
        -O /usr/local/bin/linuxdeploy-plugin-qt \
    && chmod +x /usr/local/bin/linuxdeploy-plugin-qt \
    && python3 -m pip install appimage-builder

## actually run appimage-builder now
RUN appimage-builder \
    --recipe=/app/brewtarget/build-scripts/linux/AppImageBuilder.yml \
    --skip-test
