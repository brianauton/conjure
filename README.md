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

  * It must be able to run in production mode with a single Postgres
    or MySQL database (any existing database.yml will be ignored)

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
fields:

  * `digitalocean_client_id` and `digitalocean_api_key`: These
    credentials are available after logging in to your Digital Ocean
    account.

  * `digitalocean_region`: The geographic region for deploying new
    cloud servers. If unsure, use "New York 1".

  * `private_key_file` and `public_key_file` (optional): Pathnames to
    local files (absolute paths, or relative to your project's
    `config` directory) that contain the private and public SSH keys
    to use for deployment. If these aren't specified, Conjure will try
    to find identity files in `~/.ssh`.

Here's an example conjure.yml file:

    digitalocean_client_id: XXXXXXXX
    digitalocean_api_key: XXXXXXXX
    digitalocean_region: New York 1

Finally, tell Conjure to deploy your app:

    conjure deploy

The last line of the output will tell you the IP address of the
deployed server. Repeating the command will reuse the existing server
rather than deploying a new one. Specify a branch to deploy with
`--branch` or `-b` (default is `master`):

    conjure deploy --branch=mybranch

### Additional Commands

Additional commands are available after you've deployed with `conjure
deploy`.

#### Export

Produce a native-format (Postgres or MySQL) dump of the
currently-deployed server's production database, and save it to the
local file `FILE`.

    conjure export FILE

#### Import

Overwrite the production database on the currently-deployed server
with a dump from the local file `FILE`. The dump should be in the same
format as that produced by the `export` command (either a Postgres or
MySQL dump according to the database type).

    conjure import FILE

#### Log

Show logs from the deployed application. Optionally specify the number
of lines with `-n`, and use --tail to continue streaming new lines as
they are added to the log.

    conjure log [-n=NUM] [--tail|-t]

#### Console

Open a console on the deployed application.

    conjure console

#### Rake

Run a rake task on the deployed application and show the output.

    conjure rake [ARGUMENTS...]
