drop database if exists sitegen;
create database sitegen;
use sitegen;
create table site (id integer not null auto_increment primary key, url text, meta text, content text);

