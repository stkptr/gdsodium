#include "register_types.h"

#ifdef GDSODIUM_EXTENSION
#include <gdextension_interface.h>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>
#else
#include "core/object/class_db.h"
#endif

#include <sodium.h>

#include "src/gdsodium.h"
#include "src/gdsodium_types.h"
#include "src/key_exchange.h"
#include "src/sign.h"

using namespace godot;
using namespace gdsodium;

void initialize(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE
	    || sodium_init() < 0
	    || ClassDB::class_exists("GDSodium")
	) {
		return;
	}
    ClassDB::register_class<GDSodium>();
    ClassDB::register_abstract_class<GDSodiumType>();
    ClassDB::register_class<GDSodiumKeyPair>();
    ClassDB::register_class<GDSodiumTaggedMessage>();
    ClassDB::register_class<GDSodiumValidatedMessage>();
    ClassDB::register_class<GDSodiumDirectionalKeys>();
    ClassDB::register_class<GDSodiumKeyExchange>();
    ClassDB::register_class<GDSodiumSign>();
}

void initialize_gdsodium_types(ModuleInitializationLevel p_level) {
	initialize(p_level);
}

void uninitialize_gdsodium_types(ModuleInitializationLevel p_level) {}

void initialize_gdsodium_module(ModuleInitializationLevel p_level) {
	initialize(p_level);
}

void uninitialize_gdsodium_module(ModuleInitializationLevel p_level) {}

#ifdef GDSODIUM_EXTENSION
extern "C"
{
    // Initialization
    GDExtensionBool GDE_EXPORT gdsodium_init(
        GDExtensionInterfaceGetProcAddress p_get_proc_address,
        GDExtensionClassLibraryPtr p_library,
        GDExtensionInitialization *r_initialization
    ) {
	    GDExtensionBinding::InitObject init_obj(
	        p_get_proc_address,
	        p_library,
	        r_initialization
	    );
	    init_obj.register_initializer(initialize_gdsodium_types);
	    init_obj.register_terminator(uninitialize_gdsodium_types);
	    init_obj.set_minimum_library_initialization_level(
	        MODULE_INITIALIZATION_LEVEL_SCENE
	    );

	    return init_obj.init();
    }
}
#endif
