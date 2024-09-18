#!/bin/sh

envsubst '${BACKEND_URL}' < /etc/nginx/templates/nginx.conf.template > /etc/nginx/nginx.conf

nginx -g 'daemon off;'
