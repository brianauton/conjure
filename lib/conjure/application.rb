module Conjure
  class Application
    attr_reader :origin

    def self.find(options = {})
      new(options)
    end

    def instances
      Instance.where(:origin => @origin)
    end

    def data_sets
      DataSet.find(:origin => @origin)
    end

    def name
      match = @origin.match(/\/([^.]+)\.git$/) if @origin
      match[1] if match
    end

    private

    def initialize(options = {})
      @origin = options[:origin] || origin_from_path(options[:path])
    end

    def origin_from_path(path)
      return unless path
      remote_info = `cd #{path}; git remote -v |grep origin`
      match = remote_info.match(/(git@github.com[^ ]+)/)
      match[1] if match
    end
  end
end
