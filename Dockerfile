FROM cgr.dev/chainguard/wolfi-base

RUN apk add --no-cache \
    php-8.3 \
    php-8.3-curl \
    php-8.3-pdo \
    php-8.3-pdo_mysql \
    php-8.3-pdo_sqlite \
    php-8.3-pdo_pgsql \
    php-8.3-mysqlnd

COPY rootfs /

ARG ADMINEREVO_VERSION=4.8.1

RUN	set -x \
&&	apk add --no-cache git curl \
&&	curl -fsSL "https://github.com/adminerevo/adminerevo/archive/refs/tags/v$ADMINEREVO_VERSION.zip" -o /tmp/adminerevo.zip \
&&  unzip /tmp/adminerevo.zip -d /tmp \ 
&&  php "/tmp/adminerevo-$ADMINEREVO_VERSION/compile.php" \
&&  cp "adminer-$ADMINEREVO_VERSION.php" /var/www/html/adminer.php \
&&	git clone --recurse-submodules=designs --depth 1 --shallow-submodules https://github.com/adminerevo/adminerevo.git /tmp/adminer \
&&	cp -r /tmp/adminer/designs/ /tmp/adminer/plugins/ /var/www/html \
&&	rm -rf /tmp/adminer/ \
&&  chown -R nonroot:nonroot /var/www/html \
&&	apk del git curl

ENTRYPOINT [ "/entrypoint.sh" ]
USER nonroot
EXPOSE 8080
ENV PHP_CLI_SERVER_WORKERS=4
CMD	[ "php", "-S", "[::]:8080", "-t", "/var/www/html" ]

