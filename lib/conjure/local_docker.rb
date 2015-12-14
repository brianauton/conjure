module Conjure
  class LocalDocker
    def run(command)
      `#{command}`
    end

    def with_directory(path)
      yield path
    end

    def ip_address
    end
  end
end
