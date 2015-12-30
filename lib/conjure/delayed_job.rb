module Conjure
  class DelayedJob
    def initialize(options)
      @rails_env = options[:rails_env]
    end

    def apply(template)
      template.add_file_data monit_rc, "/etc/monit/monitrc"
      template.run "chmod 0600 /etc/monit/monitrc"
      template.add_file_data monit_run, "/etc/service/monit/run"
      template.run "chmod 0700 /etc/service/monit/run"
    end

    def system_packages
      ["monit"]
    end

    private

    def monit_rc
      command = "/usr/bin/env RAILS_ENV=#{@rails_env} /home/app/application/current/bin/delayed_job"
      'set daemon 10
set logfile /var/log/monit.log
set idfile /var/lib/monit/id
set statefile /var/lib/monit/state
check process delayed_job
  with pidfile /home/app/application/shared/tmp/pids/delayed_job.pid
  start program = "' + command + ' start" as uid "app" and gid "app"
  stop program = "' + command + ' stop" as uid "app" and gid "app"
'
    end

    def monit_run
      '#!/bin/sh
exec /usr/bin/monit -I
'
    end
  end
end
