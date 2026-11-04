load("//cxx-qt-bazel/private:osx_repository.bzl", _qt_download_osx = "qt_download_osx")
load("//cxx-qt-bazel/private:win_x86_repository.bzl", _qt_download_win_x86 = "qt_download_win_x86")

qt_download_osx = _qt_download_osx
qt_download_win_x86 = _qt_download_win_x86


ALIAS_TPL = """alias(
  name = "files",
  actual = "@qt_osx//:files"
  visibility = ["//visibility:public"]
)

alias(
  name = "qmake",
  actual = "@qt_osx//:qmake"
  visibility = ["//visibility:public"]
)

alias(
  name = "lib",
  actual = "@qt_osx//:lib",
  visibility = ["//visibility:public"]
)

alias(
  name = "include",
  actual = "@qt_osx//:include",
  visibility = ["//visibility:public"]
)

alias(
  name = "qt_hdrs",
  actual = "@qt_osx//:qt_hdrs",
  visibility = ["//visibility:public"],
)
"""

_TPL = """
alias(
  name = "{name}",
  actual = select({{
    "@platforms//os:osx": "@qt_osx//:{name}",
    "@platforms//os:windows": "@qt_win_x86//:{name}",
  }}) ,
  visibility = ["//visibility:public"],
)
"""

def _qt_stdlib_alias_impl(repo_ctx):
  targets = ["qmake", "qt_hdrs", "include", "lib", "files", "srcs", "qt", "plugins", "qml", "plugin_files", "qml_files"]
  tpl = [ _TPL.format(name = name) for name in targets ]
  tpl = "\n".join(tpl)
  repo_ctx.file("BUILD", content = tpl)

qt_stdlib_alias = repository_rule(
  implementation = _qt_stdlib_alias_impl
)


