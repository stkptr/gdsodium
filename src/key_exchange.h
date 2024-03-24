#ifndef KEY_EXCHANGE_H
#define KEY_EXCHANGE_H

#include <godot_cpp/classes/object.hpp>
#include <godot_cpp/variant/packed_byte_array.hpp>
#include "gdsodium_common.h"

namespace godot {

class GDSodiumKeyExchange : public Object {
	GDCLASS(GDSodiumKeyExchange, Object)

protected:
	static void _bind_methods();

public:
    GDSodiumKeyExchange() {}
    ~GDSodiumKeyExchange() {}

    static Ref<GDSodiumKeyPair> generate_keypair(
        const PackedByteArray &seed
    );

    static Ref<GDSodiumDirectionalKeys> client_session_keys(
        Ref<GDSodiumKeyPair> client_keys,
        const PackedByteArray &server_public_key
    );

    static Ref<GDSodiumDirectionalKeys> server_session_keys(
        Ref<GDSodiumKeyPair> server_keys,
        const PackedByteArray &client_public_key
    );
};

}

#endif // KEY_EXCHANGE_H
