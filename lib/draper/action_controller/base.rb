module DraperViewContext
  def view_context
    super.tap do |context|
      Draper::ViewContext.current = context
    end
  end
end

ApplicationController.send(:include, DraperViewContext)
