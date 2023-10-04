#!/bin/sh

cd ../seelog
if [ -e generated.sqlite ]
then
    echo "Database exists"
else
    curl https://f001.backblazeb2.com/file/referred/seelog/generated.sqlite --output generated.sqlite
fi
