downloader_lib_sources = files(
  'downloader.vala',
  'manager.vala',
  'result.vala',
)

vala_downloader_deps = [
  dependency('glib-2.0'),
  dependency('gio-2.0'),
  dependency('libsoup-3.0'),
  dependency('gee-0.8')
]

vala_downloader_lib = shared_library(
  'vala-downloader-lib',
  downloader_lib_sources,
  dependencies: vala_downloader_deps,
  install: true,
  vala_vapi: 'vapi/vala-downloader-lib.vapi',
  vala_header: 'vala-downloader-lib.h'
)

vala_downloader_dep = declare_dependency(
  link_with: vala_downloader_lib,
  include_directories: include_directories('.')
)

pkg = import('pkgconfig')
pkg.generate(
  vala_downloader_lib,
  version: meson.project_version(),
  name: meson.project_name(),
  filebase: meson.project_name(),
  description: 'Vala Downloader Library.'
)
