test_env = environment()
test_sources = files(
  'main.vala',
  'example_test.vala',
  'download_async_local_server_test.vala',
  'download_sync_local_server_test.vala',
  'download_sync_not_found_test.vala',
  'download_sync_internal_error_test.vala',
  'queue_test.vala',
)


test_exe = executable('tests',
  test_sources,
  dependencies: vala_downloader_deps,
  link_with: vala_downloader_lib,
  include_directories: [include_directories('../src')],
  vala_args: ['--target-glib=2.58'],
)

test('Unit Tests', test_exe, env: test_env, protocol: 'tap')

