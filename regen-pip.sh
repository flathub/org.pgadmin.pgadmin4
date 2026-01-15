# Increase this on each version update and rerun the script
wget https://raw.githubusercontent.com/pgadmin-org/pgadmin4/REL-9_11/requirements.txt

# https://github.com/flatpak/flatpak-builder-tools/issues/365
cat requirements.txt | grep -v "<= '3.9'" | grep -v "< '3.10'" | grep -v sys_platform==\"win32\" > requirements_filtered.txt
sed -i "1 i pybind11" requirements_filtered.txt # pillow requires pybind11 to build

uv run flatpak-pip-generator --yaml \
        --requirements-file=requirements_filtered.txt \
        --ignore-pkg bcrypt==5.0.* cryptography==46.0.*

rm requirements.txt
rm requirements_filtered.txt