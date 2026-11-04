load("@cxx-qt-bazel//cxx-qt-bazel:generate.bzl", generate = "cxx_qt_cmd")
load("@rules_cc//cc:cc_library.bzl", "cc_library")

def qml_module(
  *, 
  name, 
  crate_name, 
  modules, 
  visibility = [], 
):
  module, files = modules.popitem()
  generate(
    name = name + "_" + module,
    srcs = native.glob(["**"]),
    crate_name = crate_name,
    cargo_toml = "Cargo.toml",
    qml_modules = {
      module: files
    },
    include_builtins = True
  )

  for module, files in modules.items():
    print(module, files)
    generate(
      name = name + "_" + module,
      srcs = native.glob(["**"]),
      crate_name = crate_name,
      cargo_toml = "Cargo.toml",
      qml_modules = {
        module: files
      },
      include_builtins = False
    )
  cc_library(
    name = name,
    deps = [ name + "_" + module for module in modules ] + ["@qt"] + [ name + "_" + module ],
    visibility = visibility,
    defines = [
      "QT_STATICPLUGIN",
    ],
  )
