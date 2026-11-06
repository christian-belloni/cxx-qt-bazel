QtToolchainInfo = provider(
  fields = ["qmake", "rcc", "cxxqtbuild", "lconvert", "moc"]
)

def _qt_toolchain_impl(ctx):
  return platform_common.ToolchainInfo(
    qtinfo = QtToolchainInfo(
      qmake = ctx.attr.qmake[DefaultInfo],
      rcc = ctx.attr.rcc[DefaultInfo],
      lconvert = ctx.attr.lconvert[DefaultInfo],
      moc = ctx.attr.moc[DefaultInfo],
      cxxqtbuild = ctx.attr.cxxqtbuild[DefaultInfo],
    )
  )

qt_toolchain = rule(
  implementation = _qt_toolchain_impl,
  attrs = {
    "qmake": attr.label(executable = True, mandatory = True, cfg = "exec"),
    "rcc": attr.label(executable = True, mandatory = True, cfg = "exec"),
    "lconvert": attr.label(executable = True, mandatory = True, cfg = "exec"),
    "moc": attr.label(executable = True, mandatory = True, cfg = "exec"),
    "cxxqtbuild": attr.label(executable = True, default = "@cxx-qt-bazel//:cxxqtcmd", cfg = "exec")
  }
)
