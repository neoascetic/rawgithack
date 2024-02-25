FROM openresty/openresty:1.13.6.2-1-alpine-fat
RUN opm get ledgetech/lua-resty-http
RUN <<EOF
ln -sf /etc/nginx/rawgithack/rawgithack.conf /etc/nginx/conf.d/default.conf
mkdir -p /var/cache/nginx/rawgithack_patrons
chown nobody:nobody /var/cache/nginx/rawgithack_patrons
EOF

VOLUME /var/cache/nginx/rawgithack
VOLUME /var/cache/nginx/rawgithack_patrons
CMD ["nginx", "-g", "daemon off;"]
