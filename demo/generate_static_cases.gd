extends SceneTree

func _init():
	const rseed = 33550336
	for f in DirAccess.open('res://test/unit').get_files():
		if not f.ends_with('.gd'):
			continue
		f = 'res://test/unit/' + f
		var script = load(f).new()
		var rng = RandomNumberGenerator.new()
		rng.seed = rseed
		var cases = script.generate_cases(10, rng)
		var arrays = cases.map(func(a): return a.dump())
		var json = JSON.stringify(arrays, '\t')
		var outfile = f.get_basename() + '.json'
		var w = FileAccess.open(outfile, FileAccess.WRITE)
		w.store_string(json)
	quit()
