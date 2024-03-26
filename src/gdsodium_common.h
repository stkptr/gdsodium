#ifndef GDSODIUM_COMMON_H
#define GDSODIUM_COMMON_H

#include <godot_cpp/variant/packed_byte_array.hpp>
#include "gdsodium_types.h"

namespace gdsodium {

#define BIND_METHOD(class, method_name, ...) \
    godot::ClassDB::bind_method( \
        godot::D_METHOD(#method_name, ##__VA_ARGS__), \
        &class::method_name \
    );

#define BIND_STATIC(class, method_name, ...) \
    godot::ClassDB::bind_static_method( \
        #class, \
        godot::D_METHOD(#method_name, ##__VA_ARGS__), \
        &class::method_name \
    );

#define BIND_CONSTANT_AS(m_constant, m_name) \
    godot::ClassDB::bind_integer_constant( \
        get_class_static(), "", m_name, m_constant);

#define EMPTY(class) memnew(class());

#define PASTE(a, b) a##b

#define GENERATE_KEYPAIR(class, constant) \
    Ref<GDSodiumKeyPair> class::generate_keypair( \
        const PackedByteArray &seed \
    ) { \
        PackedByteArray public_key{}; \
        PackedByteArray private_key{}; \
        public_key.resize(constant##_PUBLICKEYBYTES); \
        private_key.resize(constant##_SECRETKEYBYTES); \
        if (seed.size() == constant##_SEEDBYTES) { \
            constant##_seed_keypair( \
                public_key.ptrw(), \
                private_key.ptrw(), \
                seed.ptr() \
            ); \
        } else if (seed.is_empty()) { \
            constant##_keypair( \
                public_key.ptrw(), \
                private_key.ptrw() \
            ); \
        } else { \
            return EMPTY(GDSodiumKeyPair); \
        } \
        return memnew(GDSodiumKeyPair(public_key, private_key)); \
    }

typedef godot::PackedByteArray Bytes;

}

#endif // GDSODIUM_COMMON_H
