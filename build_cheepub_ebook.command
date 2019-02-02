#!/bin/sh
set -eu
umask 0022
PAHT='/usr/local/bin:/usr/bin:/bin'
IFS=$(printf ' \t\n_'); IFS=${IFS%_}
export IFS PATH

PATH_MYSELF=$(dirname "$0")
NORMALIZED_PAHT_MYSELF=$(cd -P "$PATH_MYSELF"; pwd)

cd "$NORMALIZED_PAHT_MYSELF"
mkdir -p source

{
cat \
./manuscripts/main.txt \
./manuscripts/back-matter.txt
} > ./source/ukixa.txt

cat ./source/ukixa.txt |
./bin/u2c_tatechuyoko |
./bin/u2c_midashi |
./bin/u2c_jisage |
./bin/u2c_ruby |
./bin/u2c_image > ./source/cheepub.txt

{
cat \
./manuscripts/front-matter.md \
./source/cheepub.txt
} |
./bin/u2c_ff |
./bin/u2c_notes |
./bin/u2c_meta  > ./source/content.md

cp ./manuscripts/*.gif ./source && true
cp ./manuscripts/*.bmp ./source && true
cp ./manuscripts/*.jpg ./source && true
cp ./manuscripts/*.jpeg ./source && true
cp ./manuscripts/*.png ./source && true
cp ./manuscripts/*.svg ./source && true
cp ./manuscripts/*.opf ./source && true
cp ./manuscripts/*.css ./source && true

cheepub -o source.epub ./source/content.md

rm -r source
unzip source.epub
rm -r META-INF mimetype
mv OEBPS source
cp ./manuscripts/style.css ./source/ && true
cp ./manuscripts/titlepage.xhtml ./source/ && true
cp ./manuscripts/colophon.xhtml ./source/ && true

zip -r ./source.zip ./source
