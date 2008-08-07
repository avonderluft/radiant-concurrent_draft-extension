require File.dirname(__FILE__) + '/../spec_helper'

share_examples_for "model with concurrent draft" do
  it "should be invalid with a draft promotion schedule date in the past" do
    @object.draft_promotion_scheduled_at = 2.days.ago
    @object.should_not be_valid
    @object.should have(1).error_on(:draft_promotion_scheduled_at)
  end

  it "should be valid with a draft promotion schedule date in the future" do
    @object.draft_promotion_scheduled_at = 1.day.from_now
    @object.should be_valid
    @object.should have(0).errors_on(:draft_promotion_scheduled_at)
  end

  describe "after draft promotion" do
    before :each do
      @object.promote_draft!
    end

    it "should have copied the content from the draft content" do
      if @object.respond_to?(:content)
        @object.content.should == @object.draft_content
      end
    end

    it "should have set the promotion date/time" do
      @object.draft_promoted_at.should be_close(Time.now, 10)
    end

    it "should have cleared the scheduled date" do
      @object.draft_promotion_scheduled_at.should be_nil
    end

    it "should have promoted the draft" do
      @object.should have_draft_promoted
    end
  end

  it "should have the draft promotion scheduled if the date is in the future" do
    @object.draft_promotion_scheduled_at = 1.day.from_now
    @object.should have_draft_promotion_scheduled
  end

  it "should cancel the scheduled promotion" do
    @object.draft_promotion_scheduled_at = 1.day.from_now
    @object.cancel_promotion!
    @object.draft_promotion_scheduled_at.should be_nil
  end

  it "should be promoted when the promotion time has past" do
    @object.draft_promotion_scheduled_at = 1.minute.ago
    @object.should be_draft_should_be_promoted
  end
end

describe Snippet, "with concurrent draft" do
  scenario :snippets
  before :each do
    @object = snippets(:first)
    @object.update_attributes(:content => 'content test', :draft_content => 'draft content')
  end
  it_should_behave_like 'model with concurrent draft'
end

describe Layout, "with concurrent draft" do
  scenario :layouts
  before :each do
    @object = layouts(:main)
    @object.update_attributes(:content => 'content test', :draft_content => 'draft content')
  end
  it_should_behave_like 'model with concurrent draft'
end

describe PagePart, "with concurrent draft" do
  scenario :pages
  before :each do
    @object = pages(:home).parts.first
    @object.update_attributes(:content => 'content test', :draft_content => 'draft content')
  end

  describe "after draft promotion" do
    before :each do
      @object.promote_draft!
    end

    it "should have copied the content from the draft content" do
      @object.content.should == @object.draft_content
    end
  end
end

describe Page, 'with concurrent draft' do
  scenario :pages
  before :each do
    @object = pages(:home)
  end

  it_should_behave_like 'model with concurrent draft'
end