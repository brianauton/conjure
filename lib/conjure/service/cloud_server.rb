module Conjure
  module Service
    class CloudServer
      require "fog"
      require "pathname"
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def run(command, options = {}, &block)
        set_fog_credentials
        file_set = RemoteFileSet.new(:shell => remote_shell, :files => options[:files])
        file_set.upload
        result = remote_shell.run(command, :stream_stdin => options[:stream_stdin], &block)
        file_set.remove
        result
      end

      def server
        @server ||= existing_server
        @server ||= new_server
        @server.wait_for { ready? }
        @server
      end

      def ip_address
        server.public_ip_address
      end

      def existing_server
        @existing_server ||= connection.servers.find{|s| s.name == @name } if connection
      end

      def self.connection
        new("").connection
      end

      def self.each_with_name_prefix(prefix, &block)
        return unless connection
        connection.servers.all.select{|s| s.name.match(/^#{prefix}/)}.each do |server|
          block.call new(server.name)
        end
      end

      def self.ensure_unique_name(name)
        return name unless connection
        existing_names = connection.servers.all.map{ |s| s.name }
        name = increment_numeric_suffix(name) while existing_names.include? name
        name
      end

      def self.increment_numeric_suffix(name)
        parts = name.split("-")
        parts[2] = parts[2] ? ((parts[2].to_i)+1).to_s : "2"
        parts.join("-")
      end

      def new_server
        Log.info " [cloud] Launching new server #{@name}"
        bootstrap_options = account.bootstrap_options.merge(:name => @name)
        options = prepare_bootstrap_options(bootstrap_options).merge(fog_credentials)
        connection.servers.bootstrap options
      end

      def account
        @account ||= Provider.all(:cloud_account).first
      end

      def connection
        @connection ||= Fog::Compute.new account.compute_options if account
      end

      def add_resource_id(options, type)
        id = "#{type}_id".to_sym
        name = "#{type}_name".to_sym
        collection = "#{type}s".to_sym
        options[id] = resource_id(collection, options[name]) if options[name]
      end

      def prepare_bootstrap_options(options)
        add_resource_id(options, :flavor)
        add_resource_id(options, :region)
        add_resource_id(options, :image)
        options
      end

      def resource_id(collection, name)
        connection.send(collection).find{|i| i.name == name}.id
      end

      def set_fog_credentials
        Fog.credential = Conjure.identity.unique_identifier
        Fog.credentials.merge! fog_credentials
      end

      def fog_credentials
        {
          private_key_path: Conjure.identity.private_key_path,
          public_key_path: Conjure.identity.public_key_path,
        }
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
