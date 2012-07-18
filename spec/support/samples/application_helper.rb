require 'active_support/core_ext/string/output_safety.rb'
module ApplicationHelper
  include ERB::Util

  def hello_world
    "Hello, World!"
  end
end
