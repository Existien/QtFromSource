#!/bin/bash
set -e -u

VERSION=$1
DOC_VERSION=$2
qtversionXML=$3
QtCreatorINI=$4

sed -Ei "s|@QT_VERSION@|$VERSION|g" $qtversionXML
sed -Ei "s|@QT_VERSION_COMPACT@|${VERSION//./}|g" $qtversionXML
sed -Ei "s|@QT_DOC_VERSION@|$DOC_VERSION|g" $QtCreatorINI