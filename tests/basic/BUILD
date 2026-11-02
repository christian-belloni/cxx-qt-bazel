load("@rules_rs//rs:rust_binary.bzl", "rust_binary")
load("@cxx-qt-bazel//cxx-qt-bazel:qml_module.bzl", "qml_module")
load("@cxx_qt_crates//:defs.bzl", "all_crate_deps")
load("@rules_cc//cc:cc_library.bzl", "cc_library")
load("@tar.bzl", "mutate", "tar")


qml_module(
  name = "main_qml",
  crate_name = "basic",
  modules = {
    "ui": glob(["qml/main.qml"]),
    "components": glob(["qml/nested/Other.qml"]),
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
  "--cfg", "cxxqt_qt_version_minor=\"12\"",
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
  "--cfg", "cxxqt_qt_version_at_least_6_12=\"true\"",
  "--cfg", "cxxqt_qt_version_at_least_6=\"true\"",
]

# default_rustc_flags = [
#   "--cfg", "cxxqt_qt_version_major=\"6\"",
#   "--cfg", "cxxqt_qt_version_minor=\"12\"",
#   "--cfg", "cxxqt_qt_version_patch=\"0\"",
# ]

rust_binary(
  name = "basic",
  srcs = ["src/main.rs"],
  deps = all_crate_deps() + [
    # "_ntdll",
    "main_qml",
  ],
  # rustc_flags = select({
  #   "@rules_rs//rs/platforms/constraints:windows_msvc": [
  #     "-Ctarget-feature=+crt-static", 
  #   ] + default_rustc_flags,
  #   "//conditions:default": default_rustc_flags,
  # })
)
