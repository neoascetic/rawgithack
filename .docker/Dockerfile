FROM openresty/openresty:1.13.6.2-1-alpine-fat
RUN opm get ledgetech/lua-resty-http
COPY rawgithack.conf rawgithack.lua web/*.html /etc/nginx/rawgithack/

RUN <<EOF
rm /etc/nginx/conf.d/default.conf
ln -sf /etc/nginx/rawgithack/rawgithack.conf /etc/nginx/conf.d/rawgithack.conf
cd /etc/nginx/rawgithack/
mkdir www
for page in *.html; do
  if [ "$page" != "base.html" ]; then
    sed -e '/PLACEHOLDER/{' -e "r $page" -e 'd}' base.html > www/$page
  fi
done
rm *.html
mkdir -p /var/cache/nginx/rawgithack_patrons
chown nobody:nobody /var/cache/nginx/rawgithack_patrons
EOF

VOLUME /var/cache/nginx/rawgithack
VOLUME /var/cache/nginx/rawgithack_patrons
CMD ["nginx", "-g", "daemon off;"]
