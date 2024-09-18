#!/bin/sh

envsubst '${BACKEND_URL}' < /etc/nginx/templates/nginx.conf.template > /etc/nginx/nginx.conf

npm install -g @angular/cli
ng build
npm i -g angular-http-server
cd .
echo "module.exports = {
    proxy: [
        {
            forward: [\"api/\"],
            target: \"localhost:4292\",
            protocol: \"http\",
        }
    ],
}" > proxy.js


sudo su
nohup angular-http-server -p 80 --config proxy.js &
nginx -g 'daemon off;'
