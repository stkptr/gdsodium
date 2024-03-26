#ifndef GDSODIUM_KEY_EXCHANGE_H
#define GDSODIUM_KEY_EXCHANGE_H

#include <godot_cpp/classes/object.hpp>
#include "gdsodium_common.h"

namespace gdsodium {

class GDSodiumKeyExchange : public godot::Object {
	GDCLASS(GDSodiumKeyExchange, godot::Object)

protected:
	static void _bind_methods();

public:
    GDSodiumKeyExchange() {}
    ~GDSodiumKeyExchange() {}

    static godot::Ref<GDSodiumKeyPair> generate_keypair(
        const Bytes &seed
    );

    static godot::Ref<GDSodiumDirectionalKeys> client_session_keys(
        godot::Ref<GDSodiumKeyPair> client_keys,
        const Bytes &server_public_key
    );

    static godot::Ref<GDSodiumDirectionalKeys> server_session_keys(
        godot::Ref<GDSodiumKeyPair> server_keys,
        const Bytes &client_public_key
    );
};

}

#endif // GDSODIUM_KEY_EXCHANGE_H
