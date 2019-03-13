#!/usr/bin/env bash
current_dir="$(dirname "$0")"
cd ${current_dir}/../app

chmod +x bin/console

chown -R www-data:www-data /var/cache/fortaleza
chown -R www-data:www-data /var/log/fortaleza
chown -R www-data:www-data public/upload
chmod -R 777 /var/cache/fortaleza
chmod -R 777 /var/log/fortaleza
chmod -R 777 public/upload
