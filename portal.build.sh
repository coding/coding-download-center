#!/bin/bash

mkdocs build --clean
grep -lr "href='https://fonts.googleapis.com/" ./site | xargs sed -i "s/href='https:\/\/fonts\.googleapis\.com/href='http:\/\/fonts.gmirror.org/g"
