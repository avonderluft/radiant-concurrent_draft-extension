module ConcurrentDraft::AdminControllerExtensions
  def self.included(base)
    base.class_eval do
      helper_method :model
      helper_method :model_class
      public :model, :model_class
      only_allow_access_to :schedule_draft_promotion, :unpublish,
          :when => [:publisher, :admin],
          :denied_message => "You must have publisher privileges to execute this action.",
          :denied_url => {:action => 'edit'}
      after_filter :check_for_promote_now, :only => [:create, :update]
    end
  end

  def authorized_user?
    (current_user.publisher? || current_user.admin?)
  end

  def check_for_promote_now
    if params[:promote] && authorized_user?
      model.promote_draft!
      flash[:notice] = "The existing draft #{model_class.to_s.downcase} has been saved and promoted, and is now live."
      flash.keep
    end
  end

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
    model.unpublish!
    flash[:notice] = "#{model_class} has been unpublished and reset to draft mode -- no draft promotion scheduled."
    redirect_to :action => "edit"
  end
end
