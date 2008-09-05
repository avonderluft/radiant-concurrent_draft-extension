module ConcurrentDraft::PageExtensions
  def promote_draft!
    parts.each(&:promote_draft!)
    update_attribute('status_id', Status[:published].id)
    super
  end
end