FROM openresty/openresty:1.25.3.2-3-alpine-fat
RUN opm get ledgetech/lua-resty-http
RUN ln -sf /etc/nginx/rawgithack/rawgithack.conf /etc/nginx/conf.d/default.conf

VOLUME /var/cache/nginx/rawgithack
CMD ["nginx", "-g", "daemon off;"]
