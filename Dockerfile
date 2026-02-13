# Imagen base con PHP 8.3 + Apache
FROM php:8.5-apache

# Instalar dependencias del sistema Y git (importante)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    && rm -rf /var/lib/apt/lists/*

# Instalar extensiones PHP
RUN docker-php-ext-install \
    pdo_mysql \
    mbstring \
    zip \
    xml

# Habilitar mod_rewrite para Laravel
RUN a2enmod rewrite

# Carpeta de trabajo
WORKDIR /var/www/html

# Copiar archivos del proyecto
COPY . .

# Instalar Composer (descargar versión más reciente)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Instalar dependencias PHP con Composer
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# ...todo lo que ya tienes arriba

# Instalar Node.js y npm (Node 20 LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Instalar dependencias Node y compilar assets
RUN npm install && npm run build

# Permisos para Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Configurar Apache para servir /public
RUN sed -i 's#/var/www/html#/var/www/html/public#g' /etc/apache2/sites-available/000-default.conf

EXPOSE 80

CMD ["apache2-foreground"]
