#!/bin/bash
shopt -s extglob
SRC_DIR=${PWD}/$(dirname ${BASH_SOURCE[0]})
ROOT_DIR=$(dirname ${SRC_DIR})
PNG_DIR=${ROOT_DIR}/pngs
PARENT_DIR=$(dirname ${ROOT_DIR})
ISL_PATH=${PARENT_DIR}/islj

# H counts

# Hsolute raw data
${ISL_PATH}/bin/dataperH-inband.r dCV 0 6 tsa010.rv0x

# Hsolute moving averages
${SRC_DIR}/hsol_ma.r ${MA_WINDOW} tsa010.rv0x

# run hsol sketches
# arguments <show cycle> <take snaps> <column> <use MA> <data directory>
/usr/local/processing-3.5.3/processing-java --sketch=/home/gepr/ucsf/triviz/triviz/sketches/hsol_bands --run \
                                            false true 1 false ${PARENT_DIR}/data # ALT
/usr/local/processing-3.5.3/processing-java --sketch=/home/gepr/ucsf/triviz/triviz/sketches/hsol_bands --run \
                                            false true 2 true ${PARENT_DIR}/data # APAP
/usr/local/processing-3.5.3/processing-java --sketch=/home/gepr/ucsf/triviz/triviz/sketches/hsol_bands --run \
                                            false true 3 true ${PARENT_DIR}/data # G
/usr/local/processing-3.5.3/processing-java --sketch=/home/gepr/ucsf/triviz/triviz/sketches/hsol_bands --run \
                                            false true 4 true ${PARENT_DIR}/data # GSH
/usr/local/processing-3.5.3/processing-java --sketch=/home/gepr/ucsf/triviz/triviz/sketches/hsol_bands --run \
                                            false true 6 true ${PARENT_DIR}/data # MitoDD
/usr/local/processing-3.5.3/processing-java --sketch=/home/gepr/ucsf/triviz/triviz/sketches/hsol_bands --run \
                                            false true 7 true ${PARENT_DIR}/data # N
/usr/local/processing-3.5.3/processing-java --sketch=/home/gepr/ucsf/triviz/triviz/sketches/hsol_bands --run \
                                            false true 8 true ${PARENT_DIR}/data # nMD
/usr/local/processing-3.5.3/processing-java --sketch=/home/gepr/ucsf/triviz/triviz/sketches/hsol_bands --run \
                                            false true 10 true ${PARENT_DIR}/data # Repair

# run event sketches
# arguments <show cycle> <take snaps> <max cycle> <event type> <data directory>
/usr/local/processing-3.5.3/processing-java --sketch=/home/gepr/ucsf/triviz/triviz/sketches/event_bands --run \
                                            false true 10800 nectrig ${PARENT_DIR}/data
/usr/local/processing-3.5.3/processing-java --sketch=/home/gepr/ucsf/triviz/triviz/sketches/event_bands --run \
                                            false true 10800 stressed ${PARENT_DIR}/data

# run body sketches
# arguments <show cycle> <take snaps> <column> <data directory>
/usr/local/processing-3.5.3/processing-java --sketch=/home/gepr/ucsf/triviz/triviz/sketches/body_mouse --run \
                                            true true 1 ${PARENT_DIR}/data # APAP
/usr/local/processing-3.5.3/processing-java --sketch=/home/gepr/ucsf/triviz/triviz/sketches/body_mouse --run \
                                            false true 6 ${PARENT_DIR}/data # ALT

rm -rf ${PNG_DIR}
mkdir ${PNG_DIR}
mv $(find ${ROOT_DIR}/sketches -name "*.png") ${PNG_DIR}/

for f in ${PNG_DIR}/tsa010.rv0x-body-APAP-??????.png
do
  tail=${f#*body-APAP-}
  # tiling is column x row, unfortunately
  #montage tsa010.rv0x-*-${tail} -tile 2x1 -geometry 200x300 -border 1 -bordercolor black -background black ${tail}
  montage ${PNG_DIR}/tsa010.rv0x-body-APAP-${tail} \
          ${PNG_DIR}/tsa010.rv0x-hsol-APAP-${tail} \
          ${PNG_DIR}/tsa010.rv0x-hsol-ALT-${tail} \
          ${PNG_DIR}/tsa010.rv0x-body-ALT-${tail} \
          ${PNG_DIR}/tsa010.rv0x-hsol-N-${tail} \
          ${PNG_DIR}/tsa010.rv0x-hsol-GSH_Depletion-${tail} \
          ${PNG_DIR}/tsa010.rv0x-hsol-MitoDD-${tail} \
          ${PNG_DIR}/tsa010.rv0x-hsol-nMD-${tail} \
          ${PNG_DIR}/tsa010.rv0x-hsol-G-${tail} \
          ${PNG_DIR}/tsa010.rv0x-hsol-Repair-${tail} \
          ${PNG_DIR}/tsa010.rv0x-nectrig-${tail} \
          ${PNG_DIR}/tsa010.rv0x-stressed-${tail} \
          -tile 4x3 -geometry 200x250 -borderwidth 1 -background black ${PNG_DIR}/${tail}
          #-tile 4x3 -geometry 200x250 -border 1 -bordercolor black -background 'rbg(235,235,235)' booga.png
done

avconv -pattern_type glob -i '${PNG_DIR}/??????.png' -pix_fmt yuv420p output.mp4

# rm ??????.png

