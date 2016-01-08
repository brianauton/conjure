module Conjure
  class LogRotate
    def initialize(options)
      @rails_env = options[:rails_env]
    end

    def apply(template)
      template.add_file_data config_file, "/etc/logrotate.d/application"
    end

    def system_packages
    end

    private

    def config_file
      '/home/app/application/shared/log/*.log {
    daily
    rotate 14
    missingok
    compress
    delaycompress
    copytruncate
}
'
    end
  end
end
