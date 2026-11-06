
load(":toolchain.bzl", "qt_toolchain")

package(default_visibility = ["//visibility:public"])


toolchain_type(name = "toolchain_type")

qt_toolchain(
  name = "osx_qt_osx",
  qmake= "@qt_osx//:qmake",
  rcc = "@qt_osx//:rcc",
  moc = "@qt_osx//:moc",
  lconvert = "@qt_osx//:lconvert",
)

qt_toolchain(
  name = "osx_qt_win_x86",
  qmake= "@qt_osx//:qmake",
  rcc = "@qt_osx//:rcc",
  moc = "@qt_osx//:moc",
  lconvert = "@qt_osx//:lconvert",
)

toolchain(
  name = "osx_qt_toolchain_to_osx",
  exec_compatible_with = ["@platforms//os:osx"],
  target_compatible_with = [
    "@platforms//os:osx", 
    "@platforms//cpu:arm64",
  ],
  toolchain = ":osx_qt_osx",
  toolchain_type = "@cxx-qt-bazel//toolchains:toolchain_type"
)

toolchain(
  name = "osx_qt_toolchain_to_win_x86",
  exec_compatible_with = ["@platforms//os:osx"],
  target_compatible_with = [
    "@platforms//os:windows",
    "@platforms//cpu:x86_64",
  ],
  toolchain = ":osx_qt_win_x86",
  toolchain_type = "@cxx-qt-bazel//toolchains:toolchain_type"
)
