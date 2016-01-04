## Conjure
[![Gem Version](https://badge.fury.io/rb/conjure.png)](http://badge.fury.io/rb/conjure)
[![Build Status](https://travis-ci.org/brianauton/conjure.png?branch=master)](https://travis-ci.org/brianauton/conjure)
[![Code Climate](https://codeclimate.com/github/brianauton/conjure.png)](https://codeclimate.com/github/brianauton/conjure)
[![Dependency Status](https://gemnasium.com/brianauton/conjure.png)](https://gemnasium.com/brianauton/conjure)

Conjure is a Ruby library for creating and updating cloud server instances as part of a Rails deployment workflow.

Conjure creates a cloud server instance, and uses Docker to start separate containers for the database and the web server. It sets up data volume containers for both of these service containers, so all data will be preserved if any individual containers or the server itself are restarted.

Conjure sets up an environment suitable for running the Rails application into which you've installed the Conjure gem, but it does not install your application. See the [capistrano-conjure](https://github.com/brianauton/capistrano-conjure) gem for an easy way to combine Conjure with deployment of your application.

WARNING: Conjure creates server instances and other resources using service provider accounts that you specify. In most cases this incurs service charges that will recur until you explicitly cancel them. You are responsible for all charges incurred through your use of Conjure.

WARNING: Conjure attempts to have a good security model and to treat your code and data responsibly, but this is not guaranteed. You are responsible for the security and confidentiality of the code of applications deployed with Conjure, the data handled by these applications, and your service credentials and public keys used for deployment.

### Requirements

* A DigitalOcean account (other cloud services may be supported in the future).

* A public SSH key located in `~/.ssh/id_rsa.pub`. This public key will be uploaded to the instance to allow subsequent access to the server. (other methods of granting server access to developers may be supported in the future).

* A Rails app that uses Postgres as its database (other databases may be supported in the future).

### Getting Started

First, install the Conjure gem either by adding it to your Gemfile

    group :development do
      gem "conjure"
    end

and then running `bundle`, OR by installing it directly:

    gem install conjure

Then set the DIGITALOCEAN_API_TOKEN environment variable to your DigitalOcean API token. Note that you need a single token that was generated for DigitalOcean's v2 API, not a key and secret pair as were used with their older v1 API.

    export DIGITALOCEAN_API_TOKEN=xxxxxxxxxxxxxxxx

Now you're ready to provision a new instance of the Rails app. Here's an example of Ruby code you could run from the Rails console or from a Rake task in your Rails app:

    Conjure::Instance.create app_name: "widget_store", rails_env: "demo", ruby_version: "2.0"

### Creating a new instance

To create a new instance on a new DigitalOcean droplet, call `Conjure::Instance.create` with a list of options. The following options are required:

* app_name: The application name; included in the name of the DigitalOcean droplet for easy identification.

Conjure will create the instance, and then give you a summary of information about the instance (including its IP address) that you'll need in order to access the instance and deploy your application.

### Updating an existing instance

To update an existing instance, call `Conjure::Instance.update` with a list of options. The following options are required:

* ip_address: The IP address of the DigitalOcean droplet to update.

Updating an instance simply involves checking that all the necessary Docker containers are running, and starting any that aren't running (after building them according to the supplied options). This means that if you want to change the configuration of your Rails application's web server, you can SSH to the droplet and manually stop and remove the `passenger` container, then run an update to have it rebuilt. This will preserve all your application's data, since that is stored in volume containers. An easier method for changing the options on existing instances may be added in the future.

### Options

The following additional options are supported for both `create` and `update`:

* max_upload_mb: The maximum size in megabytes of uploaded files that the web server should allow. Default is 20.

* rails_env: The Rails environment, e.g. "staging" or "production". Default is "staging".

* ruby_version: Valid values are "1.9", "2.0", "2.1", and "2.2" (the default).

* rubygems_version: Use this only if your application requires a specific version of RubyGems, otherwise a reasonably recent version will be used.

* ssl_hostname: Optionally configure the web server to respond to SSL connections at the given hostname. Currently this requires you to upload certificate and key files to the server after the instance is created.

* system_packages: An array of the names of any additional `apt` packages that should be installed in the Ubuntu container that runs your Rails app.

### Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec conjure` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/brianauton/conjure](https://github.com/brianauton/conjure).
