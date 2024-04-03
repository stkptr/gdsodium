#ifndef GDSODIUM_SIGN_H
#define GDSODIUM_SIGN_H

#include <godot_cpp/classes/ref_counted.hpp>
#include <sodium.h>
#include "gdsodium_common.h"

namespace gdsodium {

class GDSodiumSign : public godot::RefCounted {
	GDCLASS(GDSodiumSign, godot::RefCounted)

    crypto_sign_state state;
    bool initialized = false;

protected:
	static void _bind_methods();

public:
    GDSodiumSign() {}
    ~GDSodiumSign() {}

    void start() {
        crypto_sign_init(&state);
        initialized = true;
    }

    static godot::Ref<GDSodiumSign> create() {
        godot::Ref<GDSodiumSign> obj = memnew(GDSodiumSign());
        obj->start();
        return obj;
    }

    static godot::Ref<GDSodiumKeyPair> generate_keypair(
        const Bytes &seed
    );

    static Bytes private_key_to_seed(
        const Bytes &private_key
    );

    static Bytes private_key_to_public_key(
        const Bytes &private_key
    );

    static Bytes sign(
        const Bytes &message,
        const Bytes &private_key
    );

    static Bytes sign_detached(
        const Bytes &message,
        const Bytes &private_key
    );

    static godot::Ref<GDSodiumValidatedMessage> open(
        const Bytes &signed_message,
        const Bytes &public_key
    );

    static bool verify_detached(
        const Bytes &message,
        const Bytes &signature,
        const Bytes &public_key
    );

    bool update(
        const Bytes &data
    );

    Bytes final_sign(
        const Bytes &private_key
    );

    bool final_verify(
        const Bytes &signature,
        const Bytes &public_key
    );
};

}

#endif // GDSODIUM_SIGN_H
