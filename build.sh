#!/bin/bash
if [ -z "$FUNKY_TARGET" ]; then
	export FUNKY_TARGET=$(uname)
fi
which godot > /dev/null && export godot="godot" || export godot="flatpak run org.godotengine.Godot"

# Create destination
# Determine godot output profile
export out_file_prefix="FUNKY"
if [ "$FUNKY_TARGET" == "Darwin" ]; then
	export GODOT_PROFILE="Mac OSX"
	export EXTENSION="app"
	export BUILD_DIR=./build/mac
elif [ "$FUNKY_TARGET" == "Windows" ]; then
	export GODOT_PROFILE="Windows Desktop"
	export EXTENSION="exe"
	export BUILD_DIR=./build/windows
elif [ "$FUNKY_TARGET" == "Web" ]; then
	export GODOT_PROFILE="HTML5"
	export EXTENSION="html"
	export BUILD_DIR=./build/web
	export out_file_prefix="index"
else
	export GODOT_PROFILE="Linux/X11"
	export EXTENSION="run"
	export BUILD_DIR=./build/linux
fi
mkdir -p $BUILD_DIR
# Run godot build
$godot --no-window --export "$GODOT_PROFILE" $BUILD_DIR/$out_file_prefix.$EXTENSION
# Copy license and attribution
cp LICENSE ATTRIBUTION $BUILD_DIR
echo "DONE!"