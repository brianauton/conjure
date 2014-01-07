module Conjure
  class Application
    attr_reader :origin_url, :name

    def initialize(options = {})
      @origin_url = options[:origin_url] || find_origin_url(options[:path])
      @name = find_name(@origin_url) if @origin_url
    end

    def instances
      Instance.find(:application => self)
    end

    def data_sets
      DataSet.find(:application => self)
    end

    private

    def find_name(origin_url)
      match = origin_url.match(/\/([^.]+)\.git$/)
      match[1] if match
    end

    def find_origin_url(path)
      return unless path
      remote_info = `cd #{path}; git remote -v |grep origin`
      match = remote_info.match(/(git@github.com[^ ]+)/)
      match[1] if match
    end
  end
end
