FROM nginx:latest
COPY nginx.conf index.html styles.css /etc/nginx/rawgithack/
RUN rm /etc/nginx/conf.d/default.conf && ln -sf /etc/nginx/rawgithack/nginx.conf /etc/nginx/conf.d/rawgithack.conf
CMD ["nginx", "-g", "daemon off;"]
