#ifndef GDSODIUM_AEAD_H
#define GDSODIUM_AEAD_H

#include "gdsodium_common.h"
#include <sodium.h>

#define KEYGEN(sym) static Bytes sym ## _keygen();

#define ENCRYPT(sym) static Bytes \
    sym ## _encrypt( \
		const Bytes &message, \
		const Bytes &key, \
		const Bytes &nonce, \
		const Bytes &associated_data \
	);

#define DECRYPT(sym) static Ref<GDSodiumValidatedMessage> \
    sym ## _decrypt( \
		const Bytes &tagged_message, \
		const Bytes &key, \
		const Bytes &nonce, \
		const Bytes &associated_data \
	);

#define ENCRYPT_DETACHED(sym) static Ref<GDSodiumTaggedMessage> \
    sym ## _encrypt_detached( \
		const Bytes &message, \
		const Bytes &key, \
		const Bytes &nonce, \
		const Bytes &associated_data \
	);

#define DECRYPT_DETACHED(sym) static Ref<GDSodiumValidatedMessage> \
    sym ## _decrypt_detached( \
		const Bytes &message, \
		const Bytes &mac, \
		const Bytes &key, \
		const Bytes &nonce, \
		const Bytes &associated_data \
	);

#define SUITE(sym) \
    KEYGEN(sym); \
    ENCRYPT(sym); \
    DECRYPT(sym); \
    ENCRYPT_DETACHED(sym); \
    DECRYPT_DETACHED(sym);

namespace gdsodium {

class GDSodiumAEAD : public RefCounted {
	GDCLASS(GDSodiumAEAD, RefCounted) // GCOV_EXCL_LINE

protected:
	static void _bind_methods();

public:
	GDSodiumAEAD() {} // GCOV_EXCL_LINE
	~GDSodiumAEAD() {} // GCOV_EXCL_LINE

    SUITE(chacha20_poly1305);
    SUITE(chacha20_poly1305_ietf);
    SUITE(xchacha20_poly1305_ietf);

    SUITE(aegis256);

    SUITE(aegis128l);

    SUITE(aes256gcm);
    // AES256 GCM precomputation
};

}

#undef KEYGEN
#undef ENCRYPT
#undef DECRYPT
#undef ENCRYPT_DETACHED
#undef DECRYPT_DETACHED
#undef SUITE

#endif // GDSODIUM_AEAD_H
