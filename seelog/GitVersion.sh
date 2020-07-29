#!/bin/sh

echo "#define COPYRIGHT_YEAR `date +%Y`" > InfoPlist.h.tmp

build=`git rev-list --count HEAD`
echo "#define GIT_BUILD $build" >> InfoPlist.h.tmp
echo "#define GIT_BUILD_STRING \"$build\"" >> InfoPlist.h.tmp

version=`git describe --tags --always --match 'v*[0-9]' | awk -F'-' '{ print $1 }' | cut -c 2-`
echo "#define GIT_VERSION $version" >> InfoPlist.h.tmp
echo "#define GIT_VERSION_STRING \"$version\"" >> InfoPlist.h.tmp

description=`git describe --tags --always --match 'v*[0-9]' --dirty | cut -c 2-`
echo "#define GIT_DESCRIPTION $description" >> InfoPlist.h.tmp
echo "#define GIT_DESCRIPTION_STRING \"$description\"" >> InfoPlist.h.tmp

if diff -q InfoPlist.h InfoPlist.h.tmp; then
    rm InfoPlist.h.tmp
else
    mv -f InfoPlist.h.tmp InfoPlist.h
    touch Info.plist
fi
