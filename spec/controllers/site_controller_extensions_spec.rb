require File.dirname(__FILE__) + '/../spec_helper'
require 'site_controller'
SiteController.module_eval { def rescue_action(e); raise e; end }

describe SiteController, "(Extended) - concurrent draft changes" do
  scenario :users_and_pages
  
  before :each do
    @page = mock_model(Page, :published? => false, :draft_should_be_promoted? => true, :process => nil, :update_attribute => nil)
    Page.stub!(:find_by_url).and_return(@page)
  end

  it "should include the extension module" do
    SiteController.included_modules.should include(ConcurrentDraft::SiteControllerExtensions)
  end

  it "should add the before filter" do
    SiteController.before_filters.should be_any {|f| f == :publish_if_scheduled }
  end
  
  it "should run the before filter" do
    self.controller.should_receive(:publish_if_scheduled)
    get :show_page, :url => '/'
  end

  it "should set the status to published if the draft should be promoted" do
    Page.should_receive(:find_by_url).at_least(:once).and_return(@page)
    @page.should_receive(:update_attribute).with('status_id', Status[:published].id)
    get :show_page, :url => '/'
  end
end