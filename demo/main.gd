#!/usr/bin/env -S godot -s
extends SceneTree

# workaround for https://github.com/godotengine/godot/issues/88055
func exit(code=0):
    print(code)
    quit(code)

func _init():
    var output = StandardOutput.new()
    var success = TestRunner.run(output)
    exit(0 if success else 1)
