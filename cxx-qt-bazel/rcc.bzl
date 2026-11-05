load("@rules_cc//cc:cc_library.bzl", "cc_library")

def _qt_resource_impl(ctx):
  info = ctx.toolchains["@cxx-qt-bazel//toolchains:toolchain_type"].qtinfo


  qrc = [ file for file in ctx.files.res if str(file.path).endswith(".qrc") ][0]
  args = []
  if ctx.attr.binary:
    out_bin = ctx.actions.declare_file("%s.rcc" % ctx.attr.name)
    args = [
      qrc.path, 
      "--root", 
      "/qt/qml/" + ctx.attr.module_name, 
      "--binary",
      "-o", 
      out_bin.path
    ]
  else:
    out_bin = ctx.actions.declare_file("%s.cpp" % ctx.attr.name)
    args = [
      qrc.path, 
      "--name", 
      ctx.label.name, 
      "--root", 
      "/qt/qml/" + ctx.attr.module_name, 
      "-g", 
      "cpp", 
      "-o", 
      out_bin.path
    ]
  

  ctx.actions.run(
    executable = info.rcc.files_to_run.executable,
    arguments = args,
    outputs = [out_bin],
    inputs = ctx.files.res
  )
  return DefaultInfo(files = depset([out_bin]))


_qt_resource = rule(
  implementation = _qt_resource_impl,
  attrs = {
    "res": attr.label_list(allow_files = True),
    "module_name": attr.string(mandatory = True),
    "binary": attr.bool(default = False)
  },
  toolchains = ["@cxx-qt-bazel//toolchains:toolchain_type"]
)

def qt_resource(*, name, module_name, res, visibility = []):
  _qt_resource(
    name = "_%s" % name,
    res = res,
    module_name = module_name
  )

  cc_library(
    name = name,
    srcs = ["_%s" % name],
    deps = ["@qt"],
    visibility = visibility,
    # alwayslink required for registration in res system
    alwayslink = True,
    linkstatic = True,
  )

def qt_binary_resource(*, name, module_name, res, visibility = []):
  _qt_resource(
    name = name,
    res = res,
    module_name = module_name,
    binary = True,
  )

_QRC_TPL = """
<RCC>
  <qresource>
{files}
  </qresource>
</RCC>
"""

def _qt_localizations_impl(ctx):
  info = ctx.toolchains["@cxx-qt-bazel//toolchains:toolchain_type"].qtinfo
  rcc = info.rcc.files_to_run.executable
  lconvert = info.lconvert.files_to_run.executable
  locales = ctx.files.locales

  qms = []
  
  files = []

  for l in locales:
    f_name = l.basename
    qm = ctx.actions.declare_file(f_name.split(".")[0] + ".qm")
    ctx.actions.run(
      executable = lconvert,
      inputs = [l],
      outputs = [qm],
      arguments = [
        l.path,
        "-qm",
        qm.path
      ]
    )

    files.append("    <file>{file}</file>".format(file = qm.basename))

    qms.append(qm)
  qrc = ctx.actions.declare_file("res.qrc")
  ctx.actions.write(
    output = qrc,
    content = _QRC_TPL.format(files = "\n".join(files))
  )

  out_bin = ctx.actions.declare_file(ctx.attr.name + ".cpp")
  ctx.actions.run(
    executable = rcc,
    inputs = [qrc] + qms,
    arguments = [
      qrc.path, 
      "--root", 
      "/qt/qml/" + ctx.attr.module_name, 
      "-g", 
      "cpp", 
      "-compress",
      "10",
      "-o", 
      out_bin.path
    ],
    outputs = [out_bin]
  )

  return DefaultInfo(files = depset([out_bin]))

_qt_localizations = rule(
  implementation = _qt_localizations_impl,
  attrs = {
    "module_name": attr.string(mandatory = True),
    "locales": attr.label_list(allow_files = True),
  },
  toolchains = ["@cxx-qt-bazel//toolchains:toolchain_type"]
)

def qt_localizations(*, name, locales, module_name, visibility = []):
  _qt_localizations(
    name = "_%s" % name,
    locales = locales,
    module_name = module_name
  )

  cc_library(
    name = name,
    srcs = ["_%s" % name],
    deps = ["@qt"],
    visibility = visibility,
    # alwayslink required for registration in res system
    alwayslink = True,
    linkstatic = True,
  )
