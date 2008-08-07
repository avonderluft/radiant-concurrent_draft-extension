module ConcurrentDraft::SiteControllerExtensions
  def self.included(base)
    base.class_eval do
      before_filter :publish_if_scheduled, :only => :show_page
    end
  end

  def publish_if_scheduled
    url = Array === params[:url] ? params[:url].join('/') : params[:url]
    page = Page.find_by_url(url, false)
    if page && !page.published? && page.draft_should_be_promoted?
      page.update_attribute('status_id', Status[:published].id)
    end
    true
  end
end