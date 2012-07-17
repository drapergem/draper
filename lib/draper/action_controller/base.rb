module DraperViewContext
  def view_context
    super.tap do |context|
      Draper::ViewContext.current = context
    end
  end
end

ActionController::Base.send(:include, DraperViewContext)
