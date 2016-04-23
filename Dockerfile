FROM nginx:alpine
COPY rawgithack.conf index.html /etc/nginx/rawgithack/
RUN ln -sf /etc/nginx/rawgithack/rawgithack.conf /etc/nginx/conf.d/rawgithack.conf
CMD ["nginx", "-g", "daemon off;"]
