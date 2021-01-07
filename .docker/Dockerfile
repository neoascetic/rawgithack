FROM openresty/openresty:1.13.6.2-1-alpine
COPY rawgithack.conf rawgithack.lua /etc/nginx/rawgithack/
COPY index.html /etc/nginx/rawgithack/www/
RUN rm /etc/nginx/conf.d/default.conf &&\
    ln -sf /etc/nginx/rawgithack/rawgithack.conf /etc/nginx/conf.d/rawgithack.conf
VOLUME /var/cache/nginx/rawgithack
CMD ["nginx", "-g", "daemon off;"]
