extends UnitTest

func _init():
	super(Case, 'res://test/unit/sign.json')

func test_generate():
	assert_not_empty(GDSodiumSign.generate_keypair())

func test_generate_seed(case=use_parameters(cases)):
	var kp = GDSodiumSign.generate_keypair(case.key_seed)
	assert_eq(kp.private_key, case.private_key)
	assert_eq(kp.public_key, case.public_key)
	var bad_seed = case.key_seed.slice(GDSodiumSign.SEED_BYTES / 2)
	assert_empty(GDSodiumSign.generate_keypair(bad_seed),
		'seeds of improper length shall return an empty pair')

func test_private_key_to_seed(case=use_parameters(cases)):
	var key_seed = GDSodiumSign.private_key_to_seed(case.private_key)
	assert_eq(key_seed, case.key_seed)
	assert_incorrect_length(
		func(a): return GDSodiumSign.private_key_to_seed(a),
		case.private_key
	)

func test_private_key_to_public_key(case=use_parameters(cases)):
	var pk = GDSodiumSign.private_key_to_public_key(case.private_key)
	assert_eq(pk, case.public_key)
	assert_incorrect_length(
		func(a): return GDSodiumSign.private_key_to_public_key(a),
		case.private_key
	)

func test_sign_detached(case=use_parameters(cases)):
	var signature = GDSodiumSign.sign_detached(case.message, case.private_key)
	assert_eq(signature, case.signature)
	assert_ilen_ne(
		func(a): return GDSodiumSign.sign_detached(a, case.private_key),
		case.message,
		case.signature
	)
	assert_incorrect_length(
		func(a): return GDSodiumSign.sign_detached(case.message, a),
		case.private_key
	)

func test_sign(case=use_parameters(cases)):
	var sig = GDSodiumSign.sign(case.message, case.private_key)
	var signed = case.signature + case.message
	assert_eq(sig, signed)
	assert_ilen_ne(
		func(a): return GDSodiumSign.sign(a, case.private_key),
		case.message,
		signed
	)
	assert_incorrect_length(
		func(a): return GDSodiumSign.sign(case.message, a),
		case.private_key
	)

func assert_triplet_false(triplet, a, b, c):
	assert_ilen_false(func(x): return triplet.call(x, b, c), a)
	assert_ilen_false(func(x): return triplet.call(a, x, c), b)
	assert_ilen_false(func(x): return triplet.call(a, b, x), c)

func test_verify_detached(case=use_parameters(cases)):
	assert_true(GDSodiumSign.verify_detached(
		case.message, case.signature, case.public_key
	))
	var triplet = func(sig, msg, pub):
		return GDSodiumSign.verify_detached(msg, sig, pub)
	assert_triplet_false(triplet, case.signature, case.message, case.public_key)

func test_open(case=use_parameters(cases)):
	var message = GDSodiumSign.open(
		case.signature + case.message, case.public_key
	)
	assert_true(message.valid)
	assert_eq(message.message, case.message)
	var triplet = func(sig, msg, pub):
		var open = GDSodiumSign.open(sig + msg, pub)
		return open.valid or 0 < open.message.size()
	assert_triplet_false(triplet, case.signature, case.message, case.public_key)

func test_sign_multipart(case=use_parameters(cases)):
	var sign = func(msg, msg2, priv):
		var signer = GDSodiumSign.new()
		signer.update(msg)
		signer.update(msg2)
		return signer.final_sign(priv) == case.signature2
	assert_true(sign.call(case.message, case.message2, case.private_key))
	assert_triplet_false(sign, case.message, case.message2, case.private_key)

func test_verify_multipart(case=use_parameters(cases)):
	var verify = func(msg, msg2, pub):
		var signer = GDSodiumSign.new()
		signer.update(msg)
		signer.update(msg2)
		return signer.final_verify(case.signature2, pub)
	assert_true(verify.call(case.message, case.message2, case.public_key))
	assert_triplet_false(verify, case.message, case.message2, case.public_key)

class Case extends BaseCase:
	var key_seed
	var private_key
	var public_key
	var message
	var signature
	var message2
	var signature2

	func randomize_properties():
		var kp = GDSodiumSign.generate_keypair(
			rand_bytes(GDSodiumSign.SEED_BYTES)
		)
		var signer = GDSodiumSign.new()

		key_seed = GDSodiumSign.private_key_to_seed(kp.private_key)
		private_key = kp.private_key
		public_key = kp.public_key
		message = rand_bytes(32)
		signature = GDSodiumSign.sign_detached(message, private_key)
		message2 = rand_bytes(32)
		signer.update(message)
		signer.update(message2)
		signature2 = signer.final_sign(private_key)
