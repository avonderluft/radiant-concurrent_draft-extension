module ConcurrentDraft::AdminControllerExtensions
  def self.included(base)
    base.class_eval do
      helper_method :model
      helper_method :model_class
      alias_method_chain :handle_new_or_edit_post, :promotion
    end
  end
  
  def handle_new_or_edit_post_with_promotion(options = {})
    returning handle_new_or_edit_post_without_promotion(options) do |result|
      model.promote_draft! if params[:promote] && !result
    end
  end
  
  def schedule_draft_promotion
    self.model = model_class.find(params[:id])
    case params[:commit]
    when model_class.promote_now_text
      model.promote_draft!
      flash[:notice] = "The existing draft was promoted and is now live."
    when model_class.schedule_promotion_text
      if model.update_attributes(params[model_symbol])
        flash[:notice] = "The draft will be promoted on #{model.draft_promotion_scheduled_at.to_s(:long_civilian)}."
      else
        flash[:error] = model.errors.full_messages.to_sentence
      end
    when model_class.cancel_promotion_text
      model.cancel_promotion!
      flash[:notice] = "The draft promotion schedule was cancelled."
    end
    redirect_to :action => "edit"
  end
end