# icon_sizes = ['16', '24', '32', '48', '64', '128']
icon_sizes = ['48']

foreach i : icon_sizes
    install_data(
        join_paths('icons', i + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i, 'apps'),
        rename: meson.project_name() + '.svg'
    )
    install_data(
        join_paths('icons', i + '.svg'),
        install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', i + 'x' + i + '@2', 'apps'),
        rename: meson.project_name() + '.svg'
    )
endforeach

# install_data(
#     join_paths('icons', 'symbolic.svg'),
#     install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', 'symbolic', 'apps'),
#     rename: meson.project_name() + '.svg'
# )

# install_data (
#     'gschema.xml',
#     install_dir: join_paths (get_option ('datadir'), 'glib-2.0', 'schemas'),
#     rename: meson.project_name () + '.gschema.xml'
# )

install_data (
    'launcher.desktop',
    install_dir: join_paths (get_option ('datadir'), 'applications'),
    rename: meson.project_name () + '.desktop'
)

install_data (
    'appdata.xml',
    install_dir: join_paths (get_option ('datadir'), 'metainfo'),
    rename: meson.project_name () + '.appdata.xml'
)

