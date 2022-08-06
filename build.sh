#!/bin/bash
if [ -z "$FUNKY_TARGET" ]; then
	export FUNKY_TARGET=$(uname)
fi
which godot > /dev/null && export godot="godot" || export godot="flatpak run org.godotengine.Godot"

# Create destination
# Determine godot output profile
if [ "$FUNKY_TARGET" == "Darwin" ]; then
	export GODOT_PROFILE="Mac OSX"
	export EXTENSION="app"
	export BUILD_DIR=./build/mac
elif [ "$FUNKY_TARGET" == "Windows" ]; then
	export GODOT_PROFILE="Windows Desktop"
	export EXTENSION="exe"
	export BUILD_DIR=./build/windows
else
	export GODOT_PROFILE="Linux/X11"
	export EXTENSION="run"
	export BUILD_DIR=./build/linux
fi
mkdir -p $BUILD_DIR
# Run godot build
$godot --no-window --export "$GODOT_PROFILE" $BUILD_DIR/FUNKY.$EXTENSION
# Copy license and attribution
cp LICENSE ATTRIBUTION $BUILD_DIR
# Copy songs
cp -r songs $BUILD_DIR
# Clean already-imported files from songs dir
rm -r $BUILD_DIR/songs/**/*.{import,ogg}
echo "DONE!"