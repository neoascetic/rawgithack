FROM nginx:latest
COPY nginx.conf proxy.conf index.html styles.css /etc/nginx/rawgithack/
RUN rm /etc/nginx/conf.d/default.conf && ln -sf /etc/nginx/rawgithack/nginx.conf /etc/nginx/conf.d/rawgithack.conf
VOLUME /etc/ssl/private/rawgithack/
EXPOSE 80 433
