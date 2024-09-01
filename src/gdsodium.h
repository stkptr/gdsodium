#ifndef GDSODIUM_H
#define GDSODIUM_H

#include "gdsodium_common.h"

namespace gdsodium {

class GDSodium : public Object {
	GDCLASS(GDSodium, Object) // GCOV_EXCL_LINE

protected:
	static void _bind_methods();

public:
	GDSodium();
	~GDSodium();
};

}

#endif // GDSODIUM_H
