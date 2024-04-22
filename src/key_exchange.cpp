#include "key_exchange.h"
#include <sodium.h>

using namespace gdsodium;

void GDSodiumKeyExchange::_bind_methods() {
	ClassDB::bind_static_method(
		"GDSodiumKeyExchange",
		D_METHOD("generate_keypair", "seed"),
		&GDSodiumKeyExchange::generate_keypair,
		DEFVAL(PackedByteArray())
	);
	ClassDB::bind_static_method(
		"GDSodiumKeyExchange",
		D_METHOD("client_session_keys",
			"client_keys", "server_public_key"),
		&GDSodiumKeyExchange::client_session_keys
	);
	ClassDB::bind_static_method(
		"GDSodiumKeyExchange",
		D_METHOD("server_session_keys",
			"server_keys", "client_public_key"),
		&GDSodiumKeyExchange::server_session_keys
	);
	BIND_CONSTANT_AS(crypto_kx_PUBLICKEYBYTES, "PUBLIC_KEY_BYTES");
	BIND_CONSTANT_AS(crypto_kx_SECRETKEYBYTES, "PRIVATE_KEY_BYTES");
	BIND_CONSTANT_AS(crypto_kx_SEEDBYTES, "SEED_BYTES");
	BIND_CONSTANT_AS(crypto_kx_SESSIONKEYBYTES, "SESSION_KEY_BYTES");
}


GENERATE_KEYPAIR(GDSodiumKeyExchange, crypto_kx);


Ref<GDSodiumDirectionalKeys> GDSodiumKeyExchange::client_session_keys(
	Ref<GDSodiumKeyPair> client_keys,
	const PackedByteArray &server_public_key
) {
	PackedByteArray receive{};
	PackedByteArray transmit{};

	if (client_keys->public_key.size() != crypto_kx_PUBLICKEYBYTES
		|| client_keys->private_key.size() != crypto_kx_SECRETKEYBYTES
		|| server_public_key.size() != crypto_kx_PUBLICKEYBYTES
	) {
		return EMPTY(GDSodiumDirectionalKeys);
	}

	receive.resize(crypto_kx_SESSIONKEYBYTES);
	transmit.resize(crypto_kx_SESSIONKEYBYTES);

	if (crypto_kx_client_session_keys(
		receive.ptrw(),
		transmit.ptrw(),
		client_keys->public_key.ptr(),
		client_keys->private_key.ptr(),
		server_public_key.ptr()
	) != 0) {
		return EMPTY(GDSodiumDirectionalKeys); // GCOV_EXCL_LINE
	}

	return memnew(GDSodiumDirectionalKeys(receive, transmit));
}


Ref<GDSodiumDirectionalKeys> GDSodiumKeyExchange::server_session_keys(
	Ref<GDSodiumKeyPair> server_keys,
	const PackedByteArray &client_public_key
) {
	PackedByteArray receive{};
	PackedByteArray transmit{};

	if (server_keys->public_key.size() != crypto_kx_PUBLICKEYBYTES
		|| server_keys->private_key.size() != crypto_kx_SECRETKEYBYTES
		|| client_public_key.size() != crypto_kx_PUBLICKEYBYTES
	) {
		return EMPTY(GDSodiumDirectionalKeys);
	}

	receive.resize(crypto_kx_SESSIONKEYBYTES);
	transmit.resize(crypto_kx_SESSIONKEYBYTES);

	if (crypto_kx_server_session_keys(
		receive.ptrw(),
		transmit.ptrw(),
		server_keys->public_key.ptr(),
		server_keys->private_key.ptr(),
		client_public_key.ptr()
	) != 0) {
		return EMPTY(GDSodiumDirectionalKeys); // GCOV_EXCL_LINE
	}

	return memnew(GDSodiumDirectionalKeys(receive, transmit));
}
