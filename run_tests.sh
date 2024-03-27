#!/bin/sh

if [ -z "$GODOT" ]; then
    GODOT=godot
fi

gdscript() {
    "$GODOT" --headless --path "$1" -d -s "$2"
}

if [ "$1" = generate ]; then
    gdscript demo/ generate_static_cases.gd
else
    gdscript demo/ addons/gut/gut_cmdln.gd
fi
