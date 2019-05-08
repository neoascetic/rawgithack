FROM openresty/openresty:alpine
COPY rawgithack.conf rawgithack.lua index.html /etc/nginx/rawgithack/
RUN rm /etc/nginx/conf.d/default.conf &&\
    ln -sf /etc/nginx/rawgithack/rawgithack.conf /etc/nginx/conf.d/rawgithack.conf
VOLUME /var/cache/nginx/rawgithack
CMD ["nginx", "-g", "daemon off;"]
