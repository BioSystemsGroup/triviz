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


# for f in tsa010.rv0x-nectrig-??????.png
# do
#   tail=${f#*nectrig-}
#   # tiling is column x row, unfortunately
#   montage tsa010.rv0x-*-${tail} -tile 2x1 -geometry 200x300 ${tail}
# done

# avconv -pattern_type glob -i '??????.png' -pix_fmt yuv420p output.mp4

# rm ??????.png

