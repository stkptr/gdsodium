#include "gdsodium.h"
#define SODIUM_STATIC
#include <sodium.h>

using namespace gdsodium;

void GDSodium::_bind_methods() {
    ClassDB::bind_static_method(
        "GDSodium",
        D_METHOD("chacha20_poly1305_ietf_encrypt_detached",
            "message", "key", "nonce", "associated_data"),
        &GDSodium::chacha20_poly1305_ietf_encrypt_detached,
        DEFVAL(PackedByteArray())
    );
    ClassDB::bind_static_method(
        "GDSodium",
        D_METHOD("chacha20_poly1305_ietf_decrypt_detached",
            "ciphertext", "mac", "key", "nonce", "associated_data"),
        &GDSodium::chacha20_poly1305_ietf_decrypt_detached,
        DEFVAL(PackedByteArray())
    );
    ClassDB::bind_static_method(
        "GDSodium",
        D_METHOD("argon2id_hash",
            "secret", "salt", "operations", "memory", "output_size"),
        &GDSodium::argon2id_hash
    );
}

GDSodium::GDSodium() {}

GDSodium::~GDSodium() {}


Ref<GDSodiumTaggedMessage> GDSodium::chacha20_poly1305_ietf_encrypt_detached(
    const PackedByteArray &message,
    const PackedByteArray &key,
    const PackedByteArray &nonce,
    const PackedByteArray &associated_data
) {
    PackedByteArray ciphertext{};
    PackedByteArray mac{};
    
    ciphertext.resize(message.size());
    mac.resize(16);
    
    unsigned long long mlen;
    
    if (nonce.size() != 12 || key.size() != 32) {
        return EMPTY(GDSodiumTaggedMessage);
    }

    if (crypto_aead_chacha20poly1305_ietf_encrypt_detached(
        ciphertext.ptrw(),
        mac.ptrw(), &mlen,
        message.ptr(), message.size(),
        associated_data.ptr(), associated_data.size(),
        NULL, nonce.ptr(),
        key.ptr()
    ) != 0) {
        return EMPTY(GDSodiumTaggedMessage);
    }
    
    if (mlen != 16) {
        return EMPTY(GDSodiumTaggedMessage);
    }

    return memnew(GDSodiumTaggedMessage(ciphertext, mac));
}

Ref<GDSodiumValidatedMessage> GDSodium::chacha20_poly1305_ietf_decrypt_detached(
    const PackedByteArray &message,
    const PackedByteArray &mac,
    const PackedByteArray &key,
    const PackedByteArray &nonce,
    const PackedByteArray &associated_data
) {
    PackedByteArray plaintext{};
    plaintext.resize(message.size());
    
    if (nonce.size() != 12 || key.size() != 32) {
        return EMPTY(GDSodiumValidatedMessage);
    }
    
    if (crypto_aead_chacha20poly1305_ietf_decrypt_detached(
        plaintext.ptrw(),
        NULL,
        message.ptr(), message.size(),
        mac.ptr(),
        associated_data.ptr(), associated_data.size(),
        nonce.ptr(),
        key.ptr()
    ) != 0) {
        return EMPTY(GDSodiumValidatedMessage);
    }

    return memnew(GDSodiumValidatedMessage(plaintext, true));
}


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
        return PackedByteArray();
    }

    return out;
}
