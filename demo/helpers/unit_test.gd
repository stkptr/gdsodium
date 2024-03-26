extends RefCounted
class_name UnitTest

var output

func _init(_output):
    output = _output

func run():
    var success = true
    for m in get_method_list():
        if m['name'].begins_with('test'):
            output.newline()
            output.info('Running %s()' % m['name'])
            success = success and get(m['name']).call()
            output.newline()
    return success

func base64(b):
    if b is String:
        return Marshalls.base64_to_raw(b)
    else:
        return Marshalls.raw_to_base64(b)

func ascii(b):
    if b is String:
        return b.to_ascii_buffer()
    else:
        return b.get_string_from_ascii()

static func run_many(output, case_name: String, f: Callable, cases: Array):
    output.info('Running %d %ss' % [len(cases), case_name])
    var status = []
    for c in range(len(cases)):
        var case_passed = f.call(cases[c])
        if not case_passed:
            output.error('Failure: %s %d of %d failed' % [
                case_name, c + 1, len(cases)
            ])
        status.push_back(case_passed)
    var success = status.all(func(a): return a)
    if success:
        output.success('All %ss passed' % case_name)
    else:
        var fails = len(status.filter(func(a): return not a))
        output.error('Failure: %d of %d (%.02f%%) %ss failed' % [
            fails, len(status),
            (100.0 * fails) / len(status),
            case_name
        ])
    return success

func run_cases(f: Callable, cases: Array):
    return run_many(output, 'case', f, cases)

func run_cases_b64(f: Callable, cases: Array):
    return run_cases(f, cases.map(func(a): return a.map(self.base64)))
