# Increase this on each version update and rerun the script
wget https://raw.githubusercontent.com/pgadmin-org/pgadmin4/REL-9_12/requirements.txt

# https://github.com/flatpak/flatpak-builder-tools/issues/365
cat requirements.txt | grep -v "<= '3.9'" | grep -v "< '3.10'" | grep -v sys_platform==\"win32\" > requirements_filtered.txt
sed -i "1 i pybind11" requirements_filtered.txt # pillow requires pybind11 to build

# Download latest flatpak-pip-generator.py and run
wget https://raw.githubusercontent.com/flatpak/flatpak-builder-tools/refs/heads/master/pip/flatpak-pip-generator.py
uv run --with pyyaml ./flatpak-pip-generator.py --yaml \
        --requirements-file=requirements_filtered.txt \
        --ignore-pkg bcrypt==5.0.* cryptography==46.0.*

rm requirements.txt
rm requirements_filtered.txt
rm flatpak-pip-generator.py
