#/usr/bin/env bash

# For more information see:
# * https://unicode.org/ucd/
# * https://www.unicode.org/reports/tr44/tr44-28.html
# * https://www.unicode.org/reports/tr44/tr44-28.html#UnicodeData.txt

mkdir -p data
pushd data

curl http://www.unicode.org/Public/UCD/latest/ReadMe.txt -o ReadMe.txt

mkdir -p charts
pushd charts
curl https://www.unicode.org/Public/UCD/latest/charts/Readme.txt -o Readme.txt
curl https://www.unicode.org/Public/UCD/latest/charts/CodeCharts.pdf -o CodeCharts.pdf
popd

curl https://www.unicode.org/Public/UCD/latest/ucd/UCD.zip -o ucd.zip
unzip -d ucd ucd.zip

curl https://www.unicode.org/Public/UCD/latest/ucd/Unihan.zip -o Unihan.zip

popd


