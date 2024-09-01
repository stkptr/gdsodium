#ifndef GDSODIUM_KEY_DERIVATION_H
#define GDSODIUM_KEY_DERIVATION_H

#include "gdsodium_common.h"
#include <sodium.h>

namespace gdsodium {

class GDSodiumKeyDerivation : public RefCounted {
	GDCLASS(GDSodiumKeyDerivation, RefCounted) // GCOV_EXCL_LINE

protected:
	static void _bind_methods();

public:
	GDSodiumKeyDerivation() {} // GCOV_EXCL_LINE
	~GDSodiumKeyDerivation() {} // GCOV_EXCL_LINE

	static Bytes argon2i(
		const Bytes &secret,
		const Bytes &salt,
		uint64_t operations,
		uint64_t memory,
		uint32_t output_size
	);

	static Bytes argon2id(
		const Bytes &secret,
		const Bytes &salt,
		uint64_t operations,
		uint64_t memory,
		uint32_t output_size
	);

	static String argon2id_str(
	    const Bytes &secret,
		uint64_t operations,
		uint64_t memory
	);

	static bool argon2id_str_verify(
	    const String &hashed_password,
	    const Bytes &secret
	);

	static bool argon2id_str_needs_rehash(
	    const String &hashed_password,
		uint64_t operations,
		uint64_t memory
	);

    static Bytes scrypt_salsa208_sha256(
        const Bytes &secret,
        const Bytes &salt,
		uint64_t operations,
		uint64_t memory,
		uint32_t output_size
    );

	static String scrypt_salsa208_sha256_str(
	    const Bytes &secret,
		uint64_t operations,
		uint64_t memory
	);

	static bool scrypt_salsa208_sha256_str_verify(
	    const String &hashed_password,
	    const Bytes &secret
	);

    static Bytes scrypt_salsa208_sha256_ll(
        const Bytes &secret,
        const Bytes &salt,
		uint64_t N,
		uint32_t r,
		uint32_t p,
		uint32_t output_size
    );
};

}

#endif // GDSODIUM_KEY_DERIVATION_H
