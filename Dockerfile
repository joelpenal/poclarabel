FROM php:7.3-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    zip \
    vim \
    unzip \
    git \
    curl \
    cron

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN apt-get update -y 


# Get composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/

# Set working directory
WORKDIR /var/www

# Copy existing application directory contents
COPY . /var/www

# Install composer
RUN composer install
RUN composer dump-autoload

# Expose port 8080 and start server
CMD php artisan serve 
EXPOSE 80