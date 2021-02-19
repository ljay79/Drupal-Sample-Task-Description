#!/bin/bash
# Expected to run as user 'root'
# perform a few cleaning steps to make the docker image slim and clean.

#TODO: adjust for production
exit 0;

echo 
echo -e "\e[32m[cleanup.sh] running for environment '${stage}'\e[0m"
echo 

# DO NOT RUN in local devel environment! :/
if [ "${stage}" = "dev" ]; then
  echo "Running in DEV mode. Do not clean up ..."
  exit 0
fi


# remove git software packages
yum erase -y git

# remove any .git files/folders
find . -name ".git*" -exec rm -rf {} \;

# uninstall/remove composer
rm -rf /var/www/html/.cache
rm -rf ~/.composer
rm -rf .composer
rm -f /usr/local/bin/composer

rm -rf /var/www/html/tests

# remove symfony cache
rm -rf /var/www/html/var/cache/*

yum update -y && yum clean all && rm -rf /tmp/* /var/tmp/* /var/cache/yum

echo 
echo -e "\e[32m[cleanup.sh] leaving cleanup script\e[0m"
echo 
