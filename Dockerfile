FROM aartintelligent/app-nginx:latest

USER root

ARG PHP_VERSION='8.3'

ENV \
API_RUNTIME="supervisord" \
API_RUNTIME_CLI="php" \
PHP_VERSION="${PHP_VERSION}" \
PHP_MEMORY_LIMIT="2048M" \
PHP_MAX_EXECUTION_TIME="18000" \
PHP_REALPATH_CACHE_SIZE="4096K" \
PHP_REALPATH_CACHE_TTL="600" \
PHP_SENDMAIL_PATH="/usr/sbin/sendmail -t -i" \
PHP_XDEBUG__MODE="off" \
PHP_XDEBUG__CLIENT_PORT="9003" \
PHP_XDEBUG__CLIENT_HOST="172.17.0.1" \
PHP_XDEBUG__IDEKEY="PHPSTORM" \
PHP_SESSION__AUTO_START="0" \
PHP_APC__ENABLE="1" \
PHP_APC__ENABLE_CLI="1" \
PHP_APC__SHM_SIZE="512M" \
PHP_OPCACHE__ENABLE="1" \
PHP_OPCACHE__ENABLE_CLI="1" \
PHP_OPCACHE__MEMORY_CONSUMPTION="256" \
PHP_OPCACHE__INTERNED_STRINGS_BUFFER="8" \
PHP_OPCACHE__MAX_ACCELERATED_FILES="60000" \
PHP_OPCACHE__MAX_WASTED_PERCENTAGE="5" \
PHP_OPCACHE__USE_CWD="1" \
PHP_OPCACHE__VALIDATE_TIMESTAMPS="0" \
PHP_OPCACHE__REVALIDATE_FREQ="0" \
PHP_OPCACHE__REVALIDATE_PATH="0" \
PHP_OPCACHE__SAVE_COMMENTS="1" \
PHP_OPCACHE__RECORDS_WARNING="0" \
PHP_OPCACHE__ENABLE_FILE_OVERRIDE="0" \
PHP_OPCACHE__OPTIMIZATION_LEVEL="0x7FFFBFFF" \
PHP_OPCACHE__DUPS_FIX="0" \
PHP_OPCACHE__BLACKLIST_FILENAME="/etc/php/${PHP_VERSION}/opcache-*.blacklist" \
PHP_OPCACHE__MAX_FILE_SIZE="0" \
PHP_OPCACHE__CONSISTENCY_CHECKS="0" \
PHP_OPCACHE__FORCE_RESTART_TIMEOUT="180" \
PHP_OPCACHE__ERROR_LOG="/var/log/opcache" \
PHP_OPCACHE__LOG_VERBOSITY_LEVEL="1" \
PHP_OPCACHE__PREFERRED_MEMORY_MODEL="" \
PHP_OPCACHE__PROTECT_MEMORY="0" \
PHP_OPCACHE__RESTRICT_API="" \
PHP_OPCACHE__MMAP_BASE="" \
PHP_OPCACHE__CACHE_ID="" \
PHP_OPCACHE__FILE_CACHE="/var/cache/opcache" \
PHP_OPCACHE__FILE_CACHE_ONLY="0" \
PHP_OPCACHE__FILE_CACHE_CONSISTENCY_CHECKS="1" \
PHP_OPCACHE__FILE_CACHE_FALLBACK="1" \
PHP_OPCACHE__HUGE_CODE_PAGE="1" \
PHP_OPCACHE__VALIDATE_PERMISSION="0" \
PHP_OPCACHE__VALIDATE_ROOT="0" \
PHP_OPCACHE__OPT_DEBUG_LEVEL="0" \
PHP_OPCACHE__PRELOAD="" \
PHP_OPCACHE__PRELOAD_USER="rootless" \
PHP_OPCACHE__LOCKFILE_PATH="/var/lock/opcache" \
PHP_OPCACHE__JIT="function" \
PHP_OPCACHE__JIT_BUFFER_SIZE="512M" \
FPM_ERROR_LOG="/proc/1/fd/2" \
FPM_LOG_LEVEL="error" \
FPM_LOG_LIMIT="1024" \
FPM_LOG_BUFFER="yes" \
FPM_PM__TYPE="static" \
FPM_PM__MAX_CHILDREN="5" \
FPM_PM__START_SERVERS="2" \
FPM_PM__MIN_SPARE_SERVERS="1" \
FPM_PM__MAX_SPARE_SERVERS="3" \
FPM_PM__PROCESS_IDLE_TIMEOUT="60s;" \
FPM_PM__MAX_REQUESTS="512"

RUN set -eux; \
apt-get update; \
curl -qfsSL https://packages.sury.org/php/apt.gpg \
| gpg --dearmor -o /usr/share/keyrings/php.gpg > /dev/null; \
echo \
"deb [arch=$(dpkg --print-architecture) \
signed-by=/usr/share/keyrings/php.gpg] \
https://packages.sury.org/php/ \
$(lsb_release -cs) main" \
| tee /etc/apt/sources.list.d/php.list > /dev/null

RUN set -eux; \
apt-get update \
&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
make \
build-essential \
pkg-config \
autoconf \
libtool \
bison \
re2c \
php${PHP_VERSION}-cli \
php${PHP_VERSION}-dev \
php${PHP_VERSION}-fpm \
php${PHP_VERSION}-common \
php${PHP_VERSION}-bcmath \
php${PHP_VERSION}-opcache \
php${PHP_VERSION}-apcu \
php${PHP_VERSION}-amqp \
php${PHP_VERSION}-xdebug \
php${PHP_VERSION}-oauth \
php${PHP_VERSION}-redis \
php${PHP_VERSION}-curl \
php${PHP_VERSION}-soap \
php${PHP_VERSION}-mbstring \
php${PHP_VERSION}-mysql \
php${PHP_VERSION}-sqlite3 \
php${PHP_VERSION}-pgsql \
php${PHP_VERSION}-tokenizer \
php${PHP_VERSION}-xml \
php${PHP_VERSION}-xsl \
php${PHP_VERSION}-gd \
php${PHP_VERSION}-intl \
php${PHP_VERSION}-iconv \
php${PHP_VERSION}-ftp \
php${PHP_VERSION}-ldap \
php${PHP_VERSION}-zip

# Specificity to send emails on test environments via mailhog
# PHP_SENDMAIL_PATH="/usr/sbin/sendmail-local -t fake@mail.local --smtp-addr=mailhog:1025"
RUN set -eux; \
wget -q https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64; \
mv mhsendmail_linux_amd64 /usr/sbin/sendmail-local; \
chmod +x /usr/sbin/sendmail-local

COPY --chown=rootless:rootless system /

RUN set -eux; \
mkdir -p \
/etc/php \
/var/lib/php/sessions \
/var/log/opcache \
/var/lock/opcache \
/var/cache/opcache; \
cp -r \
/etc/php-z/* \
/etc/php/${PHP_VERSION}; \
chmod 777 -R \
/etc/php \
/var/lib/php/sessions \
/var/log/opcache \
/var/lock/opcache \
/var/cache/opcache; \
chown rootless:rootless \
/etc/php \
/var/lib/php/sessions \
/var/log/opcache \
/var/lock/opcache \
/var/cache/opcache; \
rm -rf \
/etc/php-z \
/var/www/*; \
ln -sf \
/etc/php/${PHP_VERSION}/90-php.ini \
/etc/php/${PHP_VERSION}/cli/conf.d/90-php.ini; \
ln -sf \
/etc/php/${PHP_VERSION}/90-php.ini \
/etc/php/${PHP_VERSION}/fpm/conf.d/90-php.ini; \
ln -sf \
/usr/sbin/php-fpm${PHP_VERSION} \
/usr/sbin/php-fpm

RUN set -eux; \
echo "/docker/d-bootstrap-php.sh" >> /docker/d-bootstrap.list; \
echo "/docker/d-bootstrap-fpm.sh" >> /docker/d-bootstrap.list; \
chmod +x /docker/d-*.sh

USER rootless
