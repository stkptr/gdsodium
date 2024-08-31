#include "gdsodium.h"
#define SODIUM_STATIC
#include <sodium.h>

using namespace gdsodium;

void GDSodium::_bind_methods() {
	ClassDB::bind_static_method(
		"GDSodium",
		D_METHOD("argon2id_hash",
			"secret", "salt", "operations", "memory", "output_size"),
		&GDSodium::argon2id_hash
	);
}

GDSodium::GDSodium() {}

GDSodium::~GDSodium() {}


PackedByteArray GDSodium::argon2id_hash(
	const PackedByteArray &secret,
	const PackedByteArray &salt,
	uint64_t operations,
	uint64_t memory,
	uint32_t output_size
) {
	PackedByteArray out{};
	out.resize(output_size);

	if (salt.size() != 16) {
		return PackedByteArray();
	}

	if (crypto_pwhash(
		out.ptrw(), output_size,
		reinterpret_cast<const char*>(secret.ptr()), secret.size(),
		salt.ptr(),
		operations, memory,
		crypto_pwhash_ALG_ARGON2ID13
	) != 0) {
		return PackedByteArray(); // GCOV_EXCL_LINE
	}

	return out;
}
