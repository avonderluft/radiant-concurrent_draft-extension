require File.dirname(__FILE__) + '/../spec_helper'

describe "ConcurrentDraft::Tags" do
  dataset :pages, :snippets
  describe '<r:content>' do
    before :each do
      @page = pages(:home)
      @page.part(:body).update_attribute('draft_content', 'Draft body.')
    end
  
    it "should render the published content on the live site" do
      @page.should render('<r:content />').as("Hello world!")
    end
  
    it "should render the draft content on the dev site" do
      @page.should render('<r:content />').as("Draft body.").on('dev.host')
    end
  end
  
  describe "<r:snippet>" do
    before :each do
      @snippet = snippets(:first)
      @snippet.update_attribute(:draft_content, 'Draft content.')
      @page = pages(:home)
    end

    it "should render published snippet content on the live site" do
      @page.should render('<r:snippet name="first" />').as('test')
    end

    it "should render draft snippet content on the dev site" do
      @page.should render('<r:snippet name="first" />').as('Draft content.').on('dev.host')
    end
    
    it "should promote the draft body if it is scheduled" do
      @snippet.update_attribute(:draft_promotion_scheduled_at, 1.second.from_now)
      sleep 2
      @page.should render('<r:snippet name="first" />').as('Draft content.')
      @snippet.reload
      @snippet.should be_has_draft_promoted
    end
  end
end