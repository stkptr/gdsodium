#!/usr/bin/env python

import os
import fnmatch
import tarfile
import urllib.request
import sys
import platform

Import('env')

Import('customs')
opts = Variables(customs, ARGUMENTS)
opts.Add(
    BoolVariable(
        key='sodium_use_zig',
        help='Use Zig for compiling libsodium instead of autotools.',
        default=False
    )
)
opts.Add(
    key='sodium_configure',
    help='Custom arguments for ./configure',
    default=''
)
opts.Add(
    EnumVariable(
        key='sodium_optimize',
        help='Optimization level for Zig compilation.',
        default='speed',
        allowed_values=('speed', 'size', 'safety')
    )
)
opts.Update(env)
Help(opts.GenerateHelpText(env))

if sys.platform.startswith('linux'):
    DEFAULT_PLATFORM = 'linux'
elif sys.platform.startswith('win32'):
    DEFAULT_PLATFORM = 'windows'
elif sys.platform.startswith('darwin'):
    DEFAULT_PLATFORM = 'macos'

BASE = os.getcwd()

DEFAULT_ARCH = platform.uname()[-2]

PLATFORM = ARGUMENTS.get('platform', DEFAULT_PLATFORM)
ARCH = ARGUMENTS.get('arch', DEFAULT_ARCH)

USE_ZIG = ARGUMENTS.get('sodium_use_zig') == 'yes'

EXT = 'lib' if PLATFORM == 'windows' else 'a'

NOOP = 'echo'

NAME = 'sodium'
DIRECTORY = f'{BASE}/libsodium'
LIBNAME = NAME if PLATFORM == 'windows' else f'lib{NAME}'
LIBFILE = f'{LIBNAME}.{EXT}'

SOURCE_EXT = ['c', 'h']

SODIUM_CONFIGURE = ARGUMENTS.get('sodium_configure', '')

CONFIGURE = (
    'sh configure'
    ' --with-pic --disable-pie'
    ' --enable-static --disable-shared'
    f' {SODIUM_CONFIGURE}'
)
MAKE = f'make -j{GetOption("num_jobs")}'
CLEAN = 'make distclean'

TARGET = f'{DIRECTORY}/src/libsodium/.libs/{LIBFILE}'
INCLUDE = f'{DIRECTORY}/src/libsodium/include'

if USE_ZIG:
    CONFIGURE = NOOP
    # zig targets
    archmap = {
        'x86_32': 'x86',
        'arm32': 'arm',
        'arm64': 'aarch64',
        'rv32': 'riscv32',
        'rv64': 'riscv64',
    }
    arch = archmap.get(ARCH, ARCH)
    platform = 'windows-gnu' if PLATFORM == 'windows' else PLATFORM
    DTARGET = f'-Dtarget={arch}-{platform}'
    selected = '-Dstatic=true -Dshared=false -Dtest=false'
    MAKE = f'zig build {DTARGET} {selected} -Doptimize=ReleaseFast'
    CLEAN = 'rm -rf zig-out zig-cache'
    TARGET = f'{DIRECTORY}/zig-out/lib/{LIBFILE}'
    INCLUDE = f'{DIRECTORY}/zig-out/include'

if PLATFORM == 'android':
    archmap = {
        'arm32': 'armv7-a',
        'arm64': 'armv8-a',
        'x86_32': 'x86',
        'x86_64': 'x86_64',
    }
    CONFIGURE = f'sh dist-build/android-{archmap[ARCH]}.sh'
    MAKE = NOOP

def copy_into_env(env, var, default=''):
    if var in os.environ:
        env['ENV'][var] = os.environ[var]
    elif default:
        env['ENV'][var] = default

copy_into_env(env, 'ZIG_LOCAL_CACHE_DIR', 'zig-cache')
copy_into_env(env, 'ZIG_GLOBAL_CACHE_DIR', 'zig-cache')
copy_into_env(env, 'ANDROID_NDK_HOME')


def recursive_glob_ext(base, exts):
    files = []
    for root, dirnames, filenames in os.walk(base):
        for e in exts:
            for filename in fnmatch.filter(filenames, f'*.{e}'):
                files.append(os.path.join(root, filename))
    return files


TARGET = env.File(TARGET)

build = env.Command(TARGET, recursive_glob_ext(DIRECTORY, SOURCE_EXT), [
    f'cd {DIRECTORY} && {CONFIGURE} && {MAKE}'
])

if GetOption('clean'):
    env.Execute([f'cd {DIRECTORY} && {CLEAN}'])

env.Append(CPPPATH=[INCLUDE])
env.Append(LIBS=[TARGET])

Return('build')
