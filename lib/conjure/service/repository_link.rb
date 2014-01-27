module Conjure
  module Service
    class RepositoryLink
      def initialize(options)
        @volume = options[:volume]
        @branch = options[:branch]
        @origin_url = options[:origin_url]
        @public_key = options[:public_key]
      end

      def update
        code_checked_out ? fetch_code_updates : checkout_code
      end

      def branch
        @branch ||= git_shell.command("cd #{code_path}; git rev-parse --abbrev-ref HEAD").strip
      end

      private

      def code_checked_out
        git_shell.command("[ -d #{code_path}/.git ] && echo yes; true").strip == "yes"
      end

      def checkout_code
        Log.info "[  repo] Checking out code from git"
        output = git_shell.command "git clone -b #{@branch} #{@origin_url} #{code_path}"
        raise "Access denied to git repo" if output.include? "Permission denied"
      end

      def fetch_code_updates
        Log.info "[  repo] Fetching code updates from git"
        git_shell.command "cd #{code_path}; git reset --hard; git checkout #{@branch}; git pull"
      end

      def code_path
        @volume.container_path
      end

      def git_shell
        @git_shell ||= ForwardedShell.new(:shell => @volume.shell.prepare({
          label: "git",
          setup_commands: [
            "apt-get install -y git",
            "mkdir -p /root/.ssh",
            "echo 'Host github.com\\n\\tStrictHostKeyChecking no\\n' >> /root/.ssh/config",
          ],
        }), :public_key => @public_key)
      end
    end
  end
end
