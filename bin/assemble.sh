#!/bin/bash
shopt -s extglob

for f in tsa010.rv0x-nectrig-??????.png
do
  tail=${f#*nectrig-}
  # tiling is column x row, unfortunately
  montage tsa010.rv0x-*-${tail} -tile 2x1 -geometry 200x300 ${tail}
done

avconv -pattern_type glob -i '??????.png' -pix_fmt yuv420p output.mp4

rm ??????.png

