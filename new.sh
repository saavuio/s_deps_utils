#!/bin/bash
if [ -d dependencies ]; then echo "Already initiated"; exit 1; fi
if [ -z $1 ]; then echo "Provide a name as the first argument"; exit 1; fi
if [ -z $2 ]; then echo "Provide a version as the second argument"; exit 1; fi
SDEP_NAME=$1
SDEP_VERSION=$2

mkdir dependencies

echo "#!/bin/bash
function fetch {
  NAME=\$1
  VERSION=\$2
  if [ -z \$NOCLONE ]; then
    if [ -d \$NAME ]; then
      cd \$SCRIPT_DIR
      # confirm removal
      read -p \"\$NAME will be forcefully removed. Are you sure? \" -n 1 -r; echo
      if [[ \$REPLY =~ ^[Yy]$ ]]; then
        rm -rf \$NAME
      else
        exit 1
      fi
    fi
    git clone --single-branch -b \$VERSION https://github.com/saavuio/\$NAME
  fi
  PROJECT_ROOT_PATH=.. ./\$NAME/scripts/after_fetch.sh
}
function build {
  NAME=\$1
  ./\$NAME/scripts/docker_build.sh
  PROJECT_ROOT_PATH=.. ./\$NAME/scripts/after_build.sh
}
" > dependencies/helpers.sh
chmod +x dependencies/helpers.sh

echo "#!/bin/bash
SCRIPT_DIR=\"\$(cd \"\$(dirname \"\$0\")\" && pwd)\"
cd \$SCRIPT_DIR

. ./helpers.sh

# -- $SDEP_NAME
fetch \"$SDEP_NAME\" \"$SDEP_VERSION\"
build \"$SDEP_NAME\"
" > dependencies/init.sh
chmod +x dependencies/init.sh

# rm self
if [ -f new.sh ]; then rm new.sh; fi
