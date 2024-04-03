extends GutTest
class_name UnitTest

var Case
var filename

var cases

func _init(_Case, _filename):
	super()
	Case = _Case
	filename = _filename
	var static_cases = []
	if FileAccess.file_exists(filename):
		static_cases = JSON.parse_string(
			FileAccess.get_file_as_string(filename))
	else:
		print(("Static case file '%s' not found."
			+ " Ignore this warning if generating static cases.")
			% filename
		)
	var random_cases = generate_cases(10)
	cases = static_cases.map(Case.new) + random_cases

func generate_cases(count, rng=null):
	var case = Case.new()
	return range(count).map(func(_a): return case.generate(rng))

static func is_empty(e):
	if e is PackedByteArray:
		return e.is_empty()
	elif e is GDSodiumType:
		for p in e.get_property_list():
			if p['type'] == 1 and e.get(p['name']):
				return false
			elif p['type'] == 29 and not e.get(p['name']).is_empty():
				return false
	return true

func assert_empty(e, msg=''):
	assert_true(is_empty(e), msg)

func assert_not_empty(e, msg=''):
	assert_false(is_empty(e), msg)

func assert_incorrect_length(f, v: PackedByteArray, msg=''):
	var p = v.slice(v.size() / 2)
	assert_empty(f.call(p), msg)
	p.append_array(v)
	assert_empty(f.call(p), msg)

func assert_ilen_ne(f, v: PackedByteArray, t, msg=''):
	var p = v.slice(v.size() / 2)
	assert_ne(f.call(p), t, msg)
	p.append_array(v)
	assert_ne(f.call(p), t, msg)

func assert_ilen_false(f, v: PackedByteArray, msg=''):
	assert_ilen_ne(f, v, true, msg)

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

	func _init(d={}, rng=null):
		test_rand_object = rng
		var properties = get_custom_properties()
		for p in properties:
			var source = d.get(p['name'])
			set(p['name'],
				Marshalls.base64_to_raw(source) if source is String else source)

	func dump() -> Dictionary:
		var properties = get_custom_properties()
		var d = {}
		for p in properties:
			d[p['name']] = Marshalls.raw_to_base64(get(p['name']))
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
