#!/bin/bash
shopt -s extglob
SRC_DIR=$(dirname ${BASH_SOURCE[0]})
ISL_PATH="${SRC_DIR}/../../islj"

# H counts

# Hsolute raw data
${ISL_PATH}/bin/dataperH-inband.r dCV 0 6 tsa010.rv0x

# Hsolute moving averages
${SRC_DIR}/hsol_ma.r ${MA_WINDOW} tsa010.rv0x

# run hsol sketches
/usr/local/processing-3.5.3/processing-java --sketch=/home/gepr/ucsf/triviz/triviz/sketches/hsol_bands --run false true 1  # ALT
/usr/local/processing-3.5.3/processing-java --sketch=/home/gepr/ucsf/triviz/triviz/sketches/hsol_bands --run false true 2  # APAP
/usr/local/processing-3.5.3/processing-java --sketch=/home/gepr/ucsf/triviz/triviz/sketches/hsol_bands --run false true 3  # G
/usr/local/processing-3.5.3/processing-java --sketch=/home/gepr/ucsf/triviz/triviz/sketches/hsol_bands --run false true 4  # GSH
/usr/local/processing-3.5.3/processing-java --sketch=/home/gepr/ucsf/triviz/triviz/sketches/hsol_bands --run false true 6  # MitoDD
/usr/local/processing-3.5.3/processing-java --sketch=/home/gepr/ucsf/triviz/triviz/sketches/hsol_bands --run false true 7  # N
/usr/local/processing-3.5.3/processing-java --sketch=/home/gepr/ucsf/triviz/triviz/sketches/hsol_bands --run false true 8  # nMD
/usr/local/processing-3.5.3/processing-java --sketch=/home/gepr/ucsf/triviz/triviz/sketches/hsol_bands --run false true 10 # Repair

# run event sketches
/usr/local/processing-3.5.3/processing-java --sketch=/home/gepr/ucsf/triviz/triviz/sketches/event_bands --run false true 10800 nectrig
/usr/local/processing-3.5.3/processing-java --sketch=/home/gepr/ucsf/triviz/triviz/sketches/event_bands --run false true 10800 stressed

# run body sketches
/usr/local/processing-3.5.3/processing-java --sketch=/home/gepr/ucsf/triviz/triviz/sketches/body_mouse --run true true 1 # APAP
/usr/local/processing-3.5.3/processing-java --sketch=/home/gepr/ucsf/triviz/triviz/sketches/body_mouse --run false true 6 # ALT


rm -rf pngs
mkdir pngs
mv $(find sketches -name "*.png") pngs

for f in tsa010.rv0x-body-APAP-??????.png
do
  tail=${f#*body-APAP-}
  # tiling is column x row, unfortunately
  #montage tsa010.rv0x-*-${tail} -tile 2x1 -geometry 200x300 -border 1 -bordercolor black -background black ${tail}
  montage tsa010.rv0x-body-APAP-${tail} \
          tsa010.rv0x-hsol-APAP-${tail} \
          tsa010.rv0x-hsol-ALT-${tail} \
          tsa010.rv0x-body-ALT-${tail} \
          tsa010.rv0x-hsol-N-${tail} \
          tsa010.rv0x-hsol-GSH_Depletion-${tail} \
          tsa010.rv0x-hsol-MitoDD-${tail} \
          tsa010.rv0x-hsol-nMD-${tail} \
          tsa010.rv0x-hsol-G-${tail} \
          tsa010.rv0x-hsol-Repair-${tail} \
          tsa010.rv0x-nectrig-${tail} \
          tsa010.rv0x-stressed-${tail} \
          -tile 4x3 -geometry 200x250 -borderwidth 1 -background black ${tail}
          #-tile 4x3 -geometry 200x250 -border 1 -bordercolor black -background 'rbg(235,235,235)' booga.png
done

avconv -pattern_type glob -i '??????.png' -pix_fmt yuv420p output.mp4

# rm ??????.png

