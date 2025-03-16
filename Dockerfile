FROM debian:stable-slim

COPY cpanfile .

RUN apt-get update && \
apt-get install -y sqlite3 && \
apt-get install -y cpanminus && \
apt-get install -y libdbd-sqlite3-perl && \
apt-get install -y cron && \
cpanm --installdeps .

WORKDIR /sitegen/script

COPY . /sitegen

RUN crontab ../.crontab

EXPOSE 3000

CMD ["/usr/local/bin/morbo", "/sitegen/script/sitegen"]

# Run container
# docker run -itd -p 80:3000 -v ./sitegen.conf:/sitegen/sitegen.conf -v ./public/downloads:/sitegen/public/downloads  -v ./db:/sitegen/db -v ./utils/site.env:/sitegen/utils/site.env sitegen

