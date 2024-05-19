#include "hkdf.h"
#include <sodium.h>

using namespace gdsodium;

void _bind_methods();

Bytes GDSodiumHKDF::generate_key(
	const Bytes &seed
) {
    Bytes prk{};
    prk.resize(crypto_kdf_hkdf_sha256_KEYBYTES);
    crypto_kdf_hkdf_sha256_keygen(prk.ptrw());
    return prk;
}

bool GDSodiumHKDF::update(
    const Bytes &ikm
) {
    return 0 == crypto_kdf_hkdf_sha256_extract_update(
        &state,
        ikm.ptr(), ikm.size()
    );
}

Bytes GDSodiumHKDF::finalize() {
    Bytes prk{};
    prk.resize(crypto_kdf_hkdf_sha256_KEYBYTES);

    if (crypto_kdf_hkdf_sha256_extract_final(
        &state,
        prk.ptrw()
    ) != 0) {
        return Bytes();
    }

    return prk;
}

Bytes GDSodiumHKDF::extract(
    const Bytes &salt,
    const Bytes &ikm
) {
    Bytes prk{};
    prk.resize(crypto_kdf_hkdf_sha256_KEYBYTES);

    if (crypto_kdf_hkdf_sha256_extract(
        prk.ptrw(),
        salt.ptr(), salt.size(),
        ikm.ptr(), ikm.size()
    ) != 0) {
        return Bytes();
    }

    return prk;
}

Bytes GDSodiumHKDF::expand(
    const Bytes &key,
    const Bytes &context,
    unsigned int amount
) {
    if (amount > crypto_kdf_hkdf_sha256_BYTES_MAX) {
        return Bytes();
    }

    Bytes out{};
    out.resize(amount);

    if (crypto_kdf_hkdf_sha256_expand(
        out.ptrw(), out.size(),
        reinterpret_cast<const char*>(context.ptr()), context.size(),
        key.ptr()
    ) != 0) {
        return Bytes();
    }

    return out;
}
