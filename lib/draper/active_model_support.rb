module Draper::ActiveModelSupport
  module Proxies
    def self.extended(base)
      # These methods (as keys) will be created only if the correspondent
      # model responds to the method
      proxies = [:to_param, :errors, :id]

      proxies.each do |method_name|
        if base.model.respond_to?(method_name)
          base.singleton_class.class_eval do
            if !base.class.instance_methods.include?(method_name) || base.class.instance_method(method_name).owner === Draper::Base
              define_method(method_name) do |*args, &block|
                model.send(method_name, *args, &block)
              end
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
