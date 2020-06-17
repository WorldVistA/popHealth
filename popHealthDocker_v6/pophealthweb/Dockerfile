FROM ruby:2.3.7

RUN gem install bundler -v '1.17.1'

# install
RUN apt-get update
RUN apt-get install -y --no-install-recommends apt-utils
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get update
RUN apt-get install -y nodejs
RUN apt-get install -y npm
RUN npm install -g bower
RUN apt-get install -y apache2=2.4.*
RUN apt-get install -y libcurl4-openssl-dev apache2-dev libapr1-dev libaprutil1-dev libssl-dev
RUN apt autoremove -y

RUN gem install passenger -v '5.3.7'


# Pull popHealth
WORKDIR /
RUN git clone https://github.com/WorldVistA/popHealth.git -b v6 popHealth
WORKDIR /popHealth

# fix fontawesome reference
RUN sed -i 's/"font-awesome": "^4.7.0",/"font-awesome": "~4.7.0",/g' /popHealth/bower.json

# fix JSON Parse
RUN sed -i 's/collection = JSON.parse(File.read(json_path)),/collection = JSON.parse(File.read(json_path), :max_nesting => false)/g' /popHealth/lib/measures/baseline_loader.rb

# Use custom config yml
#COPY popHealth.yml /popHealth/config/popHealth.yml

# custom bundle installer using LOCAL bundle.zip
#COPY pophealth.rake /popHealth/lib/tasks/pophealth.rake

# fixes to prevent halt of measure import on error (exception handling added)
COPY cql_bundle_importer.rb /popHealth/lib/cql_bundle_importer.rb

# User local pre-downloaded bundle-2018.zip
#COPY bundle-2018.zip /popHealth/bundles/bundle-2018.zip

# Add a mongoid.yml config file that supports environment variables to specify the host and port
COPY mongoid.yml config/mongoid.yml

# finally install popHealth
RUN bundle install

# bower must be run as a user, not root
RUN bower install --allow-root

# apache configuration

RUN passenger-install-apache2-module

ADD apache/sites-available/pophealth /etc/apache2/sites-available/pophealth
RUN rm /etc/apache2/sites-enabled/000-default*
RUN ln -s /etc/apache2/sites-available/pophealth /etc/apache2/sites-enabled/000-default.conf

ADD apache/conf-available/pophealth /etc/apache2/conf-available/pophealth
RUN ln -s /etc/apache2/conf-available/pophealth /etc/apache2/conf-enabled/pophealth.conf

ADD apache/mods-available/pophealth /etc/apache2/mods-available/pophealth
RUN ln -f -s /etc/apache2/mods-available/pophealth /etc/apache2/mods-enabled/pophealth.conf


EXPOSE 80

# add the startup script
ADD start.sh /popHealth/start.sh
RUN chmod 777 /popHealth/start.sh

ENTRYPOINT [ "/popHealth/start.sh" ]
