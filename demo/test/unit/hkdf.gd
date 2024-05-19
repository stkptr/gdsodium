extends UnitTest

func _init():
	super(Case, 'res://test/unit/hkdf.json', 'res://test/unit/fixed_hkdf.json')

func test_generate():
	assert_not_empty(GDSodiumHKDF.generate_key())

func test_extract(case=use_parameters(cases)):
	assert_eq(GDSodiumHKDF.extract(case.salt, case.ikm), case.prk)
	assert_ne(GDSodiumHKDF.extract(case.salt, PackedByteArray()), case.prk)

func test_expand(case=use_parameters(cases)):
	assert_eq(GDSodiumHKDF.expand(case.prk, case.ctx0, case.len0), case.out0)
	assert_incorrect_length(
		func(a): return GDSodiumHKDF.expand(a, case.ctx0, case.len0),
		case.prk
	)

func test_multi_extract(case=use_parameters(cases)):
	var ctx = GDSodiumHKDF.create()
	var half = int(float(case.ikm.size()) / 2)
	var start = case.ikm.slice(0, half)
	var rest = case.ikm.slice(half)
	ctx.update(start)
	ctx.update(rest)
	assert_not_empty(ctx.finalize())

class Case extends BaseCase:
	var ikm
	var salt
	var prk
	var ctx0
	var len0
	var out0

	func randomize_properties():
		ikm = rand_bytes(32)
		salt = rand_bytes(32)
		prk = GDSodiumHKDF.extract(salt, ikm)
		len0 = 32
		ctx0 = rand_bytes(len0)
		out0 = GDSodiumHKDF.expand(prk, ctx0, 32) 
