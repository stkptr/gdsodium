#ifndef GDSODIUM_H
#define GDSODIUM_H

#include <godot_cpp/classes/object.hpp>
#include <godot_cpp/variant/packed_byte_array.hpp>

namespace godot {

class GDSodium : public Object {
	GDCLASS(GDSodium, Object)

protected:
	static void _bind_methods();

public:
	GDSodium();
	~GDSodium();

    static Array chacha20_poly1305_ietf_encrypt_detached(
        const PackedByteArray &message,
        const PackedByteArray &key,
        const PackedByteArray &nonce,
        const PackedByteArray &associated_data
    );

    static PackedByteArray chacha20_poly1305_ietf_decrypt_detached(
        const PackedByteArray &message,
        const PackedByteArray &key,
        const PackedByteArray &nonce,
        const PackedByteArray &associated_data,
        const PackedByteArray &mac
    );

    static PackedByteArray argon2id_hash(
        const PackedByteArray &secret,
        const PackedByteArray &salt,
        uint64_t operations,
        uint64_t memory,
        uint32_t output_size
    );
};

}

#endif // GDSODIUM_H
