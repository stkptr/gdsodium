#!/bin/sh

if [ -z "$GODOT" ]; then
    GODOT=godot
fi

"$GODOT" --headless --path demo/ -d -s addons/gut/gut_cmdln.gd
