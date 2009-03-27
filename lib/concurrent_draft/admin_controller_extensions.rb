module ConcurrentDraft::AdminControllerExtensions
  def self.included(base)
    base.class_eval do
      #helper_method :model
      #helper_method :model_class
      #public :model, :model_class
      alias_method_chain :create, :promotion
      alias_method_chain :update, :promotion
      # alias_method_chain :handle_new_or_edit_post, :promotion
      only_allow_access_to :schedule_draft_promotion, :unpublish,
          :when => [:publisher, :admin],
          :denied_message => "You must have publisher privileges to execute this action.",
          :denied_url => {:action => 'edit'}
    end
  end

  # create
  def create_with_promotion(options = {})
    returning create_without_promotion(options) do |result|
      model.promote_draft! if params[:promote] && !result && (current_user.publisher? || current_user.admin?)
    end
  end

  # update
  def update_with_promotion(options = {})
    returning update_without_promotion(options) do |result|
      model.promote_draft! if params[:promote] && !result && (current_user.publisher? || current_user.admin?)
    end
  end

  # def handle_new_or_edit_post_with_promotion(options = {})
  #   returning handle_new_or_edit_post_without_promotion(options) do |result|
  #     model.promote_draft! if params[:promote] && !result && (current_user.publisher? || current_user.admin?)
  #   end
  # end

  def schedule_draft_promotion
    self.model = model_class.find(params[:id])
    case params[:commit]
    when model_class.promote_now_text
      model.promote_draft!
      flash[:notice] = "The existing draft #{model_class.to_s.downcase} has been promoted and is now live."
    when model_class.schedule_promotion_text
      if model.update_attributes(params[model_symbol])
        flash[:notice] = "The draft #{model_class.to_s.downcase} will be promoted on #{model.draft_promotion_scheduled_at.to_s(:long_civilian)}."
      else
        flash[:error] = model.errors.full_messages.to_sentence
      end
    when model_class.cancel_promotion_text
      model.cancel_promotion!
      flash[:notice] = "The scheduled draft #{model_class.to_s.downcase} promotion has been cancelled."
    end
    redirect_to :action => "edit"
  end
  
  def unpublish
    self.model = model_class.find(params[:id])
    model.unpublish
    flash[:notice] = "#{model_class} has been unpublished and reset to draft mode -- no draft promotion scheduled."
    redirect_to :action => "edit"
  end
  
end
