#ifndef GDSODIUM_H
#define GDSODIUM_H

#include <gdsodium_common.h>

#include <godot_cpp/classes/object.hpp>
#include <godot_cpp/variant/packed_byte_array.hpp>

namespace gdsodium {

class GDSodium : public godot::Object {
	GDCLASS(GDSodium, Object)

protected:
	static void _bind_methods();

public:
	GDSodium();
	~GDSodium();

    static godot::Ref<GDSodiumTaggedMessage> chacha20_poly1305_ietf_encrypt_detached(
        const Bytes &message,
        const Bytes &key,
        const Bytes &nonce,
        const Bytes &associated_data
    );

    static godot::Ref<GDSodiumValidatedMessage> chacha20_poly1305_ietf_decrypt_detached(
        const Bytes &message,
        const Bytes &mac,
        const Bytes &key,
        const Bytes &nonce,
        const Bytes &associated_data
    );

    static int variant_check(
        godot::Variant a
    );

    static Bytes argon2id_hash(
        const Bytes &secret,
        const Bytes &salt,
        uint64_t operations,
        uint64_t memory,
        uint32_t output_size
    );
};

}

#endif // GDSODIUM_H
