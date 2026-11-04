load("@rules_cc//cc:cc_library.bzl", "cc_library")

def _qt_resource_impl(ctx):
  info = ctx.toolchains["@cxx-qt-bazel//toolchains:toolchain_type"].qtinfo

  out_bin = ctx.actions.declare_file("%s.cpp" % ctx.attr.name)

  qrc = [ file for file in ctx.files.res if str(file.path).endswith(".qrc") ][0]

  ctx.actions.run(
    executable = info.rcc.files_to_run.executable,
    arguments = [qrc.path, "-g", "cpp", "-o", out_bin.path],
    outputs = [out_bin],
    inputs = ctx.files.res
  )
  return DefaultInfo(files = depset([out_bin]))


_qt_resource = rule(
  implementation = _qt_resource_impl,
  attrs = {
    "res": attr.label_list(allow_files = True),
  },
  toolchains = ["@cxx-qt-bazel//toolchains:toolchain_type"]
)

def qt_resource(*, name, res, visibility = []):
  _qt_resource(
    name = "_%s" % name,
    res = res,
  )

  cc_library(
    name = name,
    srcs = ["_%s" % name],
    deps = ["@qt"],
    visibility = visibility,
    # alwayslink required for registration in res system
    alwayslink = True,
  )
