#!/bin/bash

# Animated QR code generation script for large files.
# Syntax:
# ./qr.sh <filename>

# Tweakable parameters
readonly CHUNK_SIZE=1000
readonly ANIMATION_DELAY=50
readonly ANIMATION_LOOP=0
readonly OUTPUT_FILENAME=code
readonly KEEP_TEMP=false
readonly SHOW_OUTPUT=true

size=$(stat -c%s $1)
if [ $size -gt 2953 ]
then
    echo "[INFO] Splitting file $1"
    mkdir -p data
    cd data/
    split -b$CHUNK_SIZE --additional-suffix=.data --suffix-length=5 ../$1
    echo "[INFO] $(ls -l *.data | wc -l) temp files are created."
    count=0
    for x in *.data; do
        ((count=count+1))
        qrencode -r $x -8 -o code$count.png
    done
    echo "[INFO] $(ls -l *.png | wc -l) QR codes generated."
    convert -delay $ANIMATION_DELAY -loop $ANIMATION_LOOP -dispose previous *.png ../$OUTPUT_FILENAME.gif
    echo "[INFO] GIF file created."
    cd ..
    if [ $KEEP_TEMP = false ] ; then
        rm -r data/
    fi
    if [ $SHOW_OUTPUT = true ] ; then
        animate $OUTPUT_FILENAME.gif
    fi
else
    qrencode -r $1 -8 -o $OUTPUT_FILENAME.png
    echo "[INFO] QR code generated."
    if [ $SHOW_OUTPUT = true ] ; then
        xdg-open $OUTPUT_FILENAME.png
    fi
fi