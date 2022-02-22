FROM openresty/openresty:1.13.6.2-1-alpine
COPY rawgithack.conf rawgithack.lua web/*.html /etc/nginx/rawgithack/
RUN rm /etc/nginx/conf.d/default.conf &&\
    ln -sf /etc/nginx/rawgithack/rawgithack.conf /etc/nginx/conf.d/rawgithack.conf &&\
    cd /etc/nginx/rawgithack/ && mkdir www &&\
    sed $'/PLACEHOLDER/{r index.html\nd}' base.html > www/index.html &&\
    sed $'/PLACEHOLDER/{r faq.html\nd}' base.html > www/faq.html &&\
    sed $'/PLACEHOLDER/{r purge-cache.html\nd}' base.html > www/purge-cache.html &&\
    rm *.html
VOLUME /var/cache/nginx/rawgithack
CMD ["nginx", "-g", "daemon off;"]
