require File.dirname(__FILE__) + '/../spec_helper'

describe Page, "with concurrent draft" do
  scenario :pages_with_layouts
  before :each do
    @page = pages(:home)
  end
  
  it "should promote its layout when accessed if necessary" do
    @layout = layouts(:main)
    @layout.update_attributes(:draft_promotion_scheduled_at => 1.second.from_now, :draft_content => "test")
    sleep 2 # necessary so we can wait until the time has passed
    @page.layout.content.should == 'test'
    @page.layout.draft_promotion_scheduled_at.should be_nil
    @page.layout.draft_promoted_at.should be_close(Time.now, 10)
  end
  
  it "should promote its page parts when promoting" do
    @page.parts.each {|part| part.should_receive(:promote_draft!) }
    @page.promote_draft!
  end
  
  it "should promote the scheduled draft when scheduled time has passed" do
    request, response = mock('request'), mock('response')
    @page.should_receive(:draft_should_be_promoted?).and_return(true)
    @page.should_receive(:promote_draft!)
    @page.should_receive(:process_without_concurrent_draft)
    @page.process(request, response)
  end
end