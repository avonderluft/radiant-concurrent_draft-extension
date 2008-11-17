module ConcurrentDraft::PageExtensions
  
  def promote_draft!
    parts.each(&:promote_draft!)
    update_attribute('status_id', Status[:published].id)
    super
  end
  
  def unpublish
    parts.each(&:unpublish)
    update_attributes('published_at' => nil, 'status_id' => Status[:draft].id)
    super
  end
  
end