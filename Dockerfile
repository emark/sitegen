FROM debian:stable-slim

WORKDIR /sitegen

COPY cpanfile .

RUN apt-get update && \
apt-get install -y --no-install-recommends sqlite3=3.40.1-2+deb12u1 && \
apt-get install -y --no-install-recommends gcc=4:12.2.0-3 && \
apt-get install -y --no-install-recommends libdbd-sqlite3-perl=1.72-1 && \
apt-get install -y --no-install-recommends cpanminus=1.7046-1 && \
apt-get install -y --no-install-recommends make=4.3-4.1 && \
cpanm --installdeps . && \
apt-get clean && \
rm -rf /var/lib/apt/lists/*

COPY . .

EXPOSE 3000

CMD ["/usr/local/bin/morbo", "/sitegen/script/sitegen"]

# Run container
# docker run -itd -p 80:3000 --mount type=bind,src=${PWD}/sitegen.conf,dst=/sitegen/sitegen.conf --mount type=bind,src=${PWD}/public/downloads,dst=/sitegen/public/downloads --mount type=bind,src=${PWD}/db,dst=/sitegen/db --mount type=bind,src=${PWD}/utils/site.env,dst=/sitegen/utils/site.env sitegen

