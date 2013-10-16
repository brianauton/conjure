## Conjure
[![Gem Version](https://badge.fury.io/rb/conjure.png)](http://badge.fury.io/rb/conjure)
[![Build Status](https://travis-ci.org/brianauton/conjure.png?branch=master)](https://travis-ci.org/brianauton/conjure)
[![Code Climate](https://codeclimate.com/github/brianauton/conjure.png)](https://codeclimate.com/github/brianauton/conjure)

Magically powerful deployment for Rails applications.

### Requirements

Deploying a Rails application with Conjure currently requires the
following:

  * A DigitalOcean account

  * A Public/private SSH keypair to use for bootstrapping new cloud
    servers. Generating a new keypair for this purpose is recommended.

Also, your Rails application requires all of the following:

  * It must have a `.ruby-version` file indicating which version of
    Ruby to run

  * It must be able to run in production mode with a single
    Postgres database (any existing database.yml will be ignored)

  * It must be checked out locally into a git repository with a valid
    `origin` remote

  * The public SSH key you're using must have permission to check out
    the project from `origin`

### Getting Started

First, install the Conjure gem by either adding it to your Gemfile

    group :development do
      gem "conjure"
    end

and then running `bundle`, OR by installing it directly:

    gem install conjure

Then add a file to your Rails project called
`config/conjure.yml`. This should be a YAML file with the following
fields (all fields are required):

  * `digitalocean_client_id` and `digitalocean_api_key`: These
    credentials are available after logging in to your Digital Ocean
    account.

  * `digitalocean_region`: The geographic region for deploying new
    cloud servers. If unsure, use "New York 1".

  * `private_key_file` and `public_key_file`: Pathnames to local files
    (relative to your project's `config` directory) that contain the
    private and public SSH keys to use for deployment. It's
    recommended to generate a new keypair rather than using your
    personal SSH keys, since Conjure currently copies the specified
    private key to the server during deployment.

Here's an example conjure.yml file:

    digitalocean_client_id: XXXXXXXX
    digitalocean_api_key: XXXXXXXX
    digitalocean_region: New York 1
    private_key_file: conjure_key
    public_key_file: conjure_key.pub

Finally, tell Conjure to deploy your app:

    conjure deploy

The last line of the output will tell you the IP address of the
deployed server. Repeating the command will reuse the existing server
rather than deploying a new one.

### Additional Commands

These commands are available after you've deployed with `conjure
deploy`.

    conjure export FILE

This will produce a Postgres SQL dump of the currently-deployed
server's production database, and save it to the local file `FILE`.

    conjure import FILE

This will overwrite the production database on the currently-deployed
server with a Postgres SQL dump from the local file `FILE`.
