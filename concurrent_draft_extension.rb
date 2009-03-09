# Uncomment this if you reference any of your controllers in activate
require_dependency 'application'

class ConcurrentDraftExtension < Radiant::Extension
  version "1.0"
  description "Enables default draft versions of pages, snippets and layouts, which can be scheduled for promotion to Production"
  url "http://github.com/avonderluft/concurrent_draft/tree/master"

  define_routes do |map|
    map.page_schedule_draft_promotion 'admin/pages/schedule_draft_promotion/:id', 
      :controller => 'admin/page', :action => 'schedule_draft_promotion'
    map.snippet_schedule_draft_promotion 'admin/snippet/schedule_draft_promotion/:id', 
      :controller => 'admin/snippet', :action => 'schedule_draft_promotion'
    map.layout_schedule_draft_promotion 'admin/layout/schedule_draft_promotion/:id', 
      :controller => 'admin/layout', :action => 'schedule_draft_promotion' 
    map.page_unpublish 'admin/pages/unpublish/:id', :controller => 'admin/page', :action => 'unpublish'
  end
  
  def activate
    [Page, Snippet, Layout, PagePart].each do |klass|
      klass.send :include, ConcurrentDraft::ModelExtensions
    end
    Page.send :include, ConcurrentDraft::PageExtensions
    Page.send :include, ConcurrentDraft::Tags
    [Admin::PageController, Admin::SnippetController, Admin::LayoutController].each do |klass|
      klass.send :include, ConcurrentDraft::AdminControllerExtensions
      klass.class_eval do
        helper ConcurrentDraft::HelperExtensions
      end
    end
    SiteController.send :include, ConcurrentDraft::SiteControllerExtensions
    %w{page snippet layout}.each do |view|
      admin.send(view).edit.add :main, "admin/draft_controls", :before => "edit_header"
      admin.send(view).edit.form_bottom.delete 'edit_buttons'
      admin.send(view).edit.add :form_bottom, 'admin/edit_buttons'
    end
    admin.page.edit.add :extended_metadata, 'published_meta'
    Time::DATE_FORMATS[:long_civilian] = lambda {|time| time.strftime("%B %d, %Y %I:%M%p").gsub(/(\s+)0(\d+)/, '\1\2') }
  end
end