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

1. Update both pgAdmin package URLs and SHA256 checksums in `org.pgadmin.pgadmin4.yml`. Keep the server and desktop packages on the same version and Debian distribution.
2. Update `PGADMIN_VERSION` in `regen-pip.sh`, for example from `9_16` to `9_17`, then run `./regen-pip.sh` to regenerate `python3-requirements_filtered.yaml`.
3. Check the generated dependencies for environment-marker omissions. In particular, preserve the manually added `backports.zstd` source described below when the Flatpak runtime still uses Python 3.13.
4. Add the release version, upstream release date and release-notes URL to `org.pgadmin.pgadmin4.metainfo.xml`.
5. Validate and build the update:

```sh
appstreamcli validate --no-net org.pgadmin.pgadmin4.metainfo.xml
flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest org.pgadmin.pgadmin4.yml
flatpak run org.flatpak.Builder build-dir --user --ccache --force-clean --install org.pgadmin.pgadmin4.yml
```

If upstream changes bundled PostgreSQL utilities or the required runtime, update those manifest sources before regenerating dependencies.

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
