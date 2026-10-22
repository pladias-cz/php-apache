FROM php:8.5-apache@sha256:5fec3fb1f0322c20a01c8af35a09a96f3a83aa369650b0fed161e91cb84056ed
#Apache:modRewrite
RUN a2enmod rewrite
#PHP modules #1
RUN apt-get update \
        && buildDeps=" \
                git \
                zlib1g-dev \
                locales \
                locales-all \
                libicu-dev \
                libmcrypt-dev \
                libpq-dev \
                libfreetype6-dev \
                libjpeg62-turbo-dev \
                libmcrypt-dev \
                libzip-dev \
                libonig-dev \
                zlib1g-dev \
        " \
        && apt-get install -y $buildDeps --no-install-recommends \
        && rm -r /var/lib/apt/lists/*

RUN locale-gen cs_CZ.UTF-8

RUN docker-php-ext-install ftp pdo pdo_pgsql pdo_mysql mysqli intl mbstring pgsql zip exif
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    && docker-php-ext-install gd

ENV APACHE_DOCUMENT_ROOT=/var/www/html/www
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY conf/php_pladias_custom.ini $PHP_INI_DIR/conf.d/