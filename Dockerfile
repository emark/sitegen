FROM debian:stable-slim

COPY cpanfile .

RUN apt-get update && \
apt-get install -y sqlite3 && \
apt-get install -y cpanminus && \
apt-get install -y gcc && \
apt-get install -y libdbd-sqlite3-perl && \
cpanm --installdeps .

COPY . /sitegen

WORKDIR /sitegen/script

EXPOSE 3000

CMD ["/usr/local/bin/morbo", "/sitegen/script/sitegen"]

# Run container
# docker run -itd -p 80:3000 --mount type=bind,src=${PWD}/sitegen.conf,dst=/sitegen/sitegen.conf --mount type=bind,src=${PWD}/public/downloads,dst=/sitegen/public/downloads --mount type=bind,src=${PWD}/db,dst=/sitegen/db --mount type=bind,src=${PWD}/utils/site.env,dst=/sitegen/utils/site.env sitegen

