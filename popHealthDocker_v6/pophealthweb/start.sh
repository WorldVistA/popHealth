#!/bin/bash

cd /popHealth
sleep 20

checkFILE=/popHealth/setupComplete

if ! test -f "$checkFILE"; then
  #echo "Downloading Bundle with user $NLM_USERNAME"
  bundle exec rake pophealth:download_update_install nlm_user=$NLM_USERNAME nlm_pass=$NLM_PASSWORD version=2018 RAILS_ENV=production
  echo "Creating Admin Account"
  bundle exec rake admin:create_admin_account RAILS_ENV=production
  echo "Precompiling assest"
  rake assets:precompile RAILS_ENV=production RAILS_RELATIVE_URL_ROOT=/popHealth
  touch /popHealth/setupComplete
  chmod -R 777 /popHealth/
fi

echo "Starting popHealth"
bundle exec rake jobs:work RAILS_ENV=production & /usr/sbin/apache2ctl -D FOREGROUND
