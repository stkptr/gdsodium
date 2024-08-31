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
