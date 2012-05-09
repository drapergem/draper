module Draper::ActiveModelSupport
  module Proxies
    def self.extended(base)
      # These methods (as keys) will be created only if the correspondent
      # model descends from a specific class (as value)
      proxies = {}
      proxies[:to_param] = ActiveModel::Conversion if defined?(ActiveModel::Conversion)
      proxies[:errors]   = ActiveModel::Validations if defined?(ActiveModel::Validations)
      proxies[:id]       = ActiveRecord::Base if defined?(ActiveRecord::Base)

      proxies.each do |method_name, dependency|
        if base.model.kind_of?(dependency) || dependency.nil?
          class << base
            self
          end.class_eval do
            send(:define_method, method_name) do |*args, &block|
              model.send(method_name, *args, &block)
            end
          end
        end
      end

      base.class_eval do
        def to_model
          self
        end
      end
    end
  end
end
