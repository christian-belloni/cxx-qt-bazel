load("@cxx.rs//tools/bazel:rust_cxx_bridge.bzl", "rust_cxx_bridge")
load("@rules_cc//cc:cc_library.bzl", "cc_library")

bridge_files = [
  "src/dynamicmetaobjectbuilder.rs",
  "src/dynamicmetaobjectdata.rs",
  "src/qmetatypeget.rs",
  "src/qmlprivate.rs",
  "src/qqmllistproperty.rs",
  "src/qresource.rs",
  "src/registry.rs",
  "src/rustobjectgetter.rs",
  "src/qthreadhandle.rs",
]

def qtbridge_runtime(*, name, visibility = [], rustconv, crates_hub, qtbridge_type_lib):
  [
  rust_cxx_bridge(
    name = src.replace(".rs", "-cc"),
    src = src,
    deps = [
      "_cc_files_" + name,
      "@qt//:qt",
    ],
  )
    for src in bridge_files
  ]
  
  cc_library(
    name = "_generated_" + name,
    srcs = [ src + ".cc" for src in bridge_files ],
    hdrs = [src + ".h" for src in bridge_files],
    deps = [
      "_cc_files_" + name,
      "@qt//:qt",
    ],
    include_prefix = "qtbridge-runtime",
  )
  
  cc_library(
    name = name,
    srcs = native.glob(["src/cpp/**/*.cpp"], allow_empty = True),
    deps = [ 
      "_generated_" + name,
      "@qt//:qt",
    ],
    visibility = visibility,
    alwayslink = True,
    linkstatic = True,
  )
  
  cc_library(
    name = "_cc_files_" + name,
    hdrs = native.glob(["**/*.h"], allow_empty = True),
    includes = ["src", "."],
    include_prefix = "qtbridge-runtime",
    deps = [
      crates_hub + "//:" + rustconv,
      "@cxx.rs//:core", 
      "@qt//:qt",
      "@qt//:qt_hdrs",
      crates_hub + "//:" + qtbridge_type_lib
    ],
  )
