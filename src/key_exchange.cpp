#include "key_exchange.h"
#include <godot_cpp/core/class_db.hpp>
#define SODIUM_STATIC
#include <sodium.h>

using namespace godot;

void GDSodiumKeyExchange::_bind_methods() {
    ClassDB::bind_static_method(
        "GDSodiumKeyExchange",
        D_METHOD("generate_keypair", "seed"),
        &GDSodiumKeyExchange::generate_keypair,
        DEFVAL(PackedByteArray())
    );
    ClassDB::bind_static_method(
        "GDSodiumKeyExchange",
        D_METHOD("client_session_keys",
            "client_keys", "server_public_key"),
        &GDSodiumKeyExchange::client_session_keys
    );
    ClassDB::bind_static_method(
        "GDSodiumKeyExchange",
        D_METHOD("server_session_keys",
            "server_keys", "client_public_key"),
        &GDSodiumKeyExchange::server_session_keys
    );
    BIND_CONSTANT_AS(crypto_kx_PUBLICKEYBYTES, "PUBLIC_KEY_BYTES");
    BIND_CONSTANT_AS(crypto_kx_SECRETKEYBYTES, "SECRET_KEY_BYTES");
    BIND_CONSTANT_AS(crypto_kx_SEEDBYTES, "SEED_BYTES");
    BIND_CONSTANT_AS(crypto_kx_SESSIONKEYBYTES, "SESSION_KEY_BYTES");
}


Ref<GDSodiumKeyPair> GDSodiumKeyExchange::generate_keypair(
    const PackedByteArray &seed
) {
    PackedByteArray public_key{};
    PackedByteArray private_key{};

    public_key.resize(crypto_kx_PUBLICKEYBYTES);
    private_key.resize(crypto_kx_SECRETKEYBYTES);

    if (seed.size() == crypto_kx_SEEDBYTES) {
        crypto_kx_seed_keypair(
            public_key.ptrw(),
            private_key.ptrw(),
            seed.ptr()
        );
    } else if (seed.size() == 0) {
        crypto_kx_keypair(
            public_key.ptrw(),
            private_key.ptrw()
        );
    } else {
        return memnew(GDSodiumKeyPair());
    }

    return memnew(GDSodiumKeyPair(public_key, private_key));
}


Ref<GDSodiumDirectionalKeys> GDSodiumKeyExchange::client_session_keys(
    Ref<GDSodiumKeyPair> client_keys,
    const PackedByteArray &server_public_key
) {
    PackedByteArray receive{};
    PackedByteArray transmit{};

    receive.resize(crypto_kx_SESSIONKEYBYTES);
    transmit.resize(crypto_kx_SESSIONKEYBYTES);

    if (crypto_kx_client_session_keys(
        receive.ptrw(),
        transmit.ptrw(),
        client_keys->public_key.ptr(),
        client_keys->private_key.ptr(),
        server_public_key.ptr()
    ) != 0) {
        return memnew(GDSodiumDirectionalKeys());
    }

    return memnew(GDSodiumDirectionalKeys(receive, transmit));
}


Ref<GDSodiumDirectionalKeys> GDSodiumKeyExchange::server_session_keys(
    Ref<GDSodiumKeyPair> server_keys,
    const PackedByteArray &client_public_key
) {
    PackedByteArray receive{};
    PackedByteArray transmit{};

    receive.resize(crypto_kx_SESSIONKEYBYTES);
    transmit.resize(crypto_kx_SESSIONKEYBYTES);

    if (crypto_kx_server_session_keys(
        receive.ptrw(),
        transmit.ptrw(),
        server_keys->public_key.ptr(),
        server_keys->private_key.ptr(),
        client_public_key.ptr()
    ) != 0) {
        return memnew(GDSodiumDirectionalKeys());
    }

    return memnew(GDSodiumDirectionalKeys(receive, transmit));
}
