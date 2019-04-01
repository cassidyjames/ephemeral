project('com.github.cassidyjames.ephemeral', 'vala', 'c')

gnome = import('gnome')
i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()), language:'c')

asresources = gnome.compile_resources (
    'as-resources', join_paths ('data', 'gresource.xml'),
    source_dir: 'data',
    c_name: 'as'
)

executable(
    meson.project_name(),
    join_paths('src', 'Application.vala'),
    join_paths('src', 'MainWindow.vala'),
    join_paths('src', 'Dialogs', 'CustomSearchDialog.vala'),
    join_paths('src', 'Dialogs', 'ExternalDialog.vala'),
    join_paths('src', 'Dialogs', 'PreferencesDialog.vala'),
    join_paths('src', 'Views', 'ErrorView.vala'),
    join_paths('src', 'Views', 'WelcomeView.vala'),
    join_paths('src', 'Widgets', 'BrowserButton.vala'),
    join_paths('src', 'Widgets', 'DefaultInfoBar.vala'),
    join_paths('src', 'Widgets', 'NativeInfoBar.vala'),
    join_paths('src', 'Widgets', 'NetworkInfoBar.vala'),
    join_paths('src', 'Widgets', 'PaidInfoBar.vala'),
    join_paths('src', 'Widgets', 'UrlEntry.vala'),
    asresources,
    dependencies: [
        dependency('granite'),
        dependency('gtk+-3.0'),
        dependency('webkit2gtk-4.0'),
    ],
    install: true
)

subdir('data')
subdir('po')

meson.add_install_script(join_paths('meson', 'post_install.py'))

