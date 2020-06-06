FROM php:7.3-fpm

# Set working directory
WORKDIR /var/www

# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/

ENV DOCKER_CONTENT_TRUST=1 

# Install dependencies
RUN apt-get update && apt-get install -y \
    apt-utils \
    build-essential \
    mariadb-client \
    libpng-dev \
    libzip-dev \
    zlib1g-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    cron \
    npm 

# Get composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Copy existing application directory contents
COPY . /var/www

# Copy existing application directory permissions
COPY --chown=www:www . /var/www

# Change current user to www
USER www

# Expose port 8080 and start server
CMD php artisan serve --host=0.0.0.0 --port=8080
EXPOSE 8080

HEALTHCHECK --interval=12s --timeout=12s --start-period=30s \  
CMD node healthcheck.js
