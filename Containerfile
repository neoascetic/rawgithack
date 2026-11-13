FROM docker.io/nginx:stable-alpine as base
RUN mkdir -p /var/cache/nginx/rawgithack
WORKDIR /etc/nginx/rawgithack


# test image
FROM base AS test
RUN apk add --no-cache build-base perl-dev perl-utils perl-app-cpanminus && cpanm --notest Test::Nginx
ENV TEST_NGINX_CLIENT_PORT=80 TEST_NGINX_NO_CLEAN=true
CMD ["prove", "-r", "t"]


# production/default image
FROM base AS prod
COPY rawgithack.conf .
COPY web ./web
RUN ln -sf /etc/nginx/rawgithack/rawgithack.conf /etc/nginx/conf.d/default.conf
VOLUME /var/cache/nginx/rawgithack