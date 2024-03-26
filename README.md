# GDSodium

GDSodium is a set of libsodium bindings for GDScript. GDSodium is provided as a
GDExtension targeting Godot 4.2 and above.

## Usage guide

GDSodium is currently **not stable**. You shouldn't use it for anything
important yet.

However, once GDSodium is stable head over to [releases] and grab the newest
`gdsodium.zip`. Unzip into your project and you should be good to go.

By using GDSodium you must agree to some licenses. GDSodium itself is public
domain, but libsodium and GDExtension both have credit requirements.
**You must** include the licenses for [godot-cpp](/godot-cpp/LICENSE.md) and
[libsodium](/libsodium/LICENSE) in your final project. If your project is
graphical-only, you should have some menu option which shows a list of licenses,
including the licenses for godot-cpp and libsodium.

## Supported architectures

- Windows: `x86_32`, `x86_64`
- Linux:  `x86_32`, `x86_64`, `arm64`, `ppc32`, `ppc64`
- Android: `arm32` (`armv7`), `arm64` (`armv8`/`aarch64`), `x86_32`, `x86_64`

Other architectures and platforms should be supported, but they either haven't
or can't be added to the [Docker buildsystem](/docker-build) so they are not
included in releases.

On Linux, `arm32` and `riscv64` compilation fails with Godot, so those platforms
will not be supported until that issue is fixed. It's a threading-related issue.

Further, only `x86_64` and `arm64` Linux, `x86_64` Windows, and
`x86_64` and `arm64` Android are tested.


## Compiling

### Docker

If you have Docker:

```
$ git clone --recurse-submodules https://github.com/stkptr/gdsodium
$ cd gdsodium/docker-build
$ ./build.sh
```

This compiles for all supported architectures, except macOS and iOS.
The Docker buildsystem is structured with an `x86_64`host in mind.
Expect a build time of about 2 to 3 hours on an 8 core machine.

The buildsystem has the basis for macOS and iOS development in place, but will
not produce binaries at this point. Further, the system in place so far needs
insecure mode enabled. See [here][docker-insecure] for more info.

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

If you're using Windows, or would like to build libsodium with Zig for any other
reason, use `scons sodium_use_zig=yes` instead of just `scons`.


[releases]: https://github.com/stkptr/gdsodium/releases
[macos]: https://docs.godotengine.org/en/stable/contributing/development/compiling/compiling_for_macos.html
[docker-insecure]: https://docs.docker.com/reference/dockerfile/#run---security
