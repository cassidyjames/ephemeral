project('com.github.cassidyjames.ephemeral', 'vala', 'c')

gnome = import('gnome')

asresources = gnome.compile_resources (
    'as-resources', join_paths ('data', 'gresource.xml'),
    source_dir: 'data',
    c_name: 'as'
)

executable(
  meson.project_name(),
  'src/Application.vala',
  'src/MainWindow.vala',
  'src/Dialogs/ExternalDialog.vala',
  'src/Widgets/BrowserButton.vala',
  'src/Widgets/UrlEntry.vala',
  'src/Widgets/Welcome.vala',
  asresources,
  dependencies: [
    dependency('granite'),
    dependency('gtk+-3.0'),
    dependency('webkit2gtk-4.0'),
  ],
  install: true
)
subdir('data')

meson.add_install_script('meson/post_install.py')

