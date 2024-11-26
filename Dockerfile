FROM php:7.4-apache

# Inštalácia potrebných balíkov
RUN apt-get update && apt-get install -y \
    libxml2-dev \
    libpcre3-dev \
    git \
    libmariadb-dev \
    && docker-php-ext-install mysqli pdo_mysql

# Klonovanie DVWA
RUN git clone https://github.com/digininja/DVWA.git /var/www/html

# Premenovanie a modifikácia konfigurácie DVWA
RUN cp /var/www/html/config/config.inc.php.dist /var/www/html/config/config.inc.php \
    && sed -i 's/define("WEB_SERVER_WAF_ENABLED", true);/define("WEB_SERVER_WAF_ENABLED", false);/' /var/www/html/config/config.inc.php

# Nastavenie práv pre DVWA
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# Inštalácia ModSecurity
RUN apt-get install -y libapache2-mod-security2 \
    && a2enmod security2 \
    && mkdir -p /var/log/modsecurity \
    && touch /var/log/modsecurity/modsec_audit.log \
    && chmod -R 777 /var/log/modsecurity

# Skopírovanie vlastného modsecurity.conf
COPY modsecurity.conf /etc/modsecurity/modsecurity.conf

# Povolenie konfigurácie DVWA v Apache
RUN echo "<Directory /var/www/html>\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>" > /etc/apache2/conf-available/dvwa.conf \
    && a2enconf dvwa

# Povolenie mod_rewrite pre Apache
RUN a2enmod rewrite

# Nastavenie koreňového adresára
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Reštart Apache
RUN service apache2 restart

# Exponovanie portu 80
EXPOSE 80

# Štartovací príkaz
CMD ["apache2-foreground"]
