### Unreleased

* API change to remove Provision namespace

### Version 0.2.10
2015-06-24

* Always upgrade to latest revision of provisioned Ruby version

### Version 0.2.9
2015-06-24

* Add ssl_hostname and instance_size provisioning options
* Use volumes to store data for provisioned containers
* Make provisioned containers restart on reboot
* Upgrade provisioned Ruby version to 2.2

### Version 0.2.8
2014-10-31

* Add SSL configuration when provisioning
* Support configurable rubygems version
* Upgrade to latest Phusion base image

### Version 0.2.7
2014-10-23

* Add missing require directives, needed to provision Rails 2 apps

### Version 0.2.6
2014-10-23

* Use DigitalOcean API v2 for provisioning

### Version 0.2.5
2014-9-3

* Extra configuration options for provisioning

### Version 0.2.4
2014-8-29

* Update to latest DigitalOcean Docker image ID
* Generate minimal secrets.yml when provisioning

### Version 0.2.3
2014-3-28

* Create database when provisioning, for easier initial deployment

### Version 0.2.2
2014-3-28

* Bugfixes for postgres support when provisioning

### Version 0.2.1
2014-3-19

* Uniquify server name to avoid conflicts when provisioning
* Remove existing fog_default key to avoid conflicts when provisioning

### Version 0.2.0
2014-3-18

* Add source files for published Docker images
* Experimental API for programmatic provisioning

### Version 0.1.8
2014-1-24

* Add `show` command to list deployed instances
* Fix dockerfile error caused by unset environment variables

### Version 0.1.7
2014-1-14

* Improvements to error handling and verbose output

### Version 0.1.6
2013-11-27

* Support Docker 0.7

### Version 0.1.5
2013-11-22

* Add --verbose flag for debugging

### Version 0.1.4
2013-11-19

* Use SSH agent forwarding to deploy with the user's personal keys

### Version 0.1.3
2013-11-12

* Deploy apps that use MySQL

### Version 0.1.2
2013-11-06

* Minor fixes for deployment from OSX

### Version 0.1.1
2013-11-05

* Support Docker 0.6.5

### Version 0.1.0
2013-10-24

* Support revision deploys
* Add `--branch` option for deploys
* Add `console`, `log`, and `rake` commands
* SSH performance improvements

### Version 0.0.2
2013-10-14

* Avoid leaking memory when building docker images

### Version 0.0.1
2013-10-11

* Deploy to cloud servers using Docker and DigitalOcean
* Import and export the deployed app's database
* Documentation improvements

### Version 0.0.0
2013-10-07

* Very basic scripted deploy using Vagrant
