#!/bin/bash
set -e

if [ ! -s "/etc/php/$PHP_VERSION/90-php.ini" ]; then

  for e in "${!PHP_@}"; do

    if [ "$e" != "PHP_VERSION" ]; then

      VARIABLE=$(echo "$e" \
          | sed -e 's/PHP_/''/g' \
          | sed -e 's/__/'.'/g' \
          | awk '{print tolower($0)}')

      VALUE=$(printenv "$e")

      echo "$VARIABLE = '$VALUE'" >> "/etc/php/$PHP_VERSION/90-php.ini"

    fi

  done

fi
