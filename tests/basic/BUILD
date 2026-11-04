load("@rules_rs//rs:rust_binary.bzl", "rust_binary")
load("@cxx-qt-bazel//cxx-qt-bazel:qml_module.bzl", "qml_module")
load("@cxx-qt-bazel//cxx-qt-bazel:rcc.bzl", "qt_resource")
load("@cxx_qt_crates//:defs.bzl", "all_crate_deps")
load("@cxx-qt-bazel//cxx-qt-bazel:deploy.bzl", "deploy_win", "deploy_osx")
load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("@rules_pkg//pkg:zip.bzl", "pkg_zip")
load("@rules_pkg//pkg:mappings.bzl", "pkg_files", "strip_prefix")

qt_resource(
  name = "images",
  res = "res",
)

qml_module(
  name = "main_qml",
  crate_name = "basic",
  modules = {
    "com.ui.components": ["qml/main.qml"],
  },
  visibility = ["//visibility:public"]
)

cc_library(
  name = "_ntdll",
  linkopts = [
    "ntdll.lib",
  ]
)

default_rustc_flags = [
  "--cfg", "cxxqt_qt_version_major=\"6\"",
  "--cfg", "cxxqt_qt_version_minor=\"11\"",
  "--cfg", "cxxqt_qt_version_patch=\"0\"",
  "--cfg", "cxxqt_qt_version_at_least_6_1=\"true\"",
  "--cfg", "cxxqt_qt_version_at_least_6_2=\"true\"",
  "--cfg", "cxxqt_qt_version_at_least_6_3=\"true\"",
  "--cfg", "cxxqt_qt_version_at_least_6_4=\"true\"",
  "--cfg", "cxxqt_qt_version_at_least_6_5=\"true\"",
  "--cfg", "cxxqt_qt_version_at_least_6_6=\"true\"",
  "--cfg", "cxxqt_qt_version_at_least_6_7=\"true\"",
  "--cfg", "cxxqt_qt_version_at_least_6_8=\"true\"",
  "--cfg", "cxxqt_qt_version_at_least_6_9=\"true\"",
  "--cfg", "cxxqt_qt_version_at_least_6_10=\"true\"",
  "--cfg", "cxxqt_qt_version_at_least_6_11=\"true\"",
  "--cfg", "cxxqt_qt_version_at_least_6=\"true\"",
]

rust_binary(
  name = "basic",
  srcs = ["src/main.rs"],
  deps = all_crate_deps() + [
    "main_qml",
    "images"
  ],
  alwayslink = True,
  data = ["@qt"]
)

deploy_win(
  name = "packaged_win",
  binary = ":basic",
  shared_libs = "@qt//:shared_files",
  plugin_files = "@qt//:plugin_files",
  qml_files = "@qt//:qml_files",
)

deploy_osx(
  name = "packaged_osx",
  binary = ":basic",
  shared_libs = "@qt//:shared_files",
  plugin_files = "@qt//:plugin_files",
  qml_files = "@qt//:qml_files",
)

pkg_files(
  name = "zip_osx_files",
  srcs = [":basic"],
)

pkg_files(
  name = "shared",
  srcs = ["@qt//:shared_files"],
  strip_prefix = strip_prefix.from_pkg()
)

pkg_zip(
  name = "zip_osx",
  srcs = [":basic", "shared"],
  include_runfiles = True,
)
