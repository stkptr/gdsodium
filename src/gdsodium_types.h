#ifndef GDSODIUM_TYPES_H
#define GDSODIUM_TYPES_H

#include "gdsodium_common.h"

namespace gdsodium {

class GDSodiumType : public RefCounted {
	GDCLASS(GDSodiumType, RefCounted)
protected:
	static void _bind_methods() {}
};

#include "generated_datatypes.h"

}

#endif // GDSODIUM_TYPES_H
