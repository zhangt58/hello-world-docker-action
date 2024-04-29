# Qt App Builder Action

This action builds a C/C++ Qt6 app and generate the self-extract run file as a single executable file.

Supported Qt version: 6.7.0, with:

- Qt Charts
- Qt Data Visualization
- Qt Multimedia
- Qt5 Compatibility Module

# Usage

```shell
- uses: zhangt58/qt-app-builder@v1.3
  with:
    # **Required**, Qt project file name
    project_file: <myproj.pro>

    # **Required**, app name, shown in the final package name
    app_name: <myapp>

    # **Required**, executable names separated by space
    # Usually, a single executable is generated, but for a project that contains subprojects,
    # multiple executables are to be generated.
    exec_names: <app1 app2 ...>

    # **Optional**, main executable for multiple executables are to be generated
    # Defaults: the first word of *exec_names*
    main_exec: <app1>

    # **Optional**, version string of the app
    # Defaults: either the latest tag string or the commit sha1 (first 6 letters)
    app_version: <app-version-string>

    # **Optional**, the short description of the app
    # Defaults: 'A Qt app ({{app_name}}) built with qt-app-builder action'
    app_desc: ''

    # **Optional**, the directory path for generated artifacts
    # Defaults: 'dist'
    dist_dir: <folder-path-for-distro>

    # **Optional**, the options for _linuxdeployqt_
    # Defaults: '-bundle-non-qt-libs -no-translations'
    qt_deployer_opts: <linuxdeployqt-options>

    # **Optional**, the options for _makeself_
    # Defaults: '--notemp --nox11 --tar-quietly --xz'
    makeself_opts: <makeself-options>

    # **Optional**, the extra required packages installed via apt
    # Defaults: ''
    extra_requires: ''

    # **Optional**, scripts to execute from the _dist_dir_ after generated binary distro
    # Defaults: ''
    # Hint: Pass multiple lines of scripts after `|`: e.g.
    # post_dist: |
    #   1st command line
    #   2nd command line
    post_dist: ''
```

## Outputs

- `run_filename`: The path of the generated self-extract run file, set `+x` to make it executable.
- `binary_distro`: The path of the binary artifacts for distrobution, e.g. create a software package.
- `app_name`: The name string of the app.
- `app_version`: the version string of the app.