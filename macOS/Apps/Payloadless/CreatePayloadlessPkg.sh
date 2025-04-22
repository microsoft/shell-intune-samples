#!/bin/bash
#chmod +x

AppName="placeholder"

mkdir -p /tmp/empty

pkgbuild --identifier "com.yourcompany.$AppName" \
         --version "1.0" \
         --root /tmp/empty \
         $AppName.pkg
