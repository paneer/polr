# Use the official PHP image with Apache
FROM php:7.4-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    libzip-dev \
    zip \
    unzip \
    && docker-php-ext-install pdo pdo_mysql mbstring zip bcmath \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /var/www/html

# Copy the application files
COPY . .

# Install Composer
COPY --from=composer:2.0 /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader

# Copy the environment file
COPY .env.setup .env

# Set permissions for storage and bootstrap/cache
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# Configure Apache to serve the application
RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]