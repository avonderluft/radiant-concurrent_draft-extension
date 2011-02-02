ActionController::Routing::Routes.draw do |map|
  map.page_schedule_draft_promotion 'admin/pages/schedule_draft_promotion/:id',
    :controller => 'admin/pages', :action => 'schedule_draft_promotion'
  map.snippet_schedule_draft_promotion 'admin/snippet/schedule_draft_promotion/:id',
    :controller => 'admin/snippets', :action => 'schedule_draft_promotion'
  map.layout_schedule_draft_promotion 'admin/layout/schedule_draft_promotion/:id',
    :controller => 'admin/layouts', :action => 'schedule_draft_promotion'
  map.page_unpublish 'admin/pages/unpublish/:id', :controller => 'admin/pages', :action => 'unpublish'
end