extends Object
class_name TestRunner

static func run_test(output, path):
    var script = load('res://tests/' + path).new(output)
    return script.run()

static func run(output):
    var tests = DirAccess.open('res://tests').get_files()
    return UnitTest.run_many(
        output,
        'test',
        func(t): return run_test(output, t),
        tests
    )
