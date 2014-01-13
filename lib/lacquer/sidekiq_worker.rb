module Lacquer
  class SidekiqWorker
    include Sidekiq::Worker

    sidekiq_options queue: :lacquer

    def perform(urls)
      Varnish.new.purge(*urls)
    end
  end
end
