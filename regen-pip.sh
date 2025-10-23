# Increase this on each version update and rerun the script
wget https://raw.githubusercontent.com/pgadmin-org/pgadmin4/REL-9_9/requirements.txt

# https://github.com/flatpak/flatpak-builder-tools/issues/365
cat requirements.txt | grep -v "<= '3.9'" | grep -v sys_platform==\"win32\" > requirements_filtered.txt
sed -i "1 i tomli" requirements_filtered.txt # psycopg-c requires tomli to build
sed -i "1 i greenlet" requirements_filtered.txt # psycopg-c requires greenlet to build
sed -i "1 i flit-core" requirements_filtered.txt # tomli requires flit_core.buildapi to build

uv run flatpak-pip-generator --yaml \
        --requirements-file=requirements_filtered.txt \
        --ignore-pkg bcrypt==5.0.* cryptography==46.0.*

rm requirements.txt
rm requirements_filtered.txt