load("@rules_rs//rs:rust_binary.bzl", "rust_binary")

rust_binary(
  name = "qmake",
  srcs = ["src/main.rs"],
  data = ["@qt//:files", "@qt//:lib"],
  rustc_env = {
    "LIB_DIR": "$(location @qt//:lib)"
  },
  visibility = ["//visibility:public"],
)
