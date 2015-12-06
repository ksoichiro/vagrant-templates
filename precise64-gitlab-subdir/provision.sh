#!/usr/bin/env bash

VAGRANT_SYNC_DIR=/vagrant
INSTALLER_DIR=packages
GITLAB_VERSION_FILE=${VAGRANT_SYNC_DIR}/gitlab.version
GITLAB_VERSION=`cat ${GITLAB_VERSION_FILE}`
INSTALLER=${INSTALLER_DIR}/gitlab_${GITLAB_VERSION}-omnibus-1.ubuntu.12.04_amd64.deb
INSTALLER_URL=https://downloads-packages.s3.amazonaws.com/gitlab_${GITLAB_VERSION}-omnibus-1.ubuntu.12.04_amd64.deb

if [ ! -d /opt/gitlab ]; then
  pushd /vagrant > /dev/null 2>&1
  if [ ! -d ${INSTALLER_DIR} ]; then
    mkdir ${INSTALLER_DIR}
  fi
  if [ ! -f ./${INSTALLER} ]; then
    echo "Getting gitlab omnibus installer..."
    pushd ./${INSTALLER_DIR} > /dev/null 2>&1
    wget ${INSTALLER_URL} > /dev/null 2>&1
    popd > /dev/null 2>&1
  fi
  echo "Installing gitlab..."
  dpkg -i ./${INSTALLER} > /dev/null 2>&1
  echo "Reconfiguring gitlab..."
  gitlab-ctl reconfigure > /dev/null 2>&1
  popd > /dev/null 2>&1

  echo "Stopping web servers to reconfigure..."
  gitlab-ctl stop nginx > /dev/null 2>&1
  gitlab-ctl stop unicorn > /dev/null 2>&1

  echo "Installing alternative nginx..."
  apt-get update -qq
  apt-get install -y nginx
  # Disable default site
  [ -f /etc/nginx/sites-enabled/default ] && rm -f /etc/nginx/sites-enabled/default

  cp -p /var/opt/gitlab/nginx/etc/gitlab-http.conf /etc/nginx/sites-available/gitlab > /dev/null 2>&1

  echo "Configuring nginx and unicorn..."
  # Modify socket location so that nginx can access to it
  sed -i "s|^listen \"/var/opt/gitlab/[^\"]*\"|listen \"/tmp/gitlab.socket\"|" \
      /var/opt/gitlab/gitlab-rails/etc/unicorn.rb > /dev/null 2>&1
  sed -i "s|location / {$|location /gitlab {|" /etc/nginx/sites-available/gitlab > /dev/null 2>&1
  sed -i "s|server unix:/var/opt/gitlab/gitlab-rails/tmp/sockets/gitlab.socket;$|server unix:/tmp/gitlab.socket;|" /etc/nginx/sites-available/gitlab > /dev/null 2>&1
  # Give RAILS_RELATIVE_URL_ROOT to unicorn
  sed -i "s|^\(exec chpst .* HOME=\"[^\"]*\"\) /opt|\\1 RAILS_RELATIVE_URL_ROOT=\"/gitlab\" /opt|" /opt/gitlab/sv/unicorn/run

  echo "Starting web servers..."
  ln -s /etc/nginx/sites-available/gitlab /etc/nginx/sites-enabled/gitlab > /dev/null 2>&1
  service nginx start > /dev/null 2>&1
  gitlab-ctl start unicorn
fi
