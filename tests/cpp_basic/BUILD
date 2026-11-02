load("@rules_cc//cc:cc_binary.bzl", "cc_binary")
load("@rules_cc//cc:cc_shared_library.bzl", "cc_shared_library")

cc_binary(
  name = "cpp_basic",
  srcs = ["src/main.cpp"],
  deps = [
    "@qt//:qt", 
    "//tests/basic:main_qml",
  ]
)
