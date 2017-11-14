<p align="center">
  <img alt="rOCCI" src="https://i.imgur.com/jEEjEfW.png" width="300"/>
</p> 

# rOCCI-server - A Ruby-based OCCI server
[![Travis](https://img.shields.io/travis/the-rocci-project/rOCCI-server.svg?style=flat-square)](http://travis-ci.org/the-rocci-project/rOCCI-server)
[![Gemnasium](https://img.shields.io/gemnasium/the-rocci-project/rOCCI-server.svg?style=flat-square)](https://gemnasium.com/the-rocci-project/rOCCI-server)
[![Code Climate](https://img.shields.io/codeclimate/github/the-rocci-project/rOCCI-server.svg?style=flat-square)](https://codeclimate.com/github/the-rocci-project/rOCCI-server)
[![DOI](https://zenodo.org/badge/101395646.svg)](https://zenodo.org/badge/latestdoi/101395646)

## Requirements
### Ruby
* Ruby 2.2.6+
### Services
* OpenNebula 5.2+ (when using the `opennebula` backend)
* Memcache

## Installation
### Packages
`TODO`
### Source
```bash
git clone https://github.com/the-rocci-project/rOCCI-server.git
cd rOCCI-server
bundle install --deployment --without development test

bundle exec bin/oneresource create --endpoint http://one.example.org:2633/RPC2 # --username USER --password PASSWD

export RAILS_ENV=production
export HOST=0.0.0.0
export SECRET_KEY_BASE=$(head -c 69 /dev/urandom | base64 -w 0)

export ROCCI_SERVER_BACKEND=opennebula
export ROCCI_SERVER_OPENNEBULA_ENDPOINT=http://one.example.org:2633/RPC2

bundle exec puma # --daemon
```

## Usage
`TODO`

## Changelog
See `CHANGELOG.md`.

## Code Documentation
[Code Documentation for rOCCI-server](http://rubydoc.info/github/the-rocci-project/rOCCI-server/)

### Contribute

1. Fork it
2. Create a branch (git checkout -b my_markup)
3. Commit your changes (git commit -am "My changes")
4. Push to the branch (git push origin my_markup)
5. Create an Issue with a link to your branch
