module Conjure
  module Service
    class RemoteFileSet
      require "net/scp"

      def initialize(options)
        @shell = options[:shell]
        @files = options[:files].to_a
      end

      def upload
        dir_names = @files.map{|local_path, remote_path| File.dirname remote_path}.uniq
        @shell.run "mkdir -p #{dir_names.join ' '}" if dir_names.any?
        @files.each do |local_path, remote_path|
          @shell.session.scp.upload! local_path, remote_path
        end
      end

      def remove
        @files.each{|local_path, remote_path| @shell.run "rm -f #{remote_path}"}
      end
    end
  end
end
