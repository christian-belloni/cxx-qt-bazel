load("@bazel_skylib//rules/directory:providers.bzl", "DirectoryInfo")


# Queries
#
# QT_INSTALL_LIBS
# QT_INSTALL_HEADERS
# QT_INSTALL_PREFIX
# QT_INSTALL_PLUGINS

TEMPLATE_QUERY="""#!/bin/bash
CWD="$(pwd)"

if [[ $2 == "QT_VERSION" ]]; then
  echo -n "6.12.0"
  exit 0
fi

if [[ $2 == "QT_INSTALL_LIBS" ]]; then
  echo -n "$CWD/{qt_dir}/lib"
  exit 0
fi

if [[ $2 == "QT_INSTALL_HEADERS" ]]; then
  echo -n "$CWD/{qt_dir}/include"
  exit 0
fi

if [[ $2 == "QT_INSTALL_PREFIX" ]]; then
  echo -n "$CWD/{qt_dir}"
  exit 0
fi

if [[ $2 == "QT_INSTALL_PLUGINS" ]]; then
  echo -n "$CWD/{qt_dir}/plugins"
  exit 0
fi

if [[ $2 == "QT_HOST_BINS" ]]; then
  echo -n "$CWD/{qt_dir}/bin"
  exit 0
fi

echo "QMAKE_SPEC:win32-g++"
echo "QT_SYSROOT:"
echo "QT_INSTALL_PREFIX:$CWD/{qt_dir}"
echo "QT_INSTALL_ARCHDATA:$CWD/{qt_dir}"
echo "QT_INSTALL_DATA:$CWD/{qt_dir}"
echo "QT_INSTALL_DOCS:$CWD/{qt_dir}/doc"
echo "QT_INSTALL_HEADERS:$CWD/{qt_dir}/include"
echo "QT_INSTALL_LIBS:$CWD/{qt_dir}/lib"
echo "QT_INSTALL_LIBEXECS:$CWD/{qt_dir}/libexec"
echo "QT_INSTALL_BINS:$CWD/{qt_dir}/bin"
echo "QT_INSTALL_TESTS:$CWD/{qt_dir}/tests"
echo "QT_INSTALL_PLUGINS:$CWD/{qt_dir}/plugins"
echo "QT_INSTALL_QML:$CWD/{qt_dir}/qml"
echo "QT_INSTALL_TRANSLATIONS:$CWD/{qt_dir}/translations"
echo "QT_INSTALL_CONFIGURATION:"
echo "QT_INSTALL_EXAMPLES:$CWD/{qt_dir}/examples"
echo "QT_INSTALL_DEMOS:$CWD/{qt_dir}/examples"
echo "QT_HOST_PREFIX:$CWD/{qt_dir}"
echo "QT_HOST_DATA:$CWD/{qt_dir}"
echo "QT_HOST_BINS:$CWD/{qt_dir}/bin"
echo "QT_HOST_LIBEXECS:$CWD/{qt_dir}/libexec"
echo "QT_HOST_LIBS:$CWD/{qt_dir}/lib"
echo "QMAKE_SPEC:macx-clang"
echo "QMAKE_XSPEC:macx-clang"
echo "QMAKE_VERSION:3.1"
echo "QT_VERSION:6.12.0"
"""

def _qmake_impl(ctx):
  runfiles = ctx.runfiles(files = ctx.files.srcs)
  script = ctx.actions.declare_file("%s/qmake.sh" % ctx.label.name)
  directory = ctx.attr.qt_directory[DirectoryInfo].path
  ctx.actions.write(
    script, TEMPLATE_QUERY.format(qt_dir = directory, is_executable = True))
  
  return DefaultInfo(executable = script, runfiles = runfiles)

qmake = rule(
  implementation = _qmake_impl,
  attrs = {
    "qt_directory": attr.label(providers = [DirectoryInfo], default = Label("@qt//:files")),
    "srcs": attr.label(allow_files = True, default = Label("@qt//:srcs")),
  },
  executable = True
)
