module Qg
  module Sm
    class Engine < ::Rails::Engine
      initializer :assets do |config|
        Rails.application.config.assets.paths << root.join("app", "assets", "images", "sm")
      end
      
      initializer :append_migrations do |app|
        unless app.root.to_s.match "#{root}/"
          config.paths['db/migrate'].expanded.each do |expanded_path|
            app.config.paths['db/migrate'] << expanded_path
          end
        end
      end
    end
  end
end
