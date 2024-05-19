#ifndef GDSODIUM_HKDF_H
#define GDSODIUM_HKDF_H

#include "gdsodium_common.h"
#include <sodium.h>

namespace gdsodium {

class GDSodiumHKDF : public RefCounted {
	GDCLASS(GDSodiumHKDF, RefCounted) // GCOV_EXCL_LINE

	crypto_kdf_hkdf_sha256_state state;
	bool initialized = false;

protected:
	static void _bind_methods();

public:
	GDSodiumHKDF() {} // GCOV_EXCL_LINE
	~GDSodiumHKDF() {} // GCOV_EXCL_LINE

	void start() {
		if (crypto_kdf_hkdf_sha256_extract_init(&state, NULL, 0) == 0) {
		    initialized = true;
		}
	}

	static Ref<GDSodiumHKDF> extract_init() {
		Ref<GDSodiumHKDF> obj = memnew(GDSodiumHKDF());
		obj->start();
		return obj;
    }

	static Ref<GDSodiumHKDF> create() {
	    return extract_init();
	}

	static Bytes generate_key();

    bool update(
        const Bytes &ikm
    );

    Bytes finalize();

    static Bytes extract(
        const Bytes &salt,
        const Bytes &ikm
    );

    static Bytes expand(
        const Bytes &key,
        const Bytes &context,
        unsigned int amount
    );
};

}

#endif // GDSODIUM_HKDF_H
