extends GutTest
class_name UnitTest

static func base64(b):
    if b is String:
        return Marshalls.base64_to_raw(b)
    else:
        return Marshalls.raw_to_base64(b)

static func ascii(b):
    if b is String:
        return b.to_ascii_buffer()
    else:
        return b.get_string_from_ascii()

func run_cases(f: Callable, cases: Array):
    for c in cases:
        assert_true(f.call(c))

func run_cases_b64(f: Callable, cases: Array):
    run_cases(f, cases.map(func(a): return a.map(self.base64)))
