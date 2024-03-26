#!/bin/sh

if [ -z "$GODOT" ]; then
    GODOT=godot
fi

gdscript() {
    # workaround for https://github.com/godotengine/godot/issues/88055
    exit $("$GODOT" --headless --path "$1" -s "$2" | tee /dev/stderr | tail -n1)
}

gdscript demo/ main.gd
