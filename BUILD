load("@rules_rs//rs:rust_binary.bzl", "rust_binary")
load("@cxx_qt_crates//:defs.bzl", "all_crate_deps")

rust_binary(
  name = "cxxqtcmd",
  srcs = ["src/main.rs"],
  deps = all_crate_deps(),
  visibility = ["//visibility:public"]
)

platform(
  name = "windows_ucrt",
  parents = ["@rules_rs//rs/platforms:x86_64-pc-windows-gnullvm"],
  constraint_values = [
    "@llvm//constraints/windows/crt:msvcrt"
  ]
)

platform(
  name = "x86_64-pc-windows-gnullvm",
  visibility = ["//visibility:public"],
  constraint_values = [
    "@platforms//cpu:x86_64", 
    "@platforms//os:windows", 
    "@llvm//constraints/windows/abi:gnullvm", 
    "@llvm//constraints/windows/crt:ucrt",
  ],
)
