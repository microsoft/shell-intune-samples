#!/bin/bash

# Input flags + arguments
#   -d: (required) dmg path
#   -n: (required) desired output filename (no extension)
#   -s: (optional) DeveloperID to sign pkg (common cert)
#   -p: (optional) Output a .pkg rather than .intunemac
# The output file will be written to the location the script is ran from.
#
# Example:
# ./DmgtoIntunemac.sh -d ~/Downloads/Spotify.dmg -n SpotifyFinal
#
# Notes:
# 1. Make sure that the DmgtoIntunemac.sh shell script is located in the same directory as the Intune App Wrapping Tool (IntuneAppUtil). The name of this directory when downloaded from Microsoft is: intune-app-wrapping-tool-mac-master. 
# 2. Although the signing flag is optional for this conversion script, packages must be signed in order to successfully install as a managed app. 


signing=""
exit_abnormal() {
    echo "must include -d flag with argument <application filepath>"
    echo "must include -n flag with argument <output filename>"
    echo "optional: -s flag for signing, then argument <Mac Developer ID (common cert)>"
    echo "optional: -p flag for outputting a pkg rather than Intunemac file"
    exit 1
}

while getopts "d:n:s:p" options; do 
case "${options}" in
d)
dmgpath="${OPTARG}";;
n)
outputfilename="${OPTARG}";;
s)
MacDeveloperID="${OPTARG}"
echo "MacDeveloperID is: "$MacDeveloperID""
;;
p)
skipconvert="t"
echo "Output will be a .pkg file"
;;
# :)
# echo "Error: -${OPTARG} requires an argument.";;
*)
exit_abnormal;;
esac
done

if [ ! "$dmgpath" ] || [ ! "$outputfilename" ]
then
	exit_abnormal
fi

echo "dmg path is: "$dmgpath""
hdiutil attach "$dmgpath"
mkdir ./pkgtempdir

appPath=$(find /Volumes -maxdepth 2 -name "*.app")
echo "app path is: "$appPath""

appDirName=$(dirname "$appPath")
echo "app directory is: "$appDirName""

pkgbuild --install-location /Applications --component "$appPath" ./pkgtempdir/temp.pkg
productbuild --synthesize --package ./pkgtempdir/temp.pkg ./pkgtempdir/distribution.xml
cd ./pkgtempdir/
productbuild --distribution ./distribution.xml --package-path ./temp.pkg ./intermediate.pkg
if ["$MacDeveloperID" = ""]; then
mv ./intermediate.pkg ./final.pkg
else
productsign --sign "$MacDeveloperID" ./intermediate.pkg ./final.pkg
fi

mv ./final.pkg ..
cd ..
mv ./final.pkg ./"$outputfilename".pkg
rm -rf ./pkgtempdir
hdiutil detach "$appDirName"

if [ ! "$skipconvert" ]
then
	./IntuneAppUtil -c ./"$outputfilename".pkg -o .
	rm -rf ./"$outputfilename".pkg
fi