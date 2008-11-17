require File.dirname(__FILE__) + '/../spec_helper'

describe Page, "with concurrent draft" do
  scenario :pages_with_layouts
  before :each do
    @page = pages(:home)
  end
  
  it "should be publishable" do
    @page.publishable?.should be_true
  end

  describe "when promoting" do
  
    it "should promote its page parts" do
      @page.parts.each {|part| part.should_receive(:promote_draft!) }
      @page.promote_draft!
    end

    it "should update its status to published" do
      @page.update_attribute('status_id', Status[:draft].id)
      @page.promote_draft!
      @page.reload.status.should == Status[:published]
      @page.published?.should be_true
    end
  end
  
  describe "when unpublishing" do
    
    before(:each) do
      @page.promote_draft!
      @page.unpublish
    end
    
    it "should set the content of its page parts to nil" do
      @page.parts.each {|part| part.content.should be_nil}
    end
    
    it "should retain its draft content" do
      @page.part("body").should_not be_nil
    end    
  
    it "should set published_at, draft_promoted_at and draft_promotion_scheduled_at dates to nil" do
      @page.published_at.should be_nil
      @page.draft_promoted_at.should be_nil
      @page.draft_promotion_scheduled_at.should be_nil
    end  
    
    it "should update its status to draft" do
      @page.reload.status.should == Status[:draft]
      @page.published?.should be_false
    end
  end
  
end