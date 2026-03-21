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

## Updating pgAdmin

1. Confirm the new version is available in the [Ubuntu Plucky package repository](https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/plucky/dists/pgadmin4/main/binary-amd64/). The manifest cannot use an upstream release until both its `pgadmin4-server` and `pgadmin4-desktop` packages are present there.
2. Update both package URLs and SHA256 checksums in `org.pgadmin.pgadmin4.yml`. The checksums are listed in the repository's [`Packages` index](https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/plucky/dists/pgadmin4/main/binary-amd64/Packages).
3. Add the release to `org.pgadmin.pgadmin4.metainfo.xml`, including its release date and the upstream release-notes URL as the other releases.
4. Update the release branch in `regen-pip.sh`, then regenerate the Python sources. Keep `bcrypt` and `cryptography` in `--ignore-pkg` because the manifest provides compatible wheels for them separately:

```sh
./regen-pip.sh
```

5. Review all generated dependency changes, then validate the metadata and manifest:

```sh
appstreamcli validate --no-net org.pgadmin.pgadmin4.metainfo.xml
flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest org.pgadmin.pgadmin4.yml
```

6. Build and install the updated Flatpak before submitting the change:

```sh
flatpak run org.flatpak.Builder build-dir --user --ccache --force-clean --install org.pgadmin.pgadmin4.yml
flatpak run org.pgadmin.pgadmin4
```

Build flatpak:

```sh
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
# python3-requirements_filtered.yaml

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
