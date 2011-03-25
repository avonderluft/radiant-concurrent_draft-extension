module ConcurrentDraft::ModelExtensions

  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      validate :promotion_date_in_future
      if instance_methods.include?('after_initialize')
        alias_method_chain :after_initialize, :drafts
      else
        def after_initialize
          promote_on_load
        end
      end
    end
  end

  module ClassMethods
    def promote_now_text; "Promote Now" end
    def schedule_promotion_text; "Schedule for promotion on -->" end
    def cancel_promotion_text; "Cancel scheduled promotion" end
  end
  
  def display_name
    if self.respond_to?(:title)
      self.title
    elsif self.respond_to?(:name)
      self.name
    else
      'resource'
    end
  end

  def promotion_date_in_future
    if respond_to?(:draft_promotion_scheduled_at) && !draft_promotion_scheduled_at.blank? && draft_promotion_scheduled_at < Time.now
      errors.add :draft_promotion_scheduled_at, "may not be in the past"
    end
  end

  def promote_on_load
    promote_draft! if respond_to?(:draft_promotion_scheduled_at) && draft_should_be_promoted?
  end

  def after_initialize_with_drafts
    promote_on_load
    after_initialize_without_drafts
  end

  def has_draft_promotion_scheduled?
    !draft_promotion_scheduled_at.blank?
  end
  
  def has_draft_promoted?
    !draft_promoted_at.blank? && draft_promoted_at <= Time.now
  end

  def cancel_promotion!
    update_attribute("draft_promotion_scheduled_at", nil)
  end
  
  def draft_should_be_promoted?
    has_draft_promotion_scheduled? && draft_promotion_scheduled_at <= Time.now
  end

  def promote_draft!
    update_attributes("content" => draft_content) if respond_to?(:content) && respond_to?(:draft_content)
    update_attributes("draft_promotion_scheduled_at" => nil, "draft_promoted_at" => Time.now) if respond_to?(:draft_promoted_at)
    Radiant::Cache.clear if defined?(Radiant::Cache)
  end
  
  def unpublish!
    update_attributes("content" => nil) if respond_to?(:content) && respond_to?(:draft_content)
    update_attributes("draft_promotion_scheduled_at" => nil, "draft_promoted_at" => nil) if respond_to?(:draft_promoted_at)
  end
  
  def publishable?
    has_attribute?("published_at") && has_attribute?("status_id")
  end
  
end
