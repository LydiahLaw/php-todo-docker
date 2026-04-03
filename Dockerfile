FROM php:7.4-apache

RUN apt-get update && apt-get install -y \
    zip unzip git curl \
    && docker-php-ext-install mysqli pdo pdo_mysql \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin --filename=composer

RUN a2enmod rewrite

WORKDIR /var/www/html

COPY . /var/www/html

RUN mkdir -p bootstrap/cache storage/framework/sessions \
    storage/framework/views storage/framework/cache storage/logs \
    && chmod -R 775 bootstrap/cache storage

RUN composer install --no-interaction --prefer-dist --optimize-autoloader

RUN php artisan key:generate

RUN sed -i 's|/var/www/html|/var/www/html/public|g' \
    /etc/apache2/sites-available/000-default.conf

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage

COPY php-config.ini /usr/local/etc/php/conf.d/custom.ini

EXPOSE 80
CMD ["apache2-foreground"]
