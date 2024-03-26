extends RefCounted
class_name StandardOutput

func info(s):
    print(s)

func error(s):
    print(s)

func success(s):
    print(s)

func newline():
    print()
