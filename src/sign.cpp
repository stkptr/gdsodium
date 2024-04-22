#include "sign.h"

using namespace gdsodium;

void GDSodiumSign::_bind_methods() {
	BIND_METHOD(GDSodiumSign, start);
	BIND_STATIC(GDSodiumSign, create);
	ClassDB::bind_static_method(
		"GDSodiumSign",
		D_METHOD("generate_keypair", "seed"),
		&GDSodiumSign::generate_keypair,
		DEFVAL(PackedByteArray())
	);
	BIND_STATIC(GDSodiumSign, private_key_to_seed,
		"private_key");
	BIND_STATIC(GDSodiumSign, private_key_to_public_key,
		"private_key");
	BIND_STATIC(GDSodiumSign, sign,
		"message", "private_key");
	BIND_STATIC(GDSodiumSign, sign_detached,
		"message", "private_key");
	BIND_STATIC(GDSodiumSign, open,
		"signed_message", "public_key");
	BIND_STATIC(GDSodiumSign, verify_detached,
		"message", "signature", "public_key");
	BIND_METHOD(GDSodiumSign, update,
		"data"
	);
	BIND_METHOD(GDSodiumSign, final_sign,
		"private_key"
	);
	BIND_METHOD(GDSodiumSign, final_verify,
		"signature", "public_key"
	);
	BIND_CONSTANT_AS(crypto_sign_BYTES, "SIGNATURE_BYTES");
	BIND_CONSTANT_AS(crypto_sign_PUBLICKEYBYTES, "PUBLIC_KEY_BYTES");
	BIND_CONSTANT_AS(crypto_sign_SECRETKEYBYTES, "PRIVATE_KEY_BYTES");
	BIND_CONSTANT_AS(crypto_sign_SEEDBYTES, "SEED_BYTES");
}


GENERATE_KEYPAIR(GDSodiumSign, crypto_sign);


Bytes GDSodiumSign::private_key_to_seed(
	const Bytes &private_key
) {
	Bytes seed{};
	seed.resize(crypto_sign_SEEDBYTES);

	if (private_key.size() != crypto_sign_SECRETKEYBYTES) {
		return Bytes();
	}

	if (crypto_sign_ed25519_sk_to_seed(
		seed.ptrw(), private_key.ptr()
	) != 0) {
		return Bytes(); // GCOV_EXCL_LINE
	}

	return seed;
}


Bytes GDSodiumSign::private_key_to_public_key(
	const Bytes &private_key
) {
	Bytes public_key{};
	public_key.resize(crypto_sign_PUBLICKEYBYTES);

	if (private_key.size() != crypto_sign_SECRETKEYBYTES) {
		return Bytes();
	}

	if (crypto_sign_ed25519_sk_to_pk(
		public_key.ptrw(), private_key.ptr()
	) != 0) {
		return Bytes(); // GCOV_EXCL_LINE
	}

	return public_key;
}


Bytes GDSodiumSign::sign(
	const Bytes &message,
	const Bytes &private_key
) {
	Bytes out{};
	out.resize(message.size() + crypto_sign_BYTES);

	if (private_key.size() != crypto_sign_SECRETKEYBYTES) {
		return Bytes();
	}

	if (crypto_sign(
		out.ptrw(), NULL,
		message.ptr(), message.size(),
		private_key.ptr()
	) != 0) {
		return Bytes(); // GCOV_EXCL_LINE
	}

	return out;
}


Bytes GDSodiumSign::sign_detached(
	const Bytes &message,
	const Bytes &private_key
) {
	Bytes signature{};
	signature.resize(crypto_sign_BYTES);

	if (private_key.size() != crypto_sign_SECRETKEYBYTES) {
		return Bytes();
	}

	if (crypto_sign_detached(
		signature.ptrw(), NULL,
		message.ptr(), message.size(),
		private_key.ptr()
	) != 0) {
		return Bytes(); // GCOV_EXCL_LINE
	}

	return signature;
}


Ref<GDSodiumValidatedMessage> GDSodiumSign::open(
	const Bytes &signed_message,
	const Bytes &public_key
) {
	Bytes message{};
	message.resize(signed_message.size() - crypto_sign_BYTES);

	if (public_key.size() != crypto_sign_PUBLICKEYBYTES) {
		return EMPTY(GDSodiumValidatedMessage);
	}

	if (crypto_sign_open(
		message.ptrw(), NULL,
		signed_message.ptr(), signed_message.size(),
		public_key.ptr()
	) != 0) {
		return EMPTY(GDSodiumValidatedMessage); // GCOV_EXCL_LINE
	}

	return memnew(GDSodiumValidatedMessage(message, true));
}


bool GDSodiumSign::verify_detached(
	const Bytes &message,
	const Bytes &signature,
	const Bytes &public_key
) {
	if (public_key.size() != crypto_sign_PUBLICKEYBYTES
		|| signature.size() != crypto_sign_BYTES
	) {
		return false;
	}

	return 0 == crypto_sign_verify_detached(
		signature.ptr(),
		message.ptr(), message.size(),
		public_key.ptr()
	);
}


bool GDSodiumSign::update(
	const Bytes &data
) {
	if (!initialized) {
		return false;
	}

	crypto_sign_update(&state, data.ptr(), data.size());
	return true;
}


Bytes GDSodiumSign::final_sign(
	const Bytes &private_key
) {

	Bytes signature{};
	signature.resize(crypto_sign_BYTES);

	if (!initialized
		|| private_key.size() != crypto_sign_SECRETKEYBYTES
	) {
		return Bytes();
	}

	if (crypto_sign_final_create(
		&state,
		signature.ptrw(), NULL,
		private_key.ptr()
	) != 0) {
		return Bytes(); // GCOV_EXCL_LINE
	}

	return signature;
}


bool GDSodiumSign::final_verify(
	const Bytes &signature,
	const Bytes &public_key
) {
	if (!initialized
		|| public_key.size() != crypto_sign_PUBLICKEYBYTES
		|| signature.size() != crypto_sign_BYTES
	) {
		return false;
	}

	return 0 == crypto_sign_final_verify(
		&state,
		signature.ptr(),
		public_key.ptr()
	);
}
