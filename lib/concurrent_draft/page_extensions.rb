module ConcurrentDraft::PageExtensions

  def self.included(base)
    base.class_eval do
      alias_method_chain :process, :concurrent_draft
      alias_method_chain :layout, :concurrent_draft
    end
  end

  def layout_with_concurrent_draft
    returning layout_without_concurrent_draft do |l|
      l.promote_draft! if l.draft_should_be_promoted?
    end
  end

  ##
  def process_with_concurrent_draft(request, response)
    promote_draft! if draft_should_be_promoted?
    process_without_concurrent_draft(request, response)
  end

  def promote_draft!
    parts.each(&:promote_draft!)
    # Need to think this over...
    # update_attribute('status_id', Status[:published].id)
    super
  end
end