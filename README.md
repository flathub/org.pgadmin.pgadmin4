# pgAdmin Flatpak

This project uses [uv](https://docs.astral.sh/uv/getting-started/installation/). Make sure to have it installed.

```sh
uv venv
source .venv/bin/activate
uv pip install requirements-parser packaging
```

You can regenerate pip dependencies with the script `regen-pip.sh`, but you will need to have `krb5-config` and `libpq-devel` installed on your system due to a wheel needing it.

```sh
./regen-pip.sh
```

Build flatpak:

```sh
# Install flatpak build dependencies
# Please check org.pgadmin.pgadmin4.yml for the exact version required e.g. 24.08
flatpak install org.electronjs.Electron2.BaseApp/x86_64/24.08 org.freedesktop.Sdk/x86_64/24.08 org.flatpak.Builder

flatpak run org.flatpak.Builder build-dir --user --ccache --force-clean --install org.pgadmin.pgadmin4.yml
```

Then you can run it via the command line:

```sh
flatpak run org.pgadmin.pgadmin4
```

or just search for the installed app on your system

> [!Important]
> If you get `No matching distribution found for backports.zstd; python_version < "3.14"` from `python3-Flask-Compress` while building the Flatpak, add the dependency manually. Grab the download URL and SHA256 from the [backports.zstd PyPI](https://pypi.org/project/backports.zstd/) "Download files" section and include them in your sources. This could happen with `python3-google-api-python-client` and its dependency `cachetools`.

```yaml
...
- name: python3-Flask-Compress
  buildsystem: simple
  build-commands:
  - pip3 install --verbose --exists-action=i --no-index --find-links="file://${PWD}"
    --prefix=${FLATPAK_DEST} "Flask-Compress==1.*" --no-build-isolation
  sources:
  - type: file # add this
    url: <backports.zstd-download-url-from-pypi> # add this
    sha256: <backports.zstd-sha256-hash-from-pypi> # add this
  ...
...
```
