#ifndef GDSODIUM_REGISTER_TYPES_H
#define GDSODIUM_REGISTER_TYPES_H


#ifdef GDSODIUM_EXTENSION

void initialize_gdsodium_types();
void uninitialize_gdsodium_types();

#else

#include "modules/register_module_types.h"

void initialize_gdsodium_module(ModuleInitializationLevel p_level);
void uninitialize_gdsodium_module(ModuleInitializationLevel p_level);

#endif


#endif // GDSODIUM_REGISTER_TYPES_H
