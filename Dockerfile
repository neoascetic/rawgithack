FROM nginx:latest
COPY nginx.conf proxy.conf index.html styles.css /etc/nginx/rawgithack/
RUN rm /etc/nginx/conf.d/default.conf && ln -sf /etc/nginx/rawgithack/nginx.conf /etc/nginx/conf.d/rawgithack.conf
# put your SSL certificates here
VOLUME /etc/ssl/private/rawgithack
ENV DOMAIN githack.com
CMD sed -i "s/githack.com/$DOMAIN/g" /etc/nginx/rawgithack/* && nginx -g "daemon off;"
