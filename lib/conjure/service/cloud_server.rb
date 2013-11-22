module Conjure
  module Service
    class CloudServer
      require "fog"
      require "digest/md5"
      require "pathname"

      def initialize(name)
        @name = name
      end

      def run(command, options = {}, &block)
        set_fog_credentials
        upload_files options[:files].to_a
        result = remote_shell.run(command, :stream_stdin => options[:stream_stdin], &block)
        remove_files options[:files].to_a
        result
      end

      def upload_files(files)
        dir_names = files.map{|local_path, remote_path| File.dirname remote_path}.uniq
        run "mkdir -p #{dir_names.join ' '}" if dir_names.any?
        files.each{|local_path, remote_path| server.scp local_path, remote_path}
      end

      def remove_files(files)
        files.each{|local_path, remote_path| run "rm -f #{remote_path}"}
      end

      def server
        @server ||= existing_server
        @server ||= new_server
        @server.wait_for { ready? }
        @server
      end

      def ip_address
        @server.public_ip_address
      end

      def existing_server
        server = connection.servers.find{|s| s.name == @name }
        Log.info " [cloud] Using existing server #{@name}" if server
        server
      end

      def new_server
        Log.info " [cloud] Launching new server #{@name}"
        connection.servers.bootstrap bootstrap_options.merge(fog_credentials)
      end

      def connection
        @connection ||= Fog::Compute.new compute_options
      end

      def bootstrap_options
        {
          name: @name,
          flavor_id: flavor_id,
          region_id: region_id,
          image_id: image_id,
        }
      end

      def compute_options
        {
          provider: :digitalocean,
          digitalocean_api_key: Conjure.config.digitalocean_api_key,
          digitalocean_client_id: Conjure.config.digitalocean_client_id,
        }
      end

      def flavor_id
        @flavor_id ||= connection.flavors.find{|f| f.name == "512MB"}.id
      end

      def region_id
        @region_id ||= connection.regions.find{|r| r.name == Conjure.config.digitalocean_region}.id
      end

      def image_id
        @image_id ||= connection.images.find{|r| r.name == "Ubuntu 13.04 x64"}.id
      end

      def set_fog_credentials
        Fog.credential = fog_key_identifier
        Fog.credentials.merge! fog_credentials
      end

      def private_key_file
        Pathname.new(Conjure.config.config_path).join Conjure.config.private_key_file
      end

      def public_key_file
        Pathname.new(Conjure.config.config_path).join Conjure.config.public_key_file
      end

      def fog_credentials
        {
          private_key_path: private_key_file,
          public_key_path: public_key_file,
        }
      end

      def fog_key_identifier
        "conjure_#{Digest::MD5.hexdigest(File.read public_key_file)[0..7]}"
      end

      def remote_shell
        @remote_shell ||= RemoteShell.new(
          :ip_address => server.public_ip_address,
          :username => "root",
        )
      end
    end
  end
end
