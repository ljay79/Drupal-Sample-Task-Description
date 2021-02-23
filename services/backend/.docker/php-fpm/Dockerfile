FROM ljay/amaz-drupal:php-fpm

# parent image might leave user as "non root"
USER root

# dev (Development/Local System)
# test (Test/Stage System)
# prod
ARG stage=dev
ENV STAGE $stage

######################################################
# unix permission fix (docker host = unix)
# Neccessary only when sharing volume with host
ARG USER_ID
ARG GROUP_ID

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \
    usermod -u ${USER_ID} www-data && \
    groupmod -g ${GROUP_ID} www-data \
;fi
######################################################

# Copy config and script files
COPY .docker/php-fpm/ /opt/.docker/

RUN set -eux; \
  yum update -y; \
  yum install -y patch; \
  # move config files
  mv /opt/.docker/php.d/*.ini /etc/php.d/; \
  mv /opt/.docker/php.${stage}.ini /etc/php.d/99-php.ini; \
  mv /opt/.docker/php-fpm-pool.conf /etc/php-fpm.d/www.conf; \
  rm -rf /tmp/*; \
  chown -R www-data /var/log/php-fpm/; \
  ln -sf /dev/stderr /var/log/php-fpm/error.log; \
  ####################
  # DEV environment  #
  ####################
  if [ "${stage}" == "dev" ]; then \
    yum install -y wget gcc-c++ make sudo tar unzip git; \
  fi

COPY composer.json composer.lock /var/www/html/
COPY config /var/www/html/config/
COPY web /var/www/html/web/

WORKDIR /var/www/html

RUN set -eux; \
    cd /var/www/html; \
    # proper ownership
    chown -R www-data:www-data /var/www/html/

# for root user allow CLI mode
ENV PATH=${PATH}:/var/www/html/vendor/bin

# cleanup
RUN rm -rf /opt/.docker/*

#
# -----
#

# Leave everything in working state
USER www-data

# To share the volume with nginx via ContainerDefinitions:VolumesFrom:SourceContainer:php
VOLUME ["/var/www/html"]

EXPOSE 9001

CMD ["php-fpm", "-F"]
