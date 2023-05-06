#!/bin/zsh
sudo -u postgres /bin/sh -c "psql -c \"CREATE DATABASE Strapi\""
sudo -u postgres /bin/sh -c "psql -c \"CREATE ROLE strapi WITH PASSWORD 'kGmYjLYjtk%6'\""