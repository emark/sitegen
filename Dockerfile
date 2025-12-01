FROM debian:stable-slim

WORKDIR /sitegen

COPY cpanfile .

RUN apt-get update && apt-get install -y --no-install-recommends \
sqlite3 \
gcc \
libdbd-sqlite3-perl \
cpanminus \
make && \
cpanm --installdeps . && \
apt-get clean && \
rm -rf /var/lib/apt/lists/*

COPY . .

EXPOSE 3000

CMD ["/usr/local/bin/morbo", "/sitegen/script/sitegen"]

# Run container
# docker run -itd -p 80:3000 --mount type=bind,src=${PWD}/sitegen.conf,dst=/sitegen/sitegen.conf --mount type=bind,src=${PWD}/public/downloads,dst=/sitegen/public/downloads --mount type=bind,src=${PWD}/db,dst=/sitegen/db --mount type=bind,src=${PWD}/utils/site.env,dst=/sitegen/utils/site.env sitegen

