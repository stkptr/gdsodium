#include "aead.h"
#include <sodium.h>

using namespace gdsodium;


#define BIND_KEYGEN(sym) \
	ClassDB::bind_static_method( \
		"GDSodiumAEAD", \
		D_METHOD(#sym "_keygen"), \
		&GDSodiumAEAD::sym ## _keygen \
	);

#define BIND_ENCRYPT(sym) \
	ClassDB::bind_static_method( \
		"GDSodiumAEAD", \
		D_METHOD(#sym "_encrypt", \
			"message", "key", "nonce", "associated_data"), \
		&GDSodiumAEAD::sym ## _encrypt, \
		DEFVAL(PackedByteArray()) \
	);

#define BIND_DECRYPT(sym) \
	ClassDB::bind_static_method( \
		"GDSodiumAEAD", \
		D_METHOD(#sym "_decrypt", \
			"tagged_ciphertext", "key", "nonce", "associated_data"), \
		&GDSodiumAEAD::sym ## _decrypt, \
		DEFVAL(PackedByteArray()) \
	);

#define BIND_ENCRYPT_DETACHED(sym) \
	ClassDB::bind_static_method( \
		"GDSodiumAEAD", \
		D_METHOD(#sym "_encrypt_detached", \
			"message", "key", "nonce", "associated_data"), \
		&GDSodiumAEAD::sym ## _encrypt_detached, \
		DEFVAL(PackedByteArray()) \
	);

#define BIND_DECRYPT_DETACHED(sym) \
	ClassDB::bind_static_method( \
		"GDSodiumAEAD", \
		D_METHOD(#sym "_decrypt_detached", \
			"ciphertext", "mac", "key", "nonce", "associated_data"), \
		&GDSodiumAEAD::sym ## _decrypt_detached, \
		DEFVAL(PackedByteArray()) \
	);

#define BIND_SUITE(sym) \
    BIND_KEYGEN(sym); \
    BIND_ENCRYPT(sym); \
    BIND_DECRYPT(sym); \
    BIND_ENCRYPT_DETACHED(sym); \
    BIND_DECRYPT_DETACHED(sym);

#define BIND_SUITE_MACRO(sym, capsym, func) \
    BIND_SUITE(sym); \
	BIND_CONSTANT_AS(crypto_aead_ ## func ## _KEYBYTES, #capsym "_KEY_BYTES"); \
	BIND_CONSTANT_AS(crypto_aead_ ## func ## _ABYTES, #capsym "_MAC_BYTES"); \
	BIND_CONSTANT_AS(crypto_aead_ ## func ## _NPUBBYTES, #capsym "_NONCE_BYTES");


void GDSodiumAEAD::_bind_methods() {
    BIND_SUITE_MACRO(chacha20_poly1305,
        CHACHA20_POLY1305, chacha20poly1305);
    BIND_SUITE_MACRO(chacha20_poly1305_ietf,
        CHACHA20_POLY1305_IETF, chacha20poly1305_ietf);
    BIND_SUITE_MACRO(xchacha20_poly1305_ietf,
        XCHACHA20_POLY305_IETF, xchacha20poly1305_ietf);

    BIND_SUITE_MACRO(aegis256, AEGIS256, aegis256);

    BIND_SUITE_MACRO(aegis128l, AEGIS128L, aegis128l);

    BIND_SUITE_MACRO(aes256gcm, AES256GCM, aes256gcm);
}


#define KEYGEN(sym, func, key_size) \
    Bytes GDSodiumAEAD::sym ## _keygen() {\
	    PackedByteArray key{}; \
	    key.resize(key_size); \
	    crypto_aead_ ## func ## _keygen(key.ptrw()); \
	    return key; \
    }

#define ENCRYPT(sym, func, key_size, nonce_size, mac_size) \
    Bytes GDSodiumAEAD::sym ## _encrypt( \
	    const PackedByteArray &message, \
	    const PackedByteArray &key, \
	    const PackedByteArray &nonce, \
	    const PackedByteArray &associated_data \
    ) { \
	    PackedByteArray ciphertext{}; \
	    ciphertext.resize(message.size() + mac_size); \
	    unsigned long long clen; \
	    if (nonce.size() != nonce_size || key.size() != key_size) { \
		    return Bytes(); \
	    } \
	    if (crypto_aead_ ## func ## _encrypt( \
		    ciphertext.ptrw(), \
		    &clen, \
		    message.ptr(), message.size(), \
		    associated_data.ptr(), associated_data.size(), \
		    NULL, nonce.ptr(), \
		    key.ptr() \
	    ) != 0) { \
		    return Bytes(); \
	    } \
	    if (clen != message.size() + mac_size) { \
		    return Bytes(); \
	    } \
	    return ciphertext; \
    }

#define DECRYPT(sym, func, key_size, nonce_size, mac_size) \
    Ref<GDSodiumValidatedMessage> GDSodiumAEAD::sym ## _decrypt( \
	    const PackedByteArray &message, \
	    const PackedByteArray &key, \
	    const PackedByteArray &nonce, \
	    const PackedByteArray &associated_data \
    ) { \
	    PackedByteArray plaintext{}; \
	    plaintext.resize(message.size() - mac_size); \
	    unsigned long long mlen; \
	    if (nonce.size() != nonce_size || key.size() != key_size) { \
		    return EMPTY(GDSodiumValidatedMessage); \
	    } \
	    if (crypto_aead_ ## func ## _decrypt( \
		    plaintext.ptrw(), &mlen, \
		    NULL, \
		    message.ptr(), message.size(), \
		    associated_data.ptr(), associated_data.size(), \
		    nonce.ptr(), \
		    key.ptr() \
	    ) != 0) { \
		    return EMPTY(GDSodiumValidatedMessage); \
	    } \
	    if (mlen != message.size() - mac_size) { \
		    return EMPTY(GDSodiumValidatedMessage); \
	    } \
	    return memnew(GDSodiumValidatedMessage(plaintext, true)); \
    }

#define ENCRYPT_DETACHED(sym, func, key_size, nonce_size, mac_size) \
    Ref<GDSodiumTaggedMessage> GDSodiumAEAD::sym ## _encrypt_detached( \
	    const PackedByteArray &message, \
	    const PackedByteArray &key, \
	    const PackedByteArray &nonce, \
	    const PackedByteArray &associated_data \
    ) { \
	    PackedByteArray ciphertext{}; \
	    PackedByteArray mac{}; \
	    ciphertext.resize(message.size()); \
	    mac.resize(mac_size); \
	    unsigned long long mlen; \
	    if (nonce.size() != nonce_size || key.size() != key_size) { \
		    return EMPTY(GDSodiumTaggedMessage); \
	    } \
	    if (crypto_aead_ ## func ## _encrypt_detached( \
		    ciphertext.ptrw(), \
		    mac.ptrw(), &mlen, \
		    message.ptr(), message.size(), \
		    associated_data.ptr(), associated_data.size(), \
		    NULL, nonce.ptr(), \
		    key.ptr() \
	    ) != 0) { \
		    return EMPTY(GDSodiumTaggedMessage); \
	    } \
	    if (mlen != mac_size) { \
		    return EMPTY(GDSodiumTaggedMessage); \
	    } \
	    return memnew(GDSodiumTaggedMessage(ciphertext, mac)); \
    }

#define DECRYPT_DETACHED(sym, func, key_size, nonce_size, mac_size) \
    Ref<GDSodiumValidatedMessage> GDSodiumAEAD::sym ## _decrypt_detached( \
	    const PackedByteArray &message, \
	    const PackedByteArray &mac, \
	    const PackedByteArray &key, \
	    const PackedByteArray &nonce, \
	    const PackedByteArray &associated_data \
    ) { \
	    PackedByteArray plaintext{}; \
	    plaintext.resize(message.size()); \
	    if (nonce.size() != nonce_size || key.size() != key_size) { \
		    return EMPTY(GDSodiumValidatedMessage); \
	    } \
	    if (crypto_aead_ ## func ## _decrypt_detached( \
		    plaintext.ptrw(), \
		    NULL, \
		    message.ptr(), message.size(), \
		    mac.ptr(), \
		    associated_data.ptr(), associated_data.size(), \
		    nonce.ptr(), \
		    key.ptr() \
	    ) != 0) { \
		    return EMPTY(GDSodiumValidatedMessage); \
	    } \
	    return memnew(GDSodiumValidatedMessage(plaintext, true)); \
    }

#define SUITE(sym, func, key_size, nonce_size, mac_size) \
    KEYGEN(sym, func, key_size) \
    ENCRYPT(sym, func, key_size, nonce_size, mac_size) \
    DECRYPT(sym, func, key_size, nonce_size, mac_size) \
    ENCRYPT_DETACHED(sym, func, key_size, nonce_size, mac_size) \
    DECRYPT_DETACHED(sym, func, key_size, nonce_size, mac_size)

#define SUITE_MACRO(sym, func) \
    SUITE(sym, func, \
        crypto_aead_ ## func ## _KEYBYTES, \
        crypto_aead_ ## func ## _NPUBBYTES, \
        crypto_aead_ ## func ## _ABYTES \
    )

SUITE_MACRO(chacha20_poly1305, chacha20poly1305);
SUITE_MACRO(chacha20_poly1305_ietf, chacha20poly1305_ietf);
SUITE_MACRO(xchacha20_poly1305_ietf, xchacha20poly1305_ietf);

SUITE_MACRO(aegis256, aegis256);

SUITE_MACRO(aegis128l, aegis128l);

SUITE_MACRO(aes256gcm, aes256gcm);

