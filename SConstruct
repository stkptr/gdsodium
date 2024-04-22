#!/usr/bin/env python
import os

libname = 'gdsodium'
projectdir = 'demo'


def normalize_path(val, env):
    return val if os.path.isabs(val) else os.path.join(env.Dir("#").abspath, val)


def validate_parent_dir(key, val, env):
    if not os.path.isdir(normalize_path(os.path.dirname(val), env)):
        raise UserError("'%s' is not a directory: %s" % (key, os.path.dirname(val)))


localEnv = Environment(tools=["default"], PLATFORM="")

customs = ["custom.py"]
customs = [os.path.abspath(path) for path in customs]

opts = Variables(customs, ARGUMENTS)
opts.Add(
    BoolVariable(
        key="compiledb",
        help="Generate compilation DB (`compile_commands.json`) for external tools",
        default=localEnv.get("compiledb", False),
    )
)
opts.Add(
    BoolVariable(
        key="coverage",
        help="Include coverage information",
        default=False,
    )
)
opts.Add(
    PathVariable(
        key="compiledb_file",
        help="Path to a custom `compile_commands.json` file",
        default=localEnv.get("compiledb_file", "compile_commands.json"),
        validator=validate_parent_dir,
    )
)
opts.Update(localEnv)

Help(opts.GenerateHelpText(localEnv))

env = localEnv.Clone()
env["compiledb"] = False

env['ENV']['PATH'] = os.environ['PATH']

env.Append(CCFLAGS=['-DGDSODIUM_EXTENSION'])

env.Tool("compilation_db")
compilation_db = env.CompilationDatabase(
    normalize_path(localEnv["compiledb_file"], localEnv)
)
env.Alias("compiledb", compilation_db)

libsodium, datatypes = SConscript(
    'common.SConstruct',
    {'env': env, 'customs': customs}
)

env = SConscript("godot-cpp/SConstruct", {"env": env, "customs": customs})

env.Append(CPPPATH=["src/"])
sources = Glob("src/*.cpp") + Glob("*.cpp")
headers = Glob("src/*.h") + Glob("*.h")

file = "{}{}{}".format(libname, env["suffix"], env["SHLIBSUFFIX"])

if env["platform"] == "macos":
    platlibname = "{}.{}.{}".format(libname, env["platform"], env["target"])
    file = "{}.framework/{}".format(env["platform"], platlibname, platlibname)

libraryfile = "extension/{}/{}".format(env["platform"], file)

libenv = env.Clone()
if env['coverage']:
    libenv.Append(CCFLAGS=['-fprofile-arcs', '-ftest-coverage'])
    libenv.Append(LDFLAGS=['--coverage'])
    libenv.Append(LIBS=['gcov'])

if GetOption('clean'):
    env.Execute(['rm -f *.gcov src/*.gcov *.gcda src/*.gcda *.gcno src/*.gcno'])

library = libenv.SharedLibrary(
    libraryfile,
    source=sources,
)

env.Depends(library, libsodium)
env.Depends(library, datatypes)
env.Depends(library, headers)

copy_demo = env.InstallAs(f'{projectdir}/bin', 'extension')
default_args = [library, copy_demo]

if os.path.exists('gut'):
    copy_gut = env.InstallAs(f'{projectdir}/addons', 'gut/addons')
    default_args.append(copy_gut)

if localEnv.get("compiledb", False):
    default_args += [compilation_db]
Default(*default_args)
