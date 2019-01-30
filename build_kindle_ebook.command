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
./bin/u2a_meta |
./bin/u2a_tatechuyoko |
./bin/u2a_jisage |
./bin/u2a_midashi |
./bin/u2a_ruby |
./bin/u2a_image > ./source/aozora.txt

{
cat \
./manuscripts/front-matter.txt \
./source/aozora.txt
} |
./bin/u2a_ff > ./source/content-utf8.txt

cat ./source/content-utf8.txt |
./bin/u2a_sjis > ./source/content.txt

cp ./manuscripts/*.gif ./source && true
cp ./manuscripts/*.bmp ./source && true
cp ./manuscripts/*.jpg ./source && true
cp ./manuscripts/*.jpeg ./source && true
cp ./manuscripts/*.png ./source && true
cp ./manuscripts/*.svg ./source && true
cp ./manuscripts/*.opf ./source && true
cp ./manuscripts/*.css ./source && true

#exit

aozora2html --use-jisx0213 --use-unicode ./source/content.txt > ./source/content-sjis.html
cat ./source/content-sjis.html |
./bin/a2k_skip_warning > ./source/content-utf8.html
./bin/a2k_utf8 ./source/content-utf8.html
./bin/a2k_clean ./source/content-utf8.html
cat ./source/content-utf8.html | ./bin/a2k_toc > ./source/toc.html.tmp
./bin/a2k_instoc ./source/content-utf8.html ./source/toc.html.tmp
cat ./source/content-utf8.html |
./bin/a2k_notes |
sed 's/¥/\\/g' > ./source/content.html

rm ./source/*.txt ./source/*.tmp*
rm ./source/content-sjis.html ./source/content-utf8.html

zip -r ./source.zip ./source
