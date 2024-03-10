#include "gdsodium.h"
#include <godot_cpp/core/class_db.hpp>
#define SODIUM_STATIC
#include <sodium.h>

using namespace godot;

void GDSodium::_bind_methods() {
    ClassDB::bind_static_method(
        "GDSodium",
        D_METHOD("chacha20_poly1305_ietf_encrypt_detached",
            "message", "key", "nonce", "associated_data"),
        &GDSodium::chacha20_poly1305_ietf_encrypt_detached
    );
    ClassDB::bind_static_method(
        "GDSodium",
        D_METHOD("chacha20_poly1305_ietf_decrypt_detached",
            "ciphertext", "key", "nonce", "associated_data", "mac"),
        &GDSodium::chacha20_poly1305_ietf_decrypt_detached
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


Array GDSodium::chacha20_poly1305_ietf_encrypt_detached(
    PackedByteArray message,
    PackedByteArray key,
    PackedByteArray nonce,
    PackedByteArray associated_data
) {
    PackedByteArray ciphertext{};
    PackedByteArray mac{};
    
    ciphertext.resize(message.size());
    mac.resize(16);
    
    unsigned long long mlen;
    
    if (nonce.size() != 12 || key.size() != 32) {
        return Array();
    }

    if (crypto_aead_chacha20poly1305_ietf_encrypt_detached(
        ciphertext.ptrw(),
        mac.ptrw(), &mlen,
        message.ptr(), message.size(),
        associated_data.ptr(), associated_data.size(),
        NULL, nonce.ptr(),
        key.ptr()
    ) != 0) {
        return Array();
    }
    
    if (mlen != 16) {
        return Array();
    }
    
    Array output{};
    output.push_back(Variant(ciphertext));
    output.push_back(Variant(mac));
    return output;
}

PackedByteArray GDSodium::chacha20_poly1305_ietf_decrypt_detached(
    PackedByteArray message,
    PackedByteArray key,
    PackedByteArray nonce,
    PackedByteArray associated_data,
    PackedByteArray mac
) {
    PackedByteArray plaintext{};
    plaintext.resize(message.size());
    
    if (nonce.size() != 12 || key.size() != 32) {
        return PackedByteArray();
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
        return PackedByteArray();
    }

    return plaintext;
}


PackedByteArray GDSodium::argon2id_hash(
    PackedByteArray secret,
    PackedByteArray salt,
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


