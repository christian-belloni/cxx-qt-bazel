load("@rules_rs//rs:rust_binary.bzl", "rust_binary")
load("@cxx-qt-bazel//cxx-qt-bazel:qml_module.bzl", "qml_module")
load("@crates//:defs.bzl", "all_crate_deps")

qml_module(
  name = "qml",
  crate_name = "qtbridge-basic",
  modules = {
    "com.example.basic": glob(["qml/main.qml"]),
  },
  visibility = ["//visibility:public"]
)

rust_binary(
  name = "qtbridge-basic",
  srcs = ["src/main.rs"],
  deps = all_crate_deps() + [
    ":qml",
  ],
)
