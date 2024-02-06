module Draper
  module Compatibility
    # [Active Job](http://edgeguides.rubyonrails.org/active_job_basics.html) allows you to pass
    # ActiveRecord objects to background tasks directly and performs the necessary serialization
    # and deserialization. In order to do this, arguments to a background job must implement
    # [Global ID](https://github.com/rails/globalid).
    #
    # This compatibility patch implements Global ID for decorated objects by defining `.find(id)`
    # class method that uses the original one and decorates the result.
    # This means you can pass decorated objects to background jobs and they will be decorated when
    # deserialized.
    module GlobalID
      extend ActiveSupport::Concern

      included do
        include ::GlobalID::Identification
      end

      class_methods do
        def find(*args)
          object_class.find(*args).decorate
        end
      end
    end
  end
end
