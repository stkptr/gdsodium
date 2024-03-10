#!/usr/bin/env python

import os
import fnmatch
import tarfile
import urllib.request
import sys

Import('env')
env = env.Clone()


if sys.platform.startswith('linux'):
    DEFAULT_PLATFORM = 'linux'
elif sys.platform.startswith('win32'):
    DEFAULT_PLATFORM = 'windows'
elif sys.platform.startswith('darwin'):
    DEFAULT_PLATFORM = 'macos'


PLATFORM = ARGUMENTS.get('platform', DEFAULT_PLATFORM)
ARCH = ARGUMENTS.get('arch', 'x86_64')


USE_ZIG = PLATFORM != DEFAULT_PLATFORM or PLATFORM == 'windows'
EXT = 'lib' if PLATFORM == 'windows' else 'a'

NAME = 'sodium'
DIRECTORY = 'libsodium'
LIBNAME = NAME if PLATFORM == 'windows' else f'lib{NAME}'
LIBFILE = f'{LIBNAME}.{EXT}'

SOURCE_EXT = ['c', 'h']

CONFIGURE = 'sh configure --with-pic --disable-pie --enable-static'
MAKE = f'make -j{GetOption("num_jobs")}'
CLEAN = 'make distclean'

TARGET = f'{DIRECTORY}/src/libsodium/.libs/{LIBFILE}'
INCLUDE = f'{DIRECTORY}/src/libsodium/include'

if USE_ZIG:
    CONFIGURE = 'echo'
    arch = 'aarch64' if ARCH == 'arm64' else ARCH
    platform = 'windows-gnu' if PLATFORM == 'windows' else PLATFORM
    DTARGET = f'-Dtarget={arch}-{platform}'
    selected = '-Dstatic=true -Dshared=false -Dtest=false'
    MAKE = f'zig build {DTARGET} {selected} -Doptimize=ReleaseFast'
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
