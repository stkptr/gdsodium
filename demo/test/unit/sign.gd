extends UnitTest

func _init():
	super(Case, 'res://test/unit/sign.json')

func test_generate():
	assert_not_empty(GDSodiumSign.generate_keypair())

func test_generate_seed(case=use_parameters(cases)):
	var kp = GDSodiumSign.generate_keypair(case.key_seed)
	assert_eq(kp.private_key, case.private_key)
	assert_eq(kp.public_key, case.public_key)
	assert_incorrect_length(
		func(a): return GDSodiumSign.generate_keypair(a),
		case.key_seed
	)

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

func test_verify_detached(case=use_parameters(cases)):
	assert_true(GDSodiumSign.verify_detached(
		case.message, case.signature, case.public_key
	))
	var triplet = func(d):
		return GDSodiumSign.verify_detached(d.msg, d.sig, d.pub)
	assert_many_false(triplet, {
		sig = case.signature, msg = case.message, pub = case.public_key
	})

func test_open(case=use_parameters(cases)):
	var message = GDSodiumSign.open(
		case.signature + case.message, case.public_key
	)
	assert_true(message.valid)
	assert_eq(message.message, case.message)
	var triplet = func(d):
		var open = GDSodiumSign.open(d.sig + d.msg, d.pub)
		return open.valid or 0 < open.message.size()
	assert_many_false(triplet, {
		sig = case.signature, msg = case.message, pub = case.public_key
	})

func test_sign_multipart(case=use_parameters(cases)):
	var sign = func(d):
		var signer = GDSodiumSign.create()
		signer.update(d.msg)
		signer.update(d.msg2)
		return signer.final_sign(d.priv) == case.signature2
	var args = {
		msg = case.message,
		msg2 = case.message2,
		priv = case.private_key
	}
	assert_true(sign.call(args))
	assert_many_false(sign, args)

func test_verify_multipart(case=use_parameters(cases)):
	var verify = func(d):
		var signer = GDSodiumSign.create()
		signer.update(d.msg)
		signer.update(d.msg2)
		return signer.final_verify(case.signature2, d.pub)
	var args = {
		msg = case.message,
		msg2 = case.message2,
		pub = case.public_key
	}
	assert_true(verify.call(args))
	assert_many_false(verify, args)

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
		var signer = GDSodiumSign.create()

		key_seed = GDSodiumSign.private_key_to_seed(kp.private_key)
		private_key = kp.private_key
		public_key = kp.public_key
		message = rand_bytes(32)
		signature = GDSodiumSign.sign_detached(message, private_key)
		message2 = rand_bytes(32)
		signer.update(message)
		signer.update(message2)
		signature2 = signer.final_sign(private_key)
