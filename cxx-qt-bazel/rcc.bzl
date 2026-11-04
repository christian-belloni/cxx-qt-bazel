load("@rules_cc//cc:cc_library.bzl", "cc_library")

def _qt_resource_impl(ctx):
  info = ctx.toolchains["@cxx-qt-bazel//toolchains:toolchain_type"].qtinfo

  out_bin = ctx.actions.declare_file("%s.cpp" % ctx.attr.name)

  qrc = ctx.files.qrc[0]

  if len(ctx.files.qrc) != 1:
    fail("found more than 1 .qrc file in res directory")

  ctx.actions.run(
    executable = info.rcc.files_to_run.executable,
    arguments = [qrc.path, "-g", "cpp", "-o", out_bin.path],
    outputs = [out_bin],
    inputs = ctx.files.res + ctx.files.qrc
  )
  return DefaultInfo(files = depset([out_bin]))


_qt_resource = rule(
  implementation = _qt_resource_impl,
  attrs = {
    "qrc": attr.label_list(allow_files = True),
    "res": attr.label_list(allow_files = True),
  },
  toolchains = ["@cxx-qt-bazel//toolchains:toolchain_type"]
)

def qrc_resource(*, name, qrc, res, visibility = []):
  _qt_resource(
    name = "_%s" % name,
    qrc = qrc,
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

def qt_resource(*, name, res, visibility = []):
  _qt_resource(
    name = "_%s" % name,
    res = native.glob(["%s/**" % res], exclude = ["**/*.qrc"]),
    qrc = native.glob(["%s/**/*.qrc" % res]),
  )

  cc_library(
    name = name,
    srcs = ["_%s" % name],
    deps = ["@qt"],
    visibility = visibility,
    # alwayslink required for registration in res system
    alwayslink = True,
  )
