#!/bin/bash
for file in *.tif; do
    filename=$(basename "$file")
    filename="${filename%.*}"
    echo "Doing $filename"
    convert "$file" "${filename}.png"
done

