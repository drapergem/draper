<% if RSpec::Rails::Version::STRING.match(/\A3\.[^10]/) %>
  require 'rails_helper'
<% else %>
  require 'spec_helper'
<% end %>

describe <%= class_name %>Decorator do
  
end
