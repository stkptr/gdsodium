#!/usr/bin/env python

import os
import fnmatch

Import('env')
env = env.Clone()

DIRECTORY = 'libs/libsodium/'
CONFIGURE = './configure --with-pic --disable-pie --enable-static'
MAKE = f'make -j{GetOption("num_jobs")}'
CLEAN = 'make distclean'

url_base = 'https://download.libsodium.org/libsodium/releases'
version = '1.0.19-stable'
URL = f'{url_base}/libsodium-{version}.tar.gz'

SOURCE_EXT = ['c', 'h']
TARGET = f'{DIRECTORY}/src/libsodium/.libs/libsodium.a'
INCLUDE = f'{DIRECTORY}/src/libsodium/include'


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
