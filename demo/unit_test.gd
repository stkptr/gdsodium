extends GutTest
class_name UnitTest

var Case
var filename
var fixed_filename

var cases

func _init(_Case, _filename, _fixed_filename=null):
	super()
	Case = _Case
	filename = _filename
	fixed_filename = _fixed_filename
	var static_cases = []
	if FileAccess.file_exists(filename):
		static_cases = JSON.parse_string(
			FileAccess.get_file_as_string(filename))
	else:
		print(("Static case file '%s' not found."
			+ " Ignore this warning if generating static cases.")
			% filename
		)
	if fixed_filename and FileAccess.file_exists(fixed_filename):
		static_cases.append_array(JSON.parse_string(
			FileAccess.get_file_as_string(fixed_filename)))
	elif fixed_filename:
		push_error("Fixed case file '%s' not found" % fixed_filename)
	var random_cases = generate_cases(10)
	cases = static_cases.map(Case.new) + random_cases

func generate_cases(count, rng=null):
	var case = Case.new()
	return range(count).map(func(_a): return case.generate(rng))

static func is_empty(e):
	if e is PackedByteArray or e is Array:
		return e.is_empty()
	elif e is GDSodiumType:
		for p in e.get_property_list():
			if p['type'] == 1 and e.get(p['name']):
				return false
			elif p['type'] == 29 and not e.get(p['name']).is_empty():
				return false
	return true

func assert_empty(e, msg=''):
	assert_true(UnitTest.is_empty(e), msg)

func assert_not_empty(e, msg=''):
	assert_false(UnitTest.is_empty(e), msg)

func assert_incorrect_length(f, v: PackedByteArray, msg=''):
	# warning supression
	var p = v.slice(int(float(v.size()) / 2))
	assert_empty(f.call(p), msg)
	p.append_array(v)
	assert_empty(f.call(p), msg)

func assert_ilen_ne(f, v: PackedByteArray, t, msg=''):
	# warning supression
	var p = v.slice(int(float(v.size()) / 2))
	assert_ne(f.call(p), t, msg)
	p.append_array(v)
	assert_ne(f.call(p), t, msg)

func assert_ilen_false(f, v: PackedByteArray, msg=''):
	assert_ilen_ne(f, v, true, msg)

func assert_many(assertion: Callable, f: Callable, d: Dictionary):
	for k in d.keys():
		var case_f = func(x):
			var infixed = d.duplicate()
			infixed[k] = x
			return f.call(infixed)
		assertion.call(case_f, d[k])

func assert_many_false(f: Callable, d: Dictionary):
	assert_many(assert_ilen_false, f, d)

func assert_many_empty(f: Callable, d: Dictionary):
	assert_many(assert_incorrect_length, f, d)

class BaseCase:
	var test_rand_object
	var test_rand_state

	func get_custom_properties() -> Array:
		var properties = []
		var hit_valid = false
		const sentinel = 'Built-in script'
		const exclude = [sentinel, 'test_rand_object', 'test_rand_state']
		for p in get_property_list():
			if hit_valid and not p['name'] in exclude:
				properties.push_back(p)
			if p['name'] == sentinel:
				hit_valid = true
		return properties

	func encode(d):
		if d is PackedByteArray:
			return Marshalls.raw_to_base64(d)
		return d

	func decode(d):
		if not d is String:
			return d
		var base = '32'
		var bases = {
			'32': func(s): return Marshalls.base64_to_raw(s),
			'0x': func(s): return s.hex_decode(),
			'a': func(s): return s,
		}
		var groups = d.split('~', true, 1)
		var data = groups[0]
		if len(groups) == 2:
			base = groups[0]
			data = groups[1]
		return bases[base].call(data)

	func _init(d={}, rng=null):
		test_rand_object = rng
		var properties = get_custom_properties()
		for p in properties:
			var source = d.get(p['name'])
			set(p['name'], decode(source))

	func dump() -> Dictionary:
		var properties = get_custom_properties()
		var d = {}
		for p in properties:
			d[p['name']] = encode(get(p['name']))
		return d

	func initialize_rand():
		if test_rand_object == null:
			test_rand_object = RandomNumberGenerator.new()
		if test_rand_state == null:
			test_rand_state = test_rand_object.state

	func rand_bytes(count: int) -> PackedByteArray:
		initialize_rand()
		return PackedByteArray(range(count).map(
			func(_a): return test_rand_object.randi_range(0, 255)
		))

	func randomize_properties():
		pass

	func generate(rng=null):
		var instance = new({}, rng)
		instance.randomize_properties()
		return instance

	func _to_string() -> String:
		if test_rand_state != null:
			return '<Case(state#%d)>' % test_rand_state
		else:
			return '<Case#%d>' % get_instance_id()
