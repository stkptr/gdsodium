extends UnitTest

func _init():
	super(Case, 'res://test/unit/sign.json')

func test_generate():
	var kp = GDSodiumSign.generate_keypair()
	assert_false(kp.private_key.is_empty() or kp.public_key.is_empty())

func test_generate_seed(case=use_parameters(cases)):
	var kp = GDSodiumSign.generate_keypair(case.key_seed)
	assert_eq(kp.private_key, case.private_key)
	assert_eq(kp.public_key, case.public_key)

func test_private_key_to_seed(case=use_parameters(cases)):
	var key_seed = GDSodiumSign.private_key_to_seed(case.private_key)
	assert_eq(key_seed, case.key_seed)

func test_private_key_to_public_key(case=use_parameters(cases)):
	var pk = GDSodiumSign.private_key_to_public_key(case.private_key)
	assert_eq(pk, case.public_key)

func test_sign_detached(case=use_parameters(cases)):
	var signature = GDSodiumSign.sign_detached(case.message, case.private_key)
	assert_eq(signature, case.signature)

func test_sign(case=use_parameters(cases)):
	var sig = GDSodiumSign.sign(case.message, case.private_key)
	assert_eq(sig, case.signature + case.message)

func test_verify_detached(case=use_parameters(cases)):
	assert_true(GDSodiumSign.verify_detached(
		case.message, case.signature, case.public_key))

func test_open(case=use_parameters(cases)):
	var message = GDSodiumSign.open(
		case.signature + case.message, case.public_key)
	assert_true(message.valid)
	assert_eq(message.message, case.message)

func test_sign_multipart(case=use_parameters(cases)):
	var signer = GDSodiumSign.new()
	signer.update(case.message)
	signer.update(case.message2)
	assert_eq(signer.final_sign(case.private_key), case.signature2)

func test_verify_multipart(case=use_parameters(cases)):
	var signer = GDSodiumSign.new()
	signer.update(case.message)
	signer.update(case.message2)
	assert_true(signer.final_verify(case.signature2, case.public_key))

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
