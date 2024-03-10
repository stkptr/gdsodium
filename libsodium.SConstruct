#!/usr/bin/env python

import os
import fnmatch
import tarfile
import urllib.request

Import('env')
env = env.Clone()


USE_ZIG = os.name == 'nt'
EXT = 'lib' if os.name == 'nt' else 'a'

NAME = 'sodium'
DIRECTORY = 'libsodium'
LIBNAME = NAME if os.name == 'nt' else f'lib{NAME}'
LIBFILE = f'{LIBNAME}.{EXT}'

CONFIGURE = 'sh configure --with-pic --disable-pie --enable-static'
MAKE = f'make -j{GetOption("num_jobs")}'
CLEAN = 'make distclean'

SOURCE_EXT = ['c', 'h']
TARGET = f'{DIRECTORY}/src/libsodium/.libs/{LIBFILE}'
INCLUDE = f'{DIRECTORY}/src/libsodium/include'

if USE_ZIG:
    CONFIGURE = 'echo'
    MAKE = 'zig build -Dstatic=true -Dshared=false -Doptimize=ReleaseFast'
    CLEAN = 'rm -rf zig-out zig-cache'
    TARGET = f'{DIRECTORY}/zig-out/lib/{LIBFILE}'
    INCLUDE = f'{DIRECTORY}/zig-out/include'


def copy_into_env(env, var, default=''):
    if var in os.environ:
        env['ENV'][var] = os.environ[var]
    elif default:
        env['ENV'][var] = default

copy_into_env(env, 'ZIG_LOCAL_CACHE_DIR', 'zig-cache')
copy_into_env(env, 'ZIG_GLOBAL_CACHE_DIR', 'zig-cache')


def recursive_glob_ext(base, exts):
    files = []
    for root, dirnames, filenames in os.walk(base):
        for e in exts:
            for filename in fnmatch.filter(filenames, f'*.{e}'):
                files.append(os.path.join(root, filename))
    return files


TARGET = env.File(TARGET)

env.Command(TARGET, recursive_glob_ext(DIRECTORY, SOURCE_EXT), [
    f'cd {DIRECTORY} && {CONFIGURE} && {MAKE}'
])

if GetOption('clean'):
    env.Execute([f'cd {DIRECTORY} && {CLEAN}'])

env.Append(CPPPATH=[INCLUDE])
env.Append(LIBS=[TARGET])


Return('env')
