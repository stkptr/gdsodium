extends GutTest
class_name UnitTest

var Case
var filename

var cases

func _init(_Case, _filename):
	Case = _Case
	filename = _filename
	var static_cases = JSON.parse_string(FileAccess.get_file_as_string(filename))
	var random_cases = generate_cases(10)
	cases = static_cases.map(Case.new) + random_cases
	super()

func generate_cases(count, rng=null):
	var case = Case.new()
	return range(count).map(func(_a): return case.generate(rng))

class BaseCase:
	var test_rand_object

	func get_custom_properties() -> Array:
		var properties = []
		var hit_valid = false
		const sentinel = 'Built-in script'
		const exclude = [sentinel, 'test_rand_object']
		for p in get_property_list():
			if hit_valid and not p['name'] in exclude:
				properties.push_back(p)
			if p['name'] == sentinel:
				hit_valid = true
		return properties

	func _init(d={}, rng=null):
		test_rand_object = rng
		if test_rand_object == null:
			test_rand_object = RandomNumberGenerator.new()
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

	func rand_bytes(count: int) -> PackedByteArray:
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
		return '<Case#%d>' % get_instance_id()
