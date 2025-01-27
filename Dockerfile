ARG QT_VERSION=6.8.1
ARG QT_DOC_VERSION=6.8.0
ARG EMSCRIPTEN_VERSION=3.1.56

FROM ubuntu:24.04 AS builder
ARG DEBIAN_FRONTEND=noninteractive
ARG QT_VERSION
ARG EMSCRIPTEN_VERSION

WORKDIR /

RUN \
    apt-get update && \
    apt-get full-upgrade -y && \
    apt-get install --no-install-recommends -y \
    apt-utils \
    build-essential \
    chromium \
    curl \
    git \
    less \
    libc6 \
    libdbus-1-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libglib2.0-dev \
    libgles2 \
    libgles-dev \
    libglib2.0-dev \
    libx11-dev \
    libx11-xcb-dev \
    libxcb1-dev \
    libxcb-composite0-dev \
    libxcb-cursor-dev \
    libxcb-glx0-dev \
    libxcb-icccm4-dev \
    libxcb-image0-dev \
    libxcb-keysyms1-dev \
    libxcb-randr0-dev \
    libxcb-render-util0-dev \
    libxcb-shape0-dev \
    libxcb-shm0-dev \
    libxcb-sync-dev \
    libxcb-util-dev \
    libxcb-xfixes0-dev \
    libxcb-xinerama0-dev \
    libxcb-xkb-dev \
    libxext-dev \
    libxfixes-dev \
    libxi-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    libxrender-dev \
    locales \
    ninja-build \
    nodejs \
    npm \
    pdftk \
    procps \
    psmisc \
    python3 \
    python3-pip \
    tmux \
    vim \
    wget \
    xfwm4 \
    xterm \
    xvfb \
    zip \
    && \
    rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --break-system-packages cmake

RUN git clone https://github.com/emscripten-core/emsdk.git && \
    cd emsdk && \
    ./emsdk install $EMSCRIPTEN_VERSION && \
    ./emsdk activate $EMSCRIPTEN_VERSION

# Download sources
RUN git clone --depth 1 --recursive --branch v$QT_VERSION git://code.qt.io/qt/qt5.git /sources/qt5

# Create install directories
RUN mkdir -p /Qt/$QT_VERSION/gcc_64 && \
    mkdir -p /Qt/$QT_VERSION/wasm

# Create build directories
RUN mkdir -p /build/qt-gcc && \
    mkdir -p /build/qt-wasm

# Build Qt for x86_64
RUN cd /build/qt-gcc && \
    /sources/qt5/configure -prefix /Qt/$QT_VERSION/gcc_64 -make examples -release && \
    cmake --build . --parallel && cmake --install . && \
    cd / && rm -rf /build/qt-gcc

# Build Qt for wasm
SHELL ["/bin/bash", "-c"]
RUN cd /build/qt-wasm && \
    source /emsdk/emsdk_env.sh && \
    /sources/qt5/configure -qt-host-path /Qt/$QT_VERSION/gcc_64 -platform wasm-emscripten -prefix /Qt/$QT_VERSION/wasm && \
    cmake --build . --parallel && cmake --install . && chmod a+x /Qt/$QT_VERSION/wasm/bin/* && \
    cd / && rm -rf /build/qt-wasm

FROM ubuntu:24.04
ARG DEBIAN_FRONTEND=noninteractive
ARG QT_VERSION
ARG QT_DOC_VERSION
ARG EMSCRIPTEN_VERSION

WORKDIR /

RUN \
    apt-get update && \
    apt-get full-upgrade -y && \
    apt-get install --no-install-recommends -y \
    apt-utils \
    build-essential \
    chromium \
    curl \
    git \
    less \
    libc6 \
    libdbus-1-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libglib2.0-dev \
    libgles2 \
    libgles-dev \
    libglib2.0-dev \
    libx11-dev \
    libx11-xcb-dev \
    libxcb1-dev \
    libxcb-composite0-dev \
    libxcb-cursor-dev \
    libxcb-glx0-dev \
    libxcb-icccm4-dev \
    libxcb-image0-dev \
    libxcb-keysyms1-dev \
    libxcb-randr0-dev \
    libxcb-render-util0-dev \
    libxcb-shape0-dev \
    libxcb-shm0-dev \
    libxcb-sync-dev \
    libxcb-util-dev \
    libxcb-xfixes0-dev \
    libxcb-xinerama0-dev \
    libxcb-xkb-dev \
    libxext-dev \
    libxfixes-dev \
    libxi-dev \
    libxkbcommon-dev \
    libxkbcommon-x11-dev \
    libxrender-dev \
    locales \
    ninja-build \
    nodejs \
    npm \
    pdftk \
    procps \
    psmisc \
    python3 \
    python3-pip \
    tmux \
    vim \
    wget \
    xfwm4 \
    xterm \
    xvfb \
    zip \
    mesa-utils \
    && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /Qt /Qt

RUN python3 -m pip install --break-system-packages cmake aqtinstall

RUN git clone https://github.com/emscripten-core/emsdk.git && \
    cd emsdk && \
    ./emsdk install $EMSCRIPTEN_VERSION && \
    ./emsdk activate $EMSCRIPTEN_VERSION

RUN npm install -g n && \
    n 16 && \
    n prune

WORKDIR /Qt

RUN \
    aqt install-tool linux desktop tools_qtcreator qt.tools.qtcreator && \
    aqt install-example linux $QT_DOC_VERSION && aqt install-doc linux $QT_DOC_VERSION

RUN mkdir -p /Qt/Tools/QtCreator/share/qtcreator/QtProject/qtcreator
COPY QtCreator.ini /Qt/Tools/QtCreator/share/qtcreator/QtProject
COPY qtversion.xml /Qt/Tools/QtCreator/share/qtcreator/QtProject/qtcreator
COPY configure_version.sh /tmp
RUN /tmp/configure_version.sh \
    $QT_VERSION \
    $QT_DOC_VERSION \
    /Qt/Tools/QtCreator/share/qtcreator/QtProject/qtcreator/qtversion.xml \
    /Qt/Tools/QtCreator/share/qtcreator/QtProject/QtCreator.ini \
    && rm /tmp/configure_version.sh

RUN \
  sed -Ei '/(en_US|de_DE|fr_FR)\.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8

ENTRYPOINT ["/bin/bash", "-lc", "\"$0\" \"$@\""]
