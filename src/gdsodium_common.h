#ifndef GDSODIUM_COMMON_H
#define GDSODIUM_COMMON_H

#include "gdsodium_types.h"

namespace gdsodium {

#define BIND_CONSTANT_AS(m_constant, m_name) \
    godot::ClassDB::bind_integer_constant( \
        get_class_static(), "", m_name, m_constant);

typedef godot::PackedByteArray Bytes;

}

#endif // GDSODIUM_COMMON_H
