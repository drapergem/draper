module Draper
  module Compatibility
    # [Active Job](http://edgeguides.rubyonrails.org/active_job_basics.html) allows you to pass
    # ActiveRecord objects to background tasks directly and performs the necessary serialization
    # and deserialization. In order to do this, arguments to a background job must implement
    # [Global ID](https://github.com/rails/globalid).
    #
    # This compatibility patch implements Global ID for decorated objects by delegating to the object
    # that is decorated. This means you can pass decorated objects to background jobs, but 
    # the object won't be decorated when it is deserialized. This patch is meant as an intermediate
    # fix until we can find a way to deserialize the decorated object correctly.
    module GlobalID
      extend ActiveSupport::Concern

      included do
        include ::GlobalID::Identification

        delegate :to_global_id, :to_signed_global_id, to: :object
      end
    end
  end
end
