load("@cxx-qt-bazel//cxx-qt-bazel:generate.bzl", generate = "cxx_qt_cmd")
load("@rules_cc//cc:cc_library.bzl", "cc_library")

def qml_module(
  *, 
  name, 
  crate_name, 
  modules, 
  cc_deps = [],
  additional_includes = [],
  visibility = [], 
):
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
      cc_deps = cc_deps,
      include_prefix = "private",
      additional_includes = [
        name + "_" + module + "-gen/out/cxxqtbuild/include/private/" + include for include in additional_includes
      ]
    )
  cc_library(
    name = name,
    deps = [ name + "_" + module for module in modules ] + ["@qt"],
    visibility = visibility,
    defines = [
      "QT_STATICPLUGIN",
    ],
  )
