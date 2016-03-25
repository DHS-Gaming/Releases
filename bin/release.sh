#!/bin/bash

RELEASE="${1}"
DATESTAMP="${2}"

RELEASE_DIRECTORY="/cygdrive/d/CYGWIN_RELEASES/${RELEASE}/${DATESTAMP}"

SOURCE_UPSTREAM="../Upstream/Altis-4.4r1"
SOURCE_DAH_GAMING="../Altis"

PBO_CONSOLE="/cygdrive/c/Program Files/PBO Manager v.1.4 beta/PBOConsole.exe"

echo "building a release for ${RELEASE} (${DATESTAMP})"

for DIRECTORY in "Altis_Life.Altis" "life_server"; do
  mkdir -pv "${RELEASE_DIRECTORY}/${DIRECTORY}"

  #
  # preseed the directory with upstream files
  #
  rsync -Pavpx --delete \
    "${SOURCE_UPSTREAM}/${DIRECTORY}/." \
    "${RELEASE_DIRECTORY}/${DIRECTORY}/."

  #
  # copy our overlay files into the release
  #
  rsync -Pavpx \
    "${SOURCE_DAH_GAMING}/${DIRECTORY}/." \
    "${RELEASE_DIRECTORY}/${DIRECTORY}/."

  #
  # build the PBO files
  #
  "${PBO_CONSOLE}" \
    -pack "D:\\CYGWIN_RELEASES\\${RELEASE}\\${DATESTAMP}\\${DIRECTORY}" \
          "D:\\CYGWIN_RELEASES\\${RELEASE}\\${DATESTAMP}\\${DIRECTORY}.pbo"

  if [[ "production" == "${RELEASE}" ]]; then
      mkdir -pv "production/${DATESTAMP}"
      rsync -Pavpx \
        "${RELEASE_DIRECTORY}/${DIRECTORY}.pbo" \
        "production/${DATESTAMP}/${DIRECTORY}.pbo"
    fi

done

#
# deploy to betaserver
#
TARGET_DIRECTORY="/home/steam/Steam/steamapps/common/Arma\ 3\ Server"

rsync -Pavpx \
    "${RELEASE_DIRECTORY}/Altis_Life.Altis.pbo" \
      "steam@altisliferpg.xoreaxeax.de:${TARGET_DIRECTORY}/mpmissions/."

rsync -Pavpx \
          "${RELEASE_DIRECTORY}/life_server.pbo" \
                  "steam@altisliferpg.xoreaxeax.de:${TARGET_DIRECTORY}/@life_server/addons/."

#
# restart arma3 on betaserver
#
ssh steam@altisliferpg.xoreaxeax.de -t make -C /home/steam restart

sleep 1

#
# validate the contents so we know we copied everything correctly :)
#
ls -ali "${RELEASE_DIRECTORY}"

echo

sha1sum ${RELEASE_DIRECTORY}/Altis_Life.Altis.pbo
ls -al ${RELEASE_DIRECTORY}/Altis_Life.Altis.pbo
ssh -q steam@altisliferpg.xoreaxeax.de -t sha1sum "${TARGET_DIRECTORY}/mpmissions/Altis_Life.Altis.pbo"
ssh -q steam@altisliferpg.xoreaxeax.de -t ls -al "${TARGET_DIRECTORY}/mpmissions/Altis_Life.Altis.pbo"

echo

sha1sum ${RELEASE_DIRECTORY}/life_server.pbo
ls -al ${RELEASE_DIRECTORY}/life_server.pbo
ssh -q steam@altisliferpg.xoreaxeax.de -t sha1sum "${TARGET_DIRECTORY}/@life_server/addons/life_server.pbo"
ssh -q steam@altisliferpg.xoreaxeax.de -t ls -al "${TARGET_DIRECTORY}/@life_server/addons/life_server.pbo"

exit 0

