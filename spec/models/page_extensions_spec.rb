require File.dirname(__FILE__) + '/../spec_helper'

describe Page, "with concurrent draft" do
  scenario :pages_with_layouts
  before :each do
    @page = pages(:home)
  end

  it "should promote its page parts when promoting" do
    @page.parts.each {|part| part.should_receive(:promote_draft!) }
    @page.promote_draft!
  end

  it "should update its status to published when promoting" do
    @page.update_attribute('status_id', Status[:draft].id)
    @page.promote_draft!
    @page.reload.status.should == Status[:published]
  end
end