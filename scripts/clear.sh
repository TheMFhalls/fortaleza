#!/usr/bin/env bash
current_dir="$(dirname "$0")"
cd ${current_dir}/../app

bin/console cache:clear && bin/console cache:warmup
chown -R www-data:www-data /var/cache/fortaleza
chown -R www-data:www-data /var/log/fortaleza
chmod -R 777 /var/cache/fortaleza
chmod -R 777 /var/log/fortaleza
