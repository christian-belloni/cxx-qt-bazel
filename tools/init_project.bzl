
tpl = """
#!/bin/sh

mkdir -p $1

touch $1/BUILD

echo '''load("@cxx-qt-bazel//cxx-qt-bazel:build_scripts.bzl", "build_scripts")

build_scripts(
  prefix = "{prefix}",
  visibility = ["//visibility:public"],
  crates_hub = "@{crates_hub}",
  rustconv = "rustconv",
)
''' > $1/qt.additive.BUILD

echo '''bazel_dep(name = "cxx.rs", version = "1.0.205")

qt_download = use_extension("@cxx-qt-bazel//cxx-qt-bazel:extensions.bzl", "qt_download")

use_repo(qt_download, "qt", "qt_osx", "qt_win_x86")

register_toolchains(
  "@cxx-qt-bazel//toolchains:all",
)

crate = use_extension("@rules_rs//rs:extensions.bzl", "crate")

rustc_flags = [
  "--cfg", "cxxqt_qt_version_major=\\"6\\"",
  "--cfg", "cxxqt_qt_version_minor=\\"12\\"",
  "--cfg", "cxxqt_qt_version_patch=\\"0\\"",
  "--cfg", "cxxqt_qt_version_at_least_6_1",
  "--cfg", "cxxqt_qt_version_at_least_6_2",
  "--cfg", "cxxqt_qt_version_at_least_6_3",
  "--cfg", "cxxqt_qt_version_at_least_6_4",
  "--cfg", "cxxqt_qt_version_at_least_6_5",
  "--cfg", "cxxqt_qt_version_at_least_6_6",
  "--cfg", "cxxqt_qt_version_at_least_6_7",
  "--cfg", "cxxqt_qt_version_at_least_6_8",
  "--cfg", "cxxqt_qt_version_at_least_6_9",
  "--cfg", "cxxqt_qt_version_at_least_6_10",
  "--cfg", "cxxqt_qt_version_at_least_6_11",
  "--cfg", "cxxqt_qt_version_at_least_6_12",
  "--cfg", "cxxqt_qt_version_at_least_5",
  "--cfg", "cxxqt_qt_version_at_least_6",
  "--cfg", "cxxqt_qt_version_at_least_7",
]

crate.annotation(
  crate = "cxx",
  gen_build_script = "off",
  additive_build_file = "//third_party:qt.additive.BUILD",
  extra_aliased_targets = {{
    "{prefix}_cxx": "{prefix}_cxx",
  }},
  link_deps = ["@{crates_hub}//:{prefix}_cxx"]
)

crate.annotation(
  crate = "cxx-qt",
  additive_build_file = "//third_party:qt.additive.BUILD",
  extra_aliased_targets = {{
    "{prefix}_cxx-qt": "{prefix}_cxx-qt",
  }},
  gen_build_script = "off",
  deps = ["@{crates_hub}//:{prefix}_cxx-qt"],
  rustc_flags = rustc_flags
)

crate.annotation(
  crate = "cxx-qt-lib",
  additive_build_file = "//third_party:qt.additive.BUILD",
  extra_aliased_targets = {{
    "{prefix}_cxx-qt-lib": "{prefix}_cxx-qt-lib",
  }},
  gen_build_script = "off",
  deps = ["@{crates_hub}//:{prefix}_cxx-qt-lib"],
  rustc_flags = rustc_flags,
)

crate.annotation(
  crate = "qtbridge-type-lib",
  gen_build_script = "off",
  additive_build_file = "//third_party:qt.additive.BUILD",
  extra_aliased_targets = {{
    "{prefix}_qtbridge_type_lib": "{prefix}_qtbridge_type_lib",
    "rustconv": "rustconv",
  }},
  deps = ["@{crates_hub}//:{prefix}_qtbridge_type_lib"],
  rustc_flags = rustc_flags,
)

crate.annotation(
  crate = "qtbridge-runtime",
  gen_build_script = "off",
  additive_build_file = "//third_party:qt.additive.BUILD",
  extra_aliased_targets = {{
    "{prefix}_qtbridge_runtime": "{prefix}_qtbridge_runtime",
  }},
  deps = ["@{crates_hub}//:{prefix}_qtbridge_runtime"],
  rustc_flags = rustc_flags,
  patches = ["//third_party:double-free.patch"],
)

crate.annotation(
  crate = "qtbridge-interfaces",
  gen_build_script = "off",
  additive_build_file = "//third_party:qt.additive.BUILD",
  extra_aliased_targets = {{
    "{prefix}_qtbridge_interfaces": "{prefix}_qtbridge_interfaces",
  }},
  deps = ["@{crates_hub}//:{prefix}_qtbridge_interfaces"],
  rustc_flags = rustc_flags,
)

inject_repo(crate, "cxx-qt-bazel")
inject_repo(crate, "qt")
inject_repo(crate, "cxx.rs")
''' > $1/include.MODULE.bazel

echo '''--- src/cpp/dynamicmetaobjectbuilder.cpp	2026-11-03 12:01:45
+++ src/cpp/dynamicmetaobjectbuilder.cpp	2026-11-03 12:01:52
@@ -70,7 +70,11 @@
 }}
 
 DynamicMetaObjectBuilder::~DynamicMetaObjectBuilder()
-{{}}
+{{
+#ifdef __MINGW32__
+        m_mob.release();
+#endif
+}}
 
 void DynamicMetaObjectBuilder::addClassInfo(rust::Str name, rust::Str value)
 {{
@@ -150,7 +154,11 @@
     {{
         std::unique_ptr<QMetaObject, QScopedPointerPodDeleter> metaObject(m_mob->toMetaObject());
         m_data->setMetaObject(std::move(metaObject));
+#ifdef __MINGW32__
+        m_mob.release();
+#else
         m_mob.reset();
+#endif
     }}
     else
     {{

''' > $1/double-free.patch

echo "Project generation successfull, add:\n"
echo "  include(\\"//third_party:include.MODULE.bazel\\")\n"
echo "to your MODULE.bazel"
"""


def _qtbridge_project_impl(ctx):
  script = ctx.actions.declare_file(ctx.label.name)
  script_template = tpl.format(
    prefix = ctx.attr.prefix,
    crates_hub = ctx.attr.crates_hub
  )
  ctx.actions.write(script, script_template, is_executable = True)

  return DefaultInfo(executable = script)

qtbridge_project = rule(
  implementation = _qtbridge_project_impl,
  attrs = {
    "prefix": attr.string(mandatory = True),
    "crates_hub": attr.string(mandatory = True),
    "_build": attr.label(allow_single_file = True, default = "BUILD")
  },
  executable = True,
)
