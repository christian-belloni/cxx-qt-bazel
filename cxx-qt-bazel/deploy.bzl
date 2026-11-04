load("@bazel_lib//lib:copy_file.bzl", "copy_file_action", "COPY_FILE_TOOLCHAINS")
load("@rules_pkg//pkg:zip.bzl", "pkg_zip")
load("@rules_pkg//pkg:mappings.bzl", "pkg_files")
load("@rules_pkg//pkg:mappings.bzl", "strip_prefix")



# Vendored from bazel_lib
def _transition_platform_impl(settings, attr):
  use_common = settings.get("@rules_rust//rust/settings:experimental_use_cc_common_link", False)
  if "windows" in str(attr._target_platform):
    use_common = True
  return {
    "//command_line_option:platforms": str(attr._target_platform),
    "@rules_rust//rust/settings:experimental_use_cc_common_link": use_common
  }

_transition_platform = transition(
    implementation = _transition_platform_impl,
    inputs = [],
    outputs = ["//command_line_option:platforms", "@rules_rust//rust/settings:experimental_use_cc_common_link"],
)

def _common_copy_plugins_qml(ctx):
  plugin_outs = []
  for file in ctx.files.plugin_files:
    idx = file.path.find("/plugins/")
    out_path = file.path[idx + 1:]
    out = ctx.actions.declare_file("%s/%s" % (ctx.label.name, out_path))
    copy_file_action(ctx, file, out)
    plugin_outs.append(out)

  qml_outs = []
  for file in ctx.files.qml_files:
    idx = file.path.find("/qml/")
    out_path = file.path[idx + 1:]
    out = ctx.actions.declare_file("%s/%s" % (ctx.label.name, out_path))
    copy_file_action(ctx, file, out)
    qml_outs.append(out)
  return plugin_outs, qml_outs


def _deploy_win_impl(ctx):
  binary_outs = []
  exe_path = [ file.dirname for file in ctx.files.binary if ".exe" in file.path ][0]
  for file in ctx.files.binary:
    if ".exe" not in file.path and "libc++" not in file.path and "unwind" not in file.path:
      continue
    out_path = file.path.removeprefix(exe_path)
    out = ctx.actions.declare_file("%s%s" % (ctx.label.name, out_path))
    copy_file_action(ctx, file, out)
    binary_outs.append(out)

  plugin_outs, qml_outs = _common_copy_plugins_qml(ctx)

  lib_outs = []
  for file in ctx.files.shared_libs:
    idx = file.path.find("/bin/")
    out_path = file.path[idx + 5:]
    out = ctx.actions.declare_file("%s/%s" % (ctx.label.name, out_path))
    copy_file_action(ctx, file, out)
    lib_outs.append(out)

  return DefaultInfo(files = depset(binary_outs + plugin_outs + qml_outs + lib_outs))


_deploy_win = rule(
  implementation = _deploy_win_impl,
  attrs = {
    "binary": attr.label(allow_files = True, cfg = _transition_platform),
    "data": attr.label_list(allow_files = True, cfg = _transition_platform),
    "shared_libs": attr.label(allow_files = True, cfg = _transition_platform),
    "plugin_files": attr.label(allow_files = True, cfg = _transition_platform),
    "qml_files": attr.label(allow_files = True, cfg = _transition_platform),
    "_target_platform": attr.label(default = "@cxx-qt-bazel//platforms:windows_x86")
  },
  toolchains = COPY_FILE_TOOLCHAINS
)

def deploy_win(*, name, binary, shared_libs, plugin_files, qml_files, data = [], visibility = []):
  _deploy_win(
    name = "_dir_" + name,
    binary = binary,
    shared_libs = shared_libs,
    plugin_files = plugin_files,
    qml_files = qml_files
  )

  pkg_files(
    name = "_files_" + name,
    srcs = ["_dir_" + name],
    strip_prefix = strip_prefix.from_pkg("_dir_" + name),
  )

  pkg_zip(
    name = name,
    srcs = ["_files_" + name] + data,
    visibility = visibility
  )





def _deploy_osx_impl(ctx):

  out = ctx.actions.declare_file("%s/%s" % (ctx.label.name, ctx.executable.binary.basename)) 
  binary_outs = [out]
  copy_file_action(ctx, ctx.file.binary, out)

  plugin_outs, qml_outs = _common_copy_plugins_qml(ctx)

  lib_outs = []
  for file in ctx.files.shared_libs:
    idx = file.path.find("/lib/")
    out_path = file.path[idx + 5:]
    out = ctx.actions.declare_file("%s/lib/%s" % (ctx.label.name, out_path))
    copy_file_action(ctx, file, out)
    lib_outs.append(out)

  return DefaultInfo(files = depset(binary_outs + plugin_outs + qml_outs + lib_outs))


__deploy_osx = rule(
  implementation = _deploy_osx_impl,
  attrs = {
    "binary": attr.label(allow_single_file = True, cfg = _transition_platform, executable = True),
    "shared_libs": attr.label(allow_files = True, cfg = _transition_platform),
    "plugin_files": attr.label(allow_files = True, cfg = _transition_platform),
    "qml_files": attr.label(allow_files = True, cfg = _transition_platform),
    "_target_platform": attr.label(default = "@cxx-qt-bazel//platforms:osx_arm64")
  },
  toolchains = COPY_FILE_TOOLCHAINS
)

# Hidden until resolved
def _deploy_osx(*, name, binary, shared_libs, plugin_files, qml_files, visibility = []):
  _deploy_osx(
    name = "_dir_" + name,
    binary = binary,
    shared_libs = shared_libs,
    plugin_files = plugin_files,
    qml_files = qml_files
  )

  pkg_files(
    name = "_files_" + name,
    srcs = ["_dir_" + name],
    strip_prefix = strip_prefix.from_pkg("_dir_" + name),
  )

  pkg_zip(
    name = name,
    srcs = ["_files_" + name],
    visibility = visibility
  )
