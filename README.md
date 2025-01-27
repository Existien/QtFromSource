# QtFromSource

Simple docker container with Qt for gcc64 and wasm built from source.
Also includes node and QtCreator.

Run ```docker build .``` to build image.

Available build args:

- `QT_VERSION` the Qt version to build from source
- `EMSCRIPTEN_VERSION` emscripten version. Make sure it's compatible with the selected Qt version. (see https://doc.qt.io/qt-6/wasm.html)
- `QT_DOC_VERSION` sets the version of examples and documentation installed with the QtCreator.

## TODO

- configure WASM corectly in QtCreator