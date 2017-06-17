#!/bin/bash

. ./portal.conf
mkdocs build --clean
# some theme use link css in HTML head
grep -lr "href='https://fonts.googleapis.com/css" ./site/ && (grep -lr "href='https://fonts.googleapis.com/css" ./site/ | xargs sed -i "s/href='https:\/\/fonts\.googleapis\.com\/css/href='https:\/\/fonts\.proxy\.ustclug\.org\/css/g") || echo 'replace nothing'
# some theme use import in css file
grep -lr "//fonts.googleapis.com/css" ./site/css/ && (grep -lr "//fonts.googleapis.com/css" ./site/css/ | xargs sed -i "s/\/\/fonts\.googleapis\.com\/css/\/\/fonts\.proxy\.ustclug\.org\/css/g") || echo 'replace nothing'

# change css file uri, else it will cached by browser
for file in `find ./site/css/ -name '*.css'`; do
    md5=`md5sum $file | awk '{print $1}'`
    filename=`basename $file`
    grep -lr "css/$filename\"" ./site/ && (grep -lr "css/$filename\"" ./site/ | xargs sed -i "s/css\/$filename\"/css\/$filename?md5=$md5\"/g") || echo 'replace nothing'
done

# replace bad link
sed -i "s/edit\/master\/docs\/index.md/edit\/master\/docs\/index.tpl.md/g" ./site/index.html


# use https://github.com/imsun/gitment
awk '
/<\/head>/ {
    print "  <link rel=\"stylesheet\" href=\"https://imsun.github.io/gitment/style/default.css\" />"
}
{ print }
' ./site/index.html > ./site/index.html.tmp
mv ./site/index.html.tmp ./site/index.html

grep -lr "<div id=\"comments\"" ./site/ | xargs sed -i "/<div id=\"comments\"/a \
<script src=\"https://imsun.github.io/gitment/dist/gitment.browser.js\"></script> \
<script> \
var gitment = new Gitment({ \
\"id\": \$(\"#comments\").data(\"thread-key\"), \
\"owner\": \"$gitment_owner\", \
\"repo\": \"$gitment_repo\", \
\"oauth\": { \
\"client_id\": \"$gitment_oauth_client_id\", \
\"client_secret\": \"$gitment_oauth_client_secret\" \
} \
}); \
gitment.render(\"comments\"); \
</script> \
"
