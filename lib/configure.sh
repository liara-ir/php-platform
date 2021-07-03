#/bin/bash

if [ "$__PHP_MIRROR" = "true" ]; then
  echo '> Using mirror: ' $__PHP_MIRRORURL
  composer config -g repo.packagist false
  composer config -g repo.liara composer $__PHP_MIRRORURL
fi

composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader --ansi --no-scripts