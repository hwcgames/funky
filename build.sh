#!/bin/bash
if [ -z "$FUNKY_TARGET" ]; then
	export FUNKY_TARGET=$(uname)
fi
which godot > /dev/null && export godot="godot" || export godot="flatpak run org.godotengine.Godot"

# Create destination
export BUILD_DIR=./build/$FUNKY_TARGET
mkdir -p $BUILD_DIR
# Determine godot output profile
if [ "$FUNKY_TARGET" == "Darwin" ]; then
	export GODOT_PROFILE="Mac OSX"
	export EXTENSION="app"
elif [ "$FUNKY_TARGET" == "Windows" ]; then
	export GODOT_PROFILE="Windows Desktop"
	export EXTENSION="exe"
else
	export GODOT_PROFILE="Linux/X11"
	export EXTENSION="run"
fi
# Run godot build
$godot --export "$GODOT_PROFILE" $BUILD_DIR/FUNKY.$EXTENSION
echo "DONE!"