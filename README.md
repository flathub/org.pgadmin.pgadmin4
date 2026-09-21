# pgAdmin Flatpak

This project uses [uv](https://docs.astral.sh/uv/getting-started/installation/). Make sure to have it installed.

You can regenerate pip dependencies with the script `regen-pip.sh`, but you will need to have `krb5-config` and `libpq-devel` installed on your system due to a wheel needing it.

The script uses Python 3.13 to match Freedesktop 25.08 and lets uv provide the generator's Python dependencies, including pip. On Debian, install `libkrb5-dev`, `libpq-dev`, and `wget` first.

```sh
./regen-pip.sh
```

## Updating pgAdmin

1. Update both pgAdmin package URLs and SHA256 checksums in `org.pgadmin.pgadmin4.yml`. Keep the server and desktop packages on the same version and Debian distribution.
2. Update `PGADMIN_VERSION` in `regen-pip.sh`, for example from `9_16` to `9_17`, then run `./regen-pip.sh` to regenerate `python3-requirements_filtered.yaml`.
3. Check the generated dependencies for environment-marker omissions, including `backports.zstd` on Python 3.13. Fix the generator inputs or options in `regen-pip.sh` and rerun it if needed. Do not edit `python3-requirements_filtered.yaml` manually.
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

The generator runs with `--ignore-installed setuptools` so the generated module installs setuptools into `/app` without trying to uninstall the SDK's read-only copy. The `--ignore-pkg bcrypt,cryptography` option skips their standalone modules because `org.pgadmin.pgadmin4.yml` installs those packages from wheels.
