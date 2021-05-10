#!/bin/bash
rm -rf dist
npx imba build -HS server.imba
rm dist/server*
mv dist/public/__assets__/app/{*.js,*.css} dist
cat << EOF >> dist/index.html
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no shrink-to-fit=no" />
        <meta name="apple-mobile-web-app-capable" content="yes">
        <meta name="mobile-web-app-capable" content="yes">
        <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
        <meta http-equiv="Pragma" content="no-cache" />
        <meta http-equiv="Expires" content="0" />
        <title>SCHEDULE</title>
        <link rel="stylesheet" href='client.css'>
    </head>
    <body>
        <script type="module" src='client.js'></script>
    </body>
</html>
EOF
rm -rf dist/public
tree dist
npx gh-pages -d dist
