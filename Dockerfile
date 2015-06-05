FROM nginx
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf proxy.conf index.html styles.css /etc/nginx/rawgithack/
RUN ln -sf /etc/nginx/rawgithack/nginx.conf /etc/nginx/conf.d/rawgithack.conf
VOLUME /etc/nginx/rawgithack/ssl/
EXPOSE 80 433
