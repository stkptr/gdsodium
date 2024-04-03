extends UnitTest

func _init():
	super(Case, 'res://test/unit/key_exchange.json')

func test_generate():
	assert_not_empty(GDSodiumKeyExchange.generate_keypair())

func test_generate_seeds(case=use_parameters(cases)):
	var run = func(seed, private, public):
		var kp = GDSodiumKeyExchange.generate_keypair(seed)
		assert_eq(kp.private_key, private)
		assert_eq(kp.public_key, public)
		assert_incorrect_length(
			func(a): return GDSodiumKeyExchange.generate_keypair(a),
			seed
		)
	run.call(case.client_seed, case.client_private, case.client_public)
	run.call(case.server_seed, case.server_private, case.server_public)

func test_keypairs(case=use_parameters(cases)):
	var run = func(d):
		var client_keys = GDSodiumKeyPair.create(d.cpk, d.csk)
		var client = GDSodiumKeyExchange.client_session_keys(client_keys, d.spk)
		var server_keys = GDSodiumKeyPair.create(d.spk, d.ssk)
		var server = GDSodiumKeyExchange.server_session_keys(server_keys, d.cpk)
		return (
				client.receive == server.transmit
			and client.receive == d.crx
			and server.transmit == d.stx
			and client.transmit == server.receive
			and server.receive == d.srx
			and client.transmit == d.ctx
		)
	var args = {
		cpk = case.client_public, csk = case.client_private,
		crx = case.client_rx, ctx = case.client_tx,
		spk = case.server_public, ssk = case.server_private,
		srx = case.server_rx, stx = case.server_tx,
	}
	assert_true(run.call(args))
	assert_many_false(run, args)

func shortest(a):
	if len(a) == 0:
		return null
	var s = a[0]
	for i in a:
		if s.size() > i.size():
			s = i
	return s

func test_keypair_len(case=use_parameters(cases)):
	var run = func(d):
		var client_keys = GDSodiumKeyPair.create(d.cpk, d.csk)
		var client = GDSodiumKeyExchange.client_session_keys(client_keys, d.spk)
		var server_keys = GDSodiumKeyPair.create(d.spk, d.ssk)
		var server = GDSodiumKeyExchange.server_session_keys(server_keys, d.cpk)
		return shortest([
			client.receive, client.transmit,
			server.receive, server.transmit
		])
	var args = {
		cpk = case.client_public, csk = case.client_private,
		spk = case.server_public, ssk = case.server_private,
	}
	assert_many_empty(run, args)

class Case extends BaseCase:
	var client_seed
	var client_private
	var client_public
	var client_rx
	var client_tx

	var server_seed
	var server_private
	var server_public
	var server_rx
	var server_tx

	func randomize_properties():
		client_seed = rand_bytes(GDSodiumKeyExchange.SEED_BYTES)
		var ckp = GDSodiumKeyExchange.generate_keypair(client_seed)
		client_private = ckp.private_key
		client_public = ckp.public_key
		server_seed = rand_bytes(GDSodiumKeyExchange.SEED_BYTES)
		var skp = GDSodiumKeyExchange.generate_keypair(server_seed)
		server_private = skp.private_key
		server_public = skp.public_key
		
		var cdk = GDSodiumKeyExchange.client_session_keys(ckp, server_public)
		client_rx = cdk.receive
		client_tx = cdk.transmit
		
		var sdk = GDSodiumKeyExchange.server_session_keys(skp, client_public)
		server_rx = sdk.receive
		server_tx = sdk.transmit
