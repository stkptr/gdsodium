# GDSodium

GDSodium is a set of libsodium bindings for GDScript. GDSodium is provided as a
GDExtension targeting Godot 4.2 and above.

## Supported architectures

- Windows: `x86_32`, `x86_64`
- Linux:  `x86_32`, `x86_64`, `arm64`, `ppc64`, `ppc32`
- Android: `arm32` (`armv7`), `arm64` (`armv8`/`aarch64`), `x86_32`, `x86_64`

Other architectures and platforms should be supported, but they either haven't
or can't be added to the [Docker buildsystem](/docker-build) so they are not
included in releases.

Further, only `x86_64` Linux and Windows, and `arm64` Android are tested.


## Compiling

### Docker

If you have Docker:

```
$ git clone --recurse-submodules https://github.com/stkptr/gdsodium
$ cd gdsodium/docker-build
$ ./build.sh
```

This compiles for all supported architectures, except macOS and iOS.
The Docker buildsystem is structured with an x86_64 host in mind.

### SCons

#### Debian

- `apt install git python3 pipx build-essential`
- `pipx install scons`

#### Windows (MinGW)

MSVC is currently not supported.

- `choco` see https://chocolatey.org/install
- `choco install git python3 zig mingw`
- `pip install scons`

#### MacOS

Refer to [the Godot documentation][macos].

#### Compilation procedure

```
$ git clone --recurse-submodules https://github.com/stkptr/gdsodium
$ cd gdsodium
$ scons
```


[macos]: https://docs.godotengine.org
    /en/stable/contributing/development/compiling/compiling_for_macos.html
