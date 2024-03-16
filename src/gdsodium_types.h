#ifndef GDSODIUM_TYPES_H
#define GDSODIUM_TYPES_H

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/variant/packed_byte_array.hpp>

namespace godot {

class GDSodiumType : public RefCounted {
	GDCLASS(GDSodiumType, RefCounted)
protected:
	static void _bind_methods() {}
};

#include "generated_datatypes.h"

}

#endif // GDSODIUM_TYPES_H
