#!/usr/bin/env python

Import('env')
Import('customs')

libsodium = SConscript('libsodium.SConstruct', {'env': env, 'customs': customs})

import os
BASE = os.getcwd()

datatypes = env.Command(
    'src/generated_datatypes.h', [
        'src/dataclass_generate.py',
        'src/dataclasses.json',
    ], [
        f'{BASE}/src/dataclass_generate.py {BASE}/src/dataclasses.json > $TARGET'
    ]
)

Return('libsodium', 'datatypes')
