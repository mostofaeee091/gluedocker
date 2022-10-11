FROM php:8.1.1-fpm
#Arguments defined in docker-compose.yml
USER root
USER $user
# Copy composer.lock and composer.json into the working directory
COPY composer.lock composer.json /var/www/html/

# Install system dependencies
#RUN apt-get update && apt-get install -y \
#    git \
#    curl \
#    libpng-dev \
#    libonig-dev \
#    libxml2-dev \
#    zip \
#    unzip

# Install PHP extensions
#RUN docker-php-ext-install mbstring exif pcntl bcmath gd
#RUN docker-php-ext-install gd
#RUN apt install php-mysqli

#New PHP & system dependencies
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        vim \
        libzip-dev \
        unzip \
        git \
        libonig-dev \
        curl \
        build-essential \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
#    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-enable sodium
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# PHP8.1 install
#RUN add-apt-repository ppa:ondrej/php
#RUN apt install php8.1
#RUN apt install curl \
#       openssl \
#       php-tokenizer \
#       php-json
# Get latest Composer
# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
WORKDIR /var/www/html/
COPY . /var/www/html
# Create system user to run Composer and Artisan Commands
#RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user
#    chmod -R 775 /root/glue/storage/framework \
#    chmod -R 775 /root/glue/storage/logs \

# Assign permissions of the working directory to the www-data user
RUN chown -R www-data:www-data /var/www/html/
RUN chmod -R 775 /var/www/html/storage
RUN chmod -R 775 /var/www/html/bootstrap/cache
# Set working directory
#WORKDIR /var/www/
#ENTRYPOINT ["docker-php-entrypoint"]
#For My ###
RUN sed -i -e 's/pm = .+?/pm = dynamic/' \
 -e 's/pm\.max_children = \d/pm\.max_children = 35/' \
 -e 's/pm\.start_servers = \d/pm\.start_servers = 10/' \
 -e 's/pm\.min_spare_servers = \d/pm\.min_spare_servers = 5/' \
 -e 's/pm\.max_spare_servers = \d/pm\.max_spare_servers = 20/' \
 -e 's/pm\.max_requests = \d/pm\.max_requests = 500/' \
 -e 's/pm\.process_idle_timeout = .+?/pm\.process_idle_timeout = 10s/' \
 /usr/local/etc/php-fpm.d/www.conf

EXPOSE 9000
CMD ["php-fpm"]
