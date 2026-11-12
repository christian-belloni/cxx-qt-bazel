load("@rules_cc//cc:cc_library.bzl", "cc_library")
load(":providers.bzl", "CxxQtQmlPlugin")
load("@bazel_skylib//rules/directory:providers.bzl", "DirectoryInfo")

def _out_path(ctx, path):
  return ctx.actions.declare_file("%s/out/%s" % (ctx.label.name, path))

def _common_args(ctx, args):
  cxx_header = _out_path(ctx, "cxxqtbuild/include/rust/cxx.h")
  toml_dir = ctx.file.cargo_toml.dirname
  out_dir = cxx_header.path.removesuffix("/cxxqtbuild/include/rust/cxx.h")

  args.add("--out-dir", out_dir)
  
  info = ctx.toolchains["@cxx-qt-bazel//toolchains:toolchain_type"].qtinfo

  args.add("--qmake", info.qmake.files_to_run.executable.path)
  
  # args.add("--minimal-root", ctx.attr._qt_files[DirectoryInfo].paeh)
  
  args.add("--crate-directory", toml_dir)
  args.add("--crate-name", ctx.attr.crate_name)
  if ctx.attr.crate_include_root != "":
    args.add("--crate-include-root", ctx.attr.crate_include_root)
  
  if ctx.attr.include_prefix != None:
    args.add("--include-prefix", ctx.attr.include_prefix)

  include_prefix = ctx.attr.crate_name

  if not ctx.attr.include_prefix.isspace():
    include_prefix = ctx.attr.include_prefix

  return toml_dir, cxx_header, include_prefix, info

def _copy_include_files(ctx):
  include_headers = []
  for header in ctx.files.crate_include_files:
    basepath = ctx.file.cargo_toml.dirname
    header_path = header.path.removeprefix("%s/%s" % (basepath, ctx.attr.crate_include_root))
    include_header = _out_path(ctx, "cxxqtbuild/include/%s/%s" % (ctx.attr.crate_name, header_path))
    cp_args = ctx.actions.args()
    cp_args.add(header)
    cp_args.add(include_header)
    out = [include_header]

    ctx.actions.run_shell(
      inputs = ctx.files.srcs,
      outputs = out,
      command = "cp -a %s %s" % (header.path, include_header.path),
    )
    include_headers += out
  return include_headers

def _generate_sources(*, ctx, args, bridge_files, include_prefix, toml_dir):
  generated_headers = []
  generated_cpps = []

  for bridge in bridge_files:
    if type(bridge) == "string":
      args.add("--file", "%s/%s" % (toml_dir, bridge))
      relative_path = bridge
    else:
      args.add("--file", bridge)
      relative_path = bridge.path.removeprefix("%s/" % toml_dir)

    new_header = _out_path(ctx, "cxxqtbuild/include/%s/%s" % (include_prefix, relative_path.replace(".rs", ".cxx.h")))
    new_cxxqt_header = _out_path(ctx, "cxxqtbuild/include/%s/%s" % (include_prefix, relative_path.replace(".rs", ".cxxqt.h")))
    generated_headers.append(new_header)
    generated_headers.append(new_cxxqt_header)
    new_cpp = _out_path(ctx, "cxxqtgen/%s" % relative_path.replace(".rs", ".cxx.cpp"))
    new_cpp_qt = _out_path(ctx, "cxxqtgen/%s" % relative_path.replace(".rs", ".cxxqt.cpp"))
    generated_cpps.append(new_cpp)
    generated_cpps.append(new_cpp_qt)
  return (generated_headers, generated_cpps)

def _generate_qml_module(ctx, args, include_prefix, toml_dir):
  moc_files = []
  moc_plugin_headers = []
  bridge_files = []

  for module_name, qml_files in ctx.attr.qml_modules.items():
    args.add("--new-qml-module", module_name)
    public = _out_path(ctx,
      "cxx-qt-build/initializers/qml_module_%s/public-initializer.cpp" % module_name.replace(".", "_")
    )
    call = _out_path(ctx,
      "cxx-qt-build/initializers/qml_module_%s/call-initializers.cpp" % module_name.replace(".", "_")
    )
    mod = _out_path(ctx, "rcc/qml_module_resources_%s.cpp" % module_name.replace(".", "_"))
    res = _out_path(ctx, "qt-build-utils/qml_plugin/%s_plugin.cpp" % module_name.replace(".", "_"))
    moc_plugin = _out_path(ctx, "moc/moc_%s_plugin.cpp.cpp" % module_name.replace(".", "_"))
    typeregister = _out_path(ctx, "qmltyperegistrar/%s_qmltyperegistration.cpp" % module_name.replace(".", "_"))

    
    cachegen = _out_path(ctx, "qmlcachegen/%s/qmlcache_loader.cpp" % module_name.replace(".", "/"))
    moc_files += [public, call, mod, res, typeregister, cachegen]
    moc_plugin_headers.append(moc_plugin)
    for f in qml_files:
      if f.endswith("qml"):
        args.add("--qml-file", f)
        qml = _out_path(ctx, "qmlcachegen/%s/%s.cpp" % (module_name.replace(".", "/"), f.split("/").pop()))
        moc_files.append(qml)
      elif f.endswith("rs"):
        bridge_files.append(f)
        moc_files.append(_out_path(ctx, "moc/moc_%s.cxxqt.h.cpp" % f.split("/").pop().replace(".rs", "")))
      
  sources, hdrs = _generate_sources(
    ctx = ctx,
    args = args,
    include_prefix = include_prefix,
    bridge_files = bridge_files,
    toml_dir = toml_dir
  )

  return (moc_files + sources + hdrs, moc_plugin_headers)

def _generate_extra_headers(ctx, args):
  extra_headers = []
  for filename, content in ctx.attr.extra_headers.items():
    header = _out_path(ctx, "include/%s/%s" % (ctx.attr.crate_name, filename))
    args.add("--extra-header-file", header)
    extra_headers.append(header)
    
    for line in content:
      args.add("--extra-header-line", line)
  return extra_headers

def _generate_initializers(ctx, args):
  for k in ctx.attr.initializers:
    v = ctx.attr.initializers[k][DefaultInfo].files.to_list()[0]
    args.add("--initializer", "%s;%s" % (k, v.path))

  public_initializer = _out_path(ctx, "cxx-qt-build/initializers/crate_%s/public-initializer.cpp" % ctx.attr.crate_name.replace("-", "_"))
  initializer = _out_path(ctx, "cxx-qt-build/initializers/crate_%s/call-initializers.cpp" % ctx.attr.crate_name.replace("-", "_"))
  
  return public_initializer, initializer

def _cxx_qt_cmd_impl(ctx):
  args = ctx.actions.args()
  toml_dir, cxx_header, include_prefix, info = _common_args(ctx, args)

  generated_headers, generated_cpps = _generate_sources(
    ctx = ctx,
    args = args,
    include_prefix = include_prefix,
    bridge_files = ctx.files.bridge_files,
    toml_dir = toml_dir
  )

  include_headers = _copy_include_files(ctx)
  
  extra_headers = _generate_extra_headers(ctx, args)
  
  public_initializer, initializer = _generate_initializers(ctx, args)

  (moc_files, moc_plugin_headers) = _generate_qml_module(ctx, args, include_prefix, toml_dir)

  args.add("generate")

  generated = generated_headers + generated_cpps + [public_initializer, initializer, cxx_header] + extra_headers

  outputs = generated + moc_files + moc_plugin_headers
  
  ctx.actions.run(
    outputs = outputs,
    inputs = ctx.files.srcs + include_headers + ctx.attr._qt_files[DirectoryInfo].transitive_files.to_list(),
    executable = info.cxxqtbuild.files_to_run.executable,
    arguments = [args],
    mnemonic = "CxxQtGenerate",
    tools = [info.qmake.files_to_run],
    env = {
      "CARGO_CFG_cxxqt_qt_version_major": "6",
      "CARGO_CFG_cxxqt_qt_version_minor": "12",
      "CARGO_CFG_cxxqt_qt_version_at_least_6_1": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_6_2": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_6_3": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_6_4": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_6_5": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_6_6": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_6_7": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_6_8": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_6_9": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_6_10": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_6_11": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_6_12": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_5": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_6": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_7": "1",
    }
  )

  files = [cxx_header] + include_headers + extra_headers + generated_headers + generated_cpps + moc_files + [public_initializer, initializer]
  files = depset(files + ctx.files.cpp_files)

  providers = [DefaultInfo(files = files), CxxQtQmlPlugin(plugin_headers = depset(moc_plugin_headers))]

  return providers

_cxx_qt_cmd = rule(
  implementation = _cxx_qt_cmd_impl,
  attrs = {
    "crate_name": attr.string(mandatory = True),
    "srcs": attr.label_list(allow_files = True),
    "cargo_toml": attr.label(allow_single_file = True, mandatory = True),
    "bridge_files": attr.label_list(allow_files = True),
    "cpp_files": attr.label_list(allow_files = True),
    "initializers": attr.string_keyed_label_dict(allow_files = True),
    "crate_include_root": attr.string(),
    "crate_include_files": attr.label_list(allow_files = True),
    "include_dirs": attr.string_list(),
    "include_prefix": attr.string(),
    "extra_headers": attr.string_list_dict(),
    "qml_modules": attr.string_list_dict(),
    "include_builtins": attr.bool(default = True),
    "_qt_files": attr.label(providers = [DirectoryInfo], default = Label("@qt//:files")),
  },
  toolchains = ["@cxx-qt-bazel//toolchains:toolchain_type"]
)

def _extract_plugin_headers_impl(ctx):
  include = ctx.attr.cxx_qt_cmd[CxxQtQmlPlugin]
  return DefaultInfo(files = include.plugin_headers)

_extract_plugin_headers = rule(
  implementation = _extract_plugin_headers_impl,
  attrs = {
    "cxx_qt_cmd": attr.label(providers = [CxxQtQmlPlugin])
  }
)

def cxx_qt_cmd(*, name, visibility = [], cc_deps = [], additional_includes = [], **kwargs):
  _cxx_qt_cmd(name = name + "-gen", visibility = visibility, **kwargs)
  _extract_plugin_headers(
    name = "_plugin_headers_%s" % name,
    cxx_qt_cmd = name + "-gen",
  )
  cc_library(
    name = name,
    srcs = [name + "-gen"],
    hdrs = ["_plugin_headers_%s" % name],
    visibility = visibility,
    includes = [
      "%s-gen/out/cxxqtbuild/include" % name,
      "%s-gen/out/include" % name,
      "%s-gen/out/moc" % name,
    ] + additional_includes,
    defines = [
      "QT_STATICPLUGIN",
    ],
    deps = [ "@qt//:qt", "@cxx-qt-bazel//cxx-qt-bazel/private:builtins" ] + [ "%s" % dep for dep in cc_deps ],
    alwayslink = True,
    linkstatic = True,
  )

def _generate_cxxqt_impl(ctx):
  args = ctx.actions.args()
  toml_dir, cxx_header, include_prefix, info = _common_args(ctx, args)

  generated_headers, generated_cpps = _generate_sources(
    ctx = ctx,
    args = args,
    include_prefix = include_prefix,
    toml_dir = toml_dir,
    bridge_files = ctx.files.bridge_files
  )

  args.add("--new-qml-module", ctx.attr.module_name)
  outputs = [
    cxx_header,
    _out_path(ctx, "qmltyperegistrar/%s_qmltyperegistration.cpp" % ctx.attr.module_name),
    _out_path(ctx, "moc/moc_%s_plugin.cpp.cpp" % ctx.attr.module_name.replace(".", "_")),
    _out_path(ctx, "qt-build-utils/qml_plugin/%s_plugin.cpp" % ctx.attr.module_name.replace(".", "_")),
    _out_path(ctx, "rcc/qml_module_resources_%s.cpp" % ctx.attr.module_name.replace(".", "_"))
  ] + generated_headers + generated_cpps
  
  for bridge in ctx.files.bridge_files:
    args.add("--file", bridge)
    outputs.append(_out_path(ctx, "moc/moc_%s.cxxqt.h.cpp" % bridge.basename.replace(".rs", "")))

  args.add("generate")
  ctx.actions.run(
    outputs = outputs,
    inputs = ctx.files.srcs + ctx.attr._qt_files[DirectoryInfo].transitive_files.to_list(),
    executable = info.cxxqtbuild.files_to_run.executable,
    arguments = [args],
    mnemonic = "CxxQtGenerate",
    tools = [info.qmake.files_to_run],
    env = {
      "CARGO_CFG_cxxqt_qt_version_major": "6",
      "CARGO_CFG_cxxqt_qt_version_minor": "12",
      "CARGO_CFG_cxxqt_qt_version_at_least_6_1": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_6_2": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_6_3": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_6_4": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_6_5": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_6_6": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_6_7": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_6_8": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_6_9": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_6_10": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_6_11": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_6_12": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_5": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_6": "1",
      "CARGO_CFG_cxxqt_qt_version_at_least_7": "1",
    }
  )

  providers = [DefaultInfo(files = depset([out for out in outputs if not out.path.endswith(".cpp.cpp")])), CxxQtQmlPlugin(plugin_headers = depset([out for out in outputs if out.path.endswith(".cpp.cpp")]))]
  return providers


_generate_cxxqt = rule(
  implementation = _generate_cxxqt_impl,
  attrs = {
    "srcs": attr.label_list(allow_files = True),
    "bridge_files": attr.label_list(allow_files = True),
    "cargo_toml": attr.label(allow_single_file = True, mandatory = True),
    "module_name": attr.string(mandatory = True),
    "crate_name": attr.string(mandatory = True),
    "crate_include_root": attr.string(),
    "include_prefix": attr.string(),
    "_qt_files": attr.label(providers = [DirectoryInfo], default = Label("@qt//:files")),
  },
  toolchains = ["@cxx-qt-bazel//toolchains:toolchain_type"]
)

def generate_cxxqt(*, name, visibility = [], cc_deps = [], **kwargs):
  _generate_cxxqt(
    name = name + "-gen",
    **kwargs
  )
  
  _extract_plugin_headers(
    name = "_plugin_headers_%s" % name,
    cxx_qt_cmd = name + "-gen",
  )

  cc_library(
    name = name,
    srcs = [name + "-gen"],
    hdrs = ["_plugin_headers_%s" % name],
    visibility = visibility,
    deps = ["@qt", "@cxx-qt-bazel//cxx-qt-bazel/private:builtins"] + cc_deps,
    strip_include_prefix = "%s-gen/out" % name,
    includes = [
      "%s-gen/out/cxxqtbuild/include" % name,
      "%s-gen/out/include" % name,
      "%s-gen/out/moc" % name,
      "%s-gen/out/cxxqtbuild/include/private/src" % name,
    ],
    defines = [
      "QT_STATICPLUGIN",
    ],
    alwayslink = True,
    linkstatic = True,
  )
