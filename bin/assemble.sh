#!/bin/bash
DEBUG=0
MA_WINDOW=181

function usage() {
   echo "  Usage: assemble.sh <experiment>"
   exit 1
}
if [ $# -ne 1 ]; then usage; fi

# get the experiment name from the args
EXP=$1

shopt -s extglob

SCRIPT_NAME=$(basename ${BASH_SOURCE[0]})
SCRIPT_PATH=$(find ${PWD} -name ${SCRIPT_NAME})
SRC_DIR=$(dirname ${SCRIPT_PATH})

if (( DEBUG == 1 )); then echo "\${SRC_DIR} = ${SRC_DIR}"; fi
ROOT_DIR=$(dirname ${SRC_DIR})
if (( DEBUG == 1 )); then echo "\${ROOT_DIR} = ${ROOT_DIR}"; fi
PARENT_DIR=$(dirname ${ROOT_DIR})
if (( DEBUG == 1 )); then echo "\${PARENT_DIR} = ${PARENT_DIR}"; fi
PNG_DIR=${PARENT_DIR}/pngs
if (( DEBUG == 1 )); then echo "\${PNG_DIR} = ${PNG_DIR}"; fi
ISL_PATH=${PARENT_DIR}/islj
if (( DEBUG == 1 )); then echo "\${ISL_PATH} = ${ISL_PATH}"; fi

# Store the current directory so we can return
ORIG_WD=${PWD}
cd ${PARENT_DIR}/data

# H counts
${ISL_PATH}/bin/hcounts-inband.r dPV 3 7 ${EXP} > ${EXP}_hcount-bands.csv
${ISL_PATH}/bin/hcounts-inband.r dPV 14 18 ${EXP} | tail -n 1 >> ${EXP}_hcount-bands.csv
${ISL_PATH}/bin/hcounts-inband.r dCV 0 6 ${EXP} | tail -n 1 >> ${EXP}_hcount-bands.csv
# remove the "[1] " R output.
sed -i 's/\[1\] //g' ${EXP}_hcount-bands.csv
# remove the space the every CSV reader except Processing handles
sed -i 's/, /,/g' ${EXP}_hcount-bands.csv

# Hsolute raw data
${ISL_PATH}/bin/dataperH-inband.r dPV 3 7 ${EXP}
${ISL_PATH}/bin/dataperH-inband.r dPV 14 18 ${EXP}
${ISL_PATH}/bin/dataperH-inband.r dCV 0 6 ${EXP}

# Hsolute moving averages
${SRC_DIR}/hsol_ma.r ${MA_WINDOW} ${EXP}

# Event data
${ISL_PATH}/bin/reduce-event-data-inband.r dPV 3 7 ${EXP}
${ISL_PATH}/bin/reduce-event-data-inband.r dPV 14 18 ${EXP}
${ISL_PATH}/bin/reduce-event-data-inband.r dCV 0 6 ${EXP}

# Body data
${ISL_PATH}/bin/coarse-compartment.r ${EXP}

cd ${ORIG_WD}

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

echo "Running the montages"
for f in ${PNG_DIR}/${EXP}-body-APAP-??????.png
do
  tail=${f#*body-APAP-}
  # tiling is column x row, unfortunately
  #montage ${EXP}-*-${tail} -tile 2x1 -geometry 200x300 -border 1 -bordercolor black -background black ${tail}
  montage ${PNG_DIR}/${EXP}-body-APAP-${tail} \
          ${PNG_DIR}/${EXP}-hsol-APAP-${tail} \
          ${PNG_DIR}/${EXP}-hsol-ALT-${tail} \
          ${PNG_DIR}/${EXP}-body-ALT-${tail} \
          ${PNG_DIR}/${EXP}-hsol-N-${tail} \
          ${PNG_DIR}/${EXP}-hsol-GSH_Depletion-${tail} \
          ${PNG_DIR}/${EXP}-hsol-MitoDD-${tail} \
          ${PNG_DIR}/${EXP}-hsol-nMD-${tail} \
          ${PNG_DIR}/${EXP}-hsol-G-${tail} \
          ${PNG_DIR}/${EXP}-hsol-Repair-${tail} \
          ${PNG_DIR}/${EXP}-nectrig-${tail} \
          ${PNG_DIR}/${EXP}-stressed-${tail} \
          -tile 4x3 -geometry 200x250 -border 1 -background white ${PNG_DIR}/${tail}
          #-tile 4x3 -geometry 200x250 -border 1 -bordercolor black -background 'rbg(235,235,235)' booga.png
done

avconv -pattern_type glob -i "${PNG_DIR}/??????.png" -pix_fmt yuv420p output.mp4

## clean up
rm -rf ${PNG_DIR}

