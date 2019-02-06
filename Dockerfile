FROM php:7.2-fpm-alpine

EXPOSE 8000

RUN apk update && apk upgrade \
    && apk add gcc libxml2 libxslt libcurl libc-dev libxml2-dev libxslt-dev make curl icu-dev zlib-dev git redis autoconf\
    && docker-php-ext-install intl \
    && pecl install redis \
    && pecl install apcu \
    && pecl install xdebug \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install zip \
    && docker-php-ext-enable apcu \
    && docker-php-ext-enable redis \
    && docker-php-ext-enable xdebug \
    && apk del gcc libxml2-dev libxslt-dev make \
    && rm -rf /var/cache/apk/*

ENV COMPOSER_ALLOW_SUPERUSER 1
ENV COMPOSER_HOME /composer
ENV COMPOSER_VERSION 1.8.3
ENV COMPOSER_INSTALLER_SIG 48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === '${COMPOSER_INSTALLER_SIG}') { echo 'Installer verified' . PHP_EOL; exit(0); } else { echo 'Installer corrupt' . PHP_EOL; unlink('composer-setup.php'); exit(1); }" \
    && php composer-setup.php --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION} \
    && php -r "unlink('composer-setup.php');" \
    && composer --ansi --version --no-interaction

ADD 60-user.ini /usr/local/etc/php/conf.d/
