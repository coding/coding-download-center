#!/bin/bash

mkdocs build --clean
grep -lr "href='https://fonts.googleapis.com/" ./site/css/ && (grep -lr "href='https://fonts.googleapis.com/" ./site/css/ | xargs sed -i "s/href='https:\/\/fonts\.googleapis\.com/href='http:\/\/fonts\.gmirror\.org/g") || echo 'replace nothing'
grep -lr "//fonts.googleapis.com/" ./site/css/ && (grep -lr "//fonts.googleapis.com/" ./site/css/ | xargs sed -i "s/\/\/fonts\.googleapis\.com/http:\/\/fonts\.gmirror\.org/g") || echo 'replace nothing'
