def _bundle_app_impl(ctx):

  pass



bundle_app = rule(
  implementation = _bundle_app_impl,
  attrs = {
    "binary": attr.label(allow_files = True),
    "qt_shared_libs": attr.label(allow_files = True),
    "qt_qml_files": attr.label(allow_files = True),
    "qt_plugin_files": attr.label(allow_files = True),
  }
)
