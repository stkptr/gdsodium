#ifndef GDSODIUM_KEY_EXCHANGE_H
#define GDSODIUM_KEY_EXCHANGE_H

#include "gdsodium_common.h"

namespace gdsodium {

class GDSodiumKeyExchange : public Object {
	GDCLASS(GDSodiumKeyExchange, Object)

protected:
	static void _bind_methods();

public:
    GDSodiumKeyExchange() {}
    ~GDSodiumKeyExchange() {}

    static Ref<GDSodiumKeyPair> generate_keypair(
        const Bytes &seed
    );

    static Ref<GDSodiumDirectionalKeys> client_session_keys(
        Ref<GDSodiumKeyPair> client_keys,
        const Bytes &server_public_key
    );

    static Ref<GDSodiumDirectionalKeys> server_session_keys(
        Ref<GDSodiumKeyPair> server_keys,
        const Bytes &client_public_key
    );
};

}

#endif // GDSODIUM_KEY_EXCHANGE_H
