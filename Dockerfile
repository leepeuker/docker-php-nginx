FROM alpine:3.19

ARG UID=1000
ARG GID=1000

WORKDIR /app

# Install packages and remove default server definition
RUN apk add --no-cache \
  su-exec \
  curl \
  nginx \
  php83 \
  php83-ctype \
  php83-curl \
  php83-dom \
  php83-fileinfo \
  php83-fpm \
  php83-gd \
  php83-intl \
  php83-mbstring \
  php83-mysqli \
  php83-opcache \
  php83-openssl \
  php83-session \
  php83-tokenizer \
  php83-xml \
  supervisor

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/conf.d /etc/nginx/conf.d/

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Configure PHP-FPM
ENV PHP_INI_DIR /etc/php83
COPY config/fpm-pool.conf ${PHP_INI_DIR}/php-fpm.d/www.conf
COPY config/php.ini ${PHP_INI_DIR}/conf.d/custom.ini

# Create symlink for php
RUN ln -s /usr/bin/php83 /usr/bin/php

# Add composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Create movary user and group
RUN addgroup -g $UID movary \
    && adduser -G movary -u $GID movary -D

# Add applicationx
COPY src/ /app
COPY entrypoint.sh /entrypoint.sh

# Expose the port nginx is reachable on
EXPOSE 8080

ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
