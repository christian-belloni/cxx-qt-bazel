load(":repository.bzl","qt_download_osx", "qt_download_win_x86", "qt_stdlib_alias")




def _qt_download_impl(_mod_ctx):
  qt_download_osx(
    name = "qt_osx",
  )
  qt_download_win_x86(
    name = "qt_win_x86",
  )
  qt_stdlib_alias(
    name = "qt",
  )

qt_download = module_extension(
  implementation = _qt_download_impl
)
