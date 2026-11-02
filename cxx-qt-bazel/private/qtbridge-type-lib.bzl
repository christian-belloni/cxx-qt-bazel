load("@cxx.rs//tools/bazel:rust_cxx_bridge.bzl", "rust_cxx_bridge")
load("@rules_cc//cc:cc_library.bzl", "cc_library")

bridge_files = [
  "src/core/qmetaobject/mod.rs",
  "src/core/qmetatype/mod.rs",
  "src/core/qmetatypeinterface/mod.rs",
  "src/core/qobject/mod.rs",
  "src/testlib/qsignalspy/mod.rs",
]

cpp_files = [
  "src/core/qmetatype/cpp/qmetatype.cpp",
  "src/core/qmetatypeinterface/cpp/qmetatypeinterface.cpp",
  "src/core/qobject/cpp/qobject.cpp",
  "src/testlib/qsignalspy/cpp/qsignalspy.cpp",
]

def qtbridge_type_lib(*, name, visibility = [], cxx_qt_lib, rustconv_lbl):
  cc_library(
    name = rustconv_lbl,
    includes = ["src"],
    hdrs = ["src/rustconv.h"],
    visibility = ["//visibility:public"],
  )
  
  [
  rust_cxx_bridge(
    name = src.replace(".rs", "-cc"),
    src = src,
    deps = ["_cc_files_" + name, cxx_qt_lib],
  )
    for src in bridge_files
  ]
  
  cc_library(
    name = name,
    deps = [ src.replace(".rs", "-cc") for src in bridge_files ],
    visibility = visibility,
    linkstatic = True,
    alwayslink = True,
  )
  
  cc_library(
    name = "_cc_files_" + name,
    srcs = cpp_files,
    hdrs = native.glob(["**/*.h"], allow_empty = True),
    include_prefix = "qtbridge-type-lib",
    deps = [
      "@cxx.rs//:core", 
      rustconv_lbl, 
      "@qt//:qt",
      "@qt//:qt_hdrs",
    ],
    alwayslink = True,
    linkstatic = True,
  )
