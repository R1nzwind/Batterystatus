project('org.rinzwind.batterystatus', 'vala', 'c', version: '0.0.1')

i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

subdir ('src')
subdir ('po')

install_data (
    join_paths('schema', meson.project_name() + '.gschema.xml'),
    install_dir: join_paths (get_option ('datadir'), 'glib-2.0', 'schemas'),
)

install_data(
    join_paths('data', meson.project_name() + '.desktop'),
    install_dir: join_paths(get_option('datadir'), 'applications')
)

install_data(
    join_paths('data', meson.project_name() + '.appdata.xml'),
    install_dir: join_paths(get_option('datadir'), 'metainfo')
)

meson.add_install_script('post_install.py')