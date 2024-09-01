#include "key_derivation.h"
#include <sodium.h>

using namespace gdsodium;

void GDSodiumKeyDerivation::_bind_methods() {
	BIND_STATIC(GDSodiumKeyDerivation, argon2i,
	    "secret", "salt", "operations", "memory", "output_size");
	BIND_STATIC(GDSodiumKeyDerivation, argon2id,
	    "secret", "salt", "operations", "memory", "output_size");
	BIND_STATIC(GDSodiumKeyDerivation, scrypt_salsa208_sha256,
	    "secret", "salt", "operations", "memory", "output_size");
	BIND_STATIC(GDSodiumKeyDerivation, argon2id_str,
	    "secret", "operations", "memory");
	BIND_STATIC(GDSodiumKeyDerivation, argon2id_str_verify,
	    "hashed_password", "secret");
	BIND_STATIC(GDSodiumKeyDerivation, argon2id_str_needs_rehash,
	    "hashed_password", "operations", "memory");
	BIND_STATIC(GDSodiumKeyDerivation, scrypt_salsa208_sha256_str,
	    "secret", "operations", "memory");
	BIND_STATIC(GDSodiumKeyDerivation, scrypt_salsa208_sha256_str_verify,
	    "hashed_password", "secret");
	BIND_STATIC(GDSodiumKeyDerivation, scrypt_salsa208_sha256_ll,
	    "secret", "salt", "N", "r", "p", "output_size");
	BIND_CONSTANT_AS(crypto_pwhash_SALTBYTES, "ARGON2_SALT_BYTES");
	BIND_CONSTANT_AS(crypto_pwhash_SALTBYTES, "ARGON2I_SALT_BYTES");
	BIND_CONSTANT_AS(crypto_pwhash_SALTBYTES, "ARGON2ID_SALT_BYTES");
	BIND_CONSTANT_AS(crypto_pwhash_scryptsalsa208sha256_SALTBYTES,
	    "SCRYPT_SALSA208_SHA256_SALT_BYTES");
}

Bytes GDSodiumKeyDerivation::argon2i(
	const Bytes &secret,
	const Bytes &salt,
	uint64_t operations,
	uint64_t memory,
	uint32_t output_size
) {
	Bytes out{};
	out.resize(output_size);

	if (salt.size() != crypto_pwhash_SALTBYTES) {
		return Bytes();
	}

	if (crypto_pwhash(
		out.ptrw(), output_size,
		reinterpret_cast<const char*>(secret.ptr()), secret.size(),
		salt.ptr(),
		operations, memory,
		crypto_pwhash_ALG_ARGON2I13
	) != 0) {
		return Bytes(); // GCOV_EXCL_LINE
	}

	return out;
}

Bytes GDSodiumKeyDerivation::argon2id(
	const Bytes &secret,
	const Bytes &salt,
	uint64_t operations,
	uint64_t memory,
	uint32_t output_size
) {
	Bytes out{};
	out.resize(output_size);

	if (salt.size() != crypto_pwhash_SALTBYTES) {
		return Bytes();
	}

	if (crypto_pwhash(
		out.ptrw(), output_size,
		reinterpret_cast<const char*>(secret.ptr()), secret.size(),
		salt.ptr(),
		operations, memory,
		crypto_pwhash_ALG_ARGON2ID13
	) != 0) {
		return Bytes(); // GCOV_EXCL_LINE
	}

	return out;
}

String GDSodiumKeyDerivation::argon2id_str(
	const Bytes &secret,
	uint64_t operations,
	uint64_t memory
) {
	char out[crypto_pwhash_STRBYTES];

	if (crypto_pwhash_str(
		out,
		reinterpret_cast<const char*>(secret.ptr()), secret.size(),
		operations, memory
	) != 0) {
		return ""; // GCOV_EXCL_LINE
	}

	return String(out);
}

bool GDSodiumKeyDerivation::argon2id_str_verify(
    const String &hashed_password,
    const Bytes &secret
) {
    Bytes hashed = hashed_password.to_ascii_buffer();
    hashed.resize(hashed.size() + 1);

	return crypto_pwhash_str_verify(
		reinterpret_cast<const char*>(hashed.ptr()),
		reinterpret_cast<const char*>(secret.ptr()), secret.size()
	) == 0;
}

bool GDSodiumKeyDerivation::argon2id_str_needs_rehash(
    const String &hashed_password,
	uint64_t operations,
	uint64_t memory
) {
    Bytes hashed = hashed_password.to_ascii_buffer();
    hashed.resize(hashed.size() + 1);

	return crypto_pwhash_str_needs_rehash(
		reinterpret_cast<const char*>(hashed.ptr()),
		operations, memory
	) == 0;
}

Bytes GDSodiumKeyDerivation::scrypt_salsa208_sha256(
	const Bytes &secret,
	const Bytes &salt,
	uint64_t operations,
	uint64_t memory,
	uint32_t output_size
) {
	Bytes out{};
	out.resize(output_size);

	if (salt.size() != crypto_pwhash_scryptsalsa208sha256_SALTBYTES) {
		return Bytes();
	}

	if (crypto_pwhash_scryptsalsa208sha256(
		out.ptrw(), output_size,
		reinterpret_cast<const char*>(secret.ptr()), secret.size(),
		salt.ptr(),
		operations, memory
	) != 0) {
		return Bytes(); // GCOV_EXCL_LINE
	}

	return out;
}

String GDSodiumKeyDerivation::scrypt_salsa208_sha256_str(
	const Bytes &secret,
	uint64_t operations,
	uint64_t memory
) {
	char out[crypto_pwhash_STRBYTES];

	if (crypto_pwhash_scryptsalsa208sha256_str(
		out,
		reinterpret_cast<const char*>(secret.ptr()), secret.size(),
		operations, memory
	) != 0) {
		return ""; // GCOV_EXCL_LINE
	}

	return String(out);
}

bool GDSodiumKeyDerivation::scrypt_salsa208_sha256_str_verify(
    const String &hashed_password,
    const Bytes &secret
) {
    Bytes hashed = hashed_password.to_ascii_buffer();
    hashed.resize(hashed.size() + 1);

	return crypto_pwhash_scryptsalsa208sha256_str_verify(
		reinterpret_cast<const char*>(hashed.ptr()),
		reinterpret_cast<const char*>(secret.ptr()), secret.size()
	) == 0;
}

Bytes GDSodiumKeyDerivation::scrypt_salsa208_sha256_ll(
	const Bytes &secret,
	const Bytes &salt,
	uint64_t N,
	uint32_t r,
	uint32_t p,
	uint32_t output_size
) {
	Bytes out{};
	out.resize(output_size);

	if (crypto_pwhash_scryptsalsa208sha256_ll(
		secret.ptr(), secret.size(),
		salt.ptr(), salt.size(),
		N, r, p,
		out.ptrw(), output_size
	) != 0) {
		return Bytes(); // GCOV_EXCL_LINE
	}

	return out;
}

