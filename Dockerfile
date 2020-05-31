FROM ubuntu:18.04

# Set working directory
WORKDIR /var/www

# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/

ENV DOCKER_CONTENT_TRUST=1
ENV DD_AGENT_MAJOR_VERSION=7 
ENV DD_API_KEY=515a77b256d24b80642bdca4bfbd1185

# Install dependencies
RUN apt-get update && apt-get install -y \
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
    cron

# Install DataDog Agent
RUN curl -L https://raw.githubusercontent.com/DataDog/datadog-agent/master/cmd/agent/install_script.sh | bash -

# Install Node
RUN curl -sL https://deb.nodesource.com/setup_14.x  | bash -
RUN apt-get -y install nodejs
RUN npm install

# Install extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
RUN docker-php-ext-install gd
RUN docker-php-ext-configure bcmath --enable-bcmath
RUN docker-php-ext-install bcmath

RUN apt-get update -y && \
    apt-get install -y libmcrypt-dev && \
    pecl install mcrypt-1.0.3 && \
    docker-php-ext-enable mcrypt

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