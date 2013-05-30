require 'active_support/concern'

module Draper
  module SimpleFormBuilderExtension
    extend ActiveSupport::Concern

    included do
      alias_method_chain :association, :decoration
    end

    def association_with_decoration(association, options = {}, &block)
      reflection = find_association_reflection(association)
      raise "Association #{association.inspect} not found" unless reflection

      options[:collection] ||= options.fetch(:collection) {
        conditions = reflection.options[:conditions]
        conditions = conditions.call if conditions.respond_to?(:call)
        relation = reflection.klass.where(conditions).order(reflection.options[:order])
        relation = relation.decorate if relation.respond_to?(:decorate)
        relation
      }
      association_without_decoration association, options, &block
    end
  end
end
::SimpleForm::FormBuilder.send :include, Draper::SimpleFormBuilderExtension
