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
    join_paths('src', 'Dialogs', 'ScriptDialog.vala'),
    join_paths('src', 'InfoBars', 'DefaultInfoBar.vala'),
    join_paths('src', 'InfoBars', 'NativeInfoBar.vala'),
    join_paths('src', 'InfoBars', 'NetworkInfoBar.vala'),
    join_paths('src', 'InfoBars', 'PaidInfoBar.vala'),
    join_paths('src', 'Views', 'ErrorView.vala'),
    join_paths('src', 'Views', 'WelcomeView.vala'),
    join_paths('src', 'Widgets', 'BrowserButton.vala'),
    join_paths('src', 'Widgets', 'DownloadsButton.vala'),
    join_paths('src', 'Widgets', 'FindBar.vala'),
    join_paths('src', 'Widgets', 'UrlEntry.vala'),
    join_paths('src', 'Widgets', 'WebView.vala'),
    asresources,
    dependencies: [
        dependency('granite'),
        dependency('gtk+-3.0'),
        dependency('libdazzle-1.0'),
        dependency('webkit2gtk-4.0'),
    ],
    install: true
)

subdir('data')
subdir('po')

meson.add_install_script(join_paths('meson', 'post_install.py'))

