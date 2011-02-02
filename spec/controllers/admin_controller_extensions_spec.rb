require File.dirname(__FILE__) + '/../spec_helper'

shared_examples_for 'controller with scheduled draft promotion' do
  dataset :users

  before :each do
    create_user "Publisher", :publisher => true
    # controller.cache.clear
    @klass = controller.class.model_class
    @model_symbol = @klass.name.symbolize
    @object = mock_model(controller.class.model_class, :promote_draft! => nil, :save => true, :url => '')
    @object.errors.stub!(:full_messages).and_return([])
    @klass.stub!(:find).and_return(@object)
    login_as :admin
  end

  describe "common actions" do

    def do_post(options={})
      post(:schedule_draft_promotion, {:id => '1', :commit => @klass.promote_now_text}.merge(options))
    end

    it "should load the model" do
      @klass.should_receive(:find).with('1').and_return(@object)
      login_as :admin
      do_post
      assigns[@model_symbol].should == @object
    end

    it "should redirect back to the edit screen" do
      do_post
      response.should be_redirect
      response.should redirect_to(:action => "edit")
    end

    [:admin, :publisher].each do |user|
      describe "#{user} user" do
        before :each do
          login_as user
          #request.session[:user_id] = user_id(user)
        end
      
        it "should allow #{user}" do
          do_post
          response.should be_redirect
          response.should redirect_to(:action => "edit")
          flash[:error].should be_blank
        end
      end
    end
    
    [:designer, :existing].each do |user|
      before :each do
        login_as user
      end
      
      it "should deny #{user}" do
        do_post
        response.should be_redirect
        response.should redirect_to(:action => "edit")
        flash[:error].should == 'You must have publisher privileges to execute this action.'
      end
    end
  end

  describe "promoting/publishing now" do

    def do_post
      post :schedule_draft_promotion, :id => '1', :commit => @klass.promote_now_text
    end

    it "should promote the draft" do
      @object.should_receive(:promote_draft!)
      do_post
    end

    it "should set the flash message" do
      do_post
      flash[:notice].should match(/published|promoted/)
    end
  end

  describe "scheduling draft promotion" do
    def do_post
      post :schedule_draft_promotion, :id => '1',
                                      @model_symbol => @post_attrs,
                                      :commit => @klass.schedule_promotion_text
    end

    before :each do
      @post_attrs = {'draft_promotion_scheduled_at' => 3.days.from_now}
      @object.stub!(:update_attributes)
      @object.stub!(:draft_promotion_scheduled_at).and_return(3.days.from_now)
    end
    
    it "should not promote the draft" do
      @object.should_not_receive(:promote_draft!)
      do_post
    end

    it "should not cancel the draft" do
      @object.should_not_receive(:cancel_draft!)
      do_post
    end

    it "should set the flash notice message when the scheduled time is valid" do
      @object.should_receive(:update_attributes).with(@post_attrs).and_return(true)
      do_post
      flash[:notice].should match(/will be promoted/)
    end

    it "should set the flash error message when the scheduled time is invalid" do
      @object.should_receive(:update_attributes).with(@post_attrs).and_return(false)
      do_post
      flash[:error].should be
    end
  end

  describe "cancelling promotion" do
    def do_post
      post :schedule_draft_promotion, :id => '1', :commit => @klass.cancel_promotion_text
    end

    before :each do
      @object.stub!(:cancel_promotion!)
    end

    it "should cancel the draft promotion" do
      @object.should_receive(:cancel_promotion!)
      do_post
    end

    it "should set the flash message" do
      do_post
      flash[:notice].should match(/cancelled/)
    end
  end

  describe "promotion in conjunction with saving" do
    before :each do
      controller.class.skip_before_filter :filter_chain
      @klass.stub!(:find_by_id).and_return(@object)
      controller.stub!(:handle_new_or_edit_post_without_promotion).and_return(false)
    end
    
    it "should promote the draft when the 'Save & Promote Now' button was pushed" do
      @object.should_receive(:promote_draft!).once
      @object.should_receive(:update_attributes!).once
      put :update, :id => 1, :promote => 'Save & Promote Now'
    end
    
    it "should not promote the draft when the 'Save & Promote Now' button was not pushed" do
      @object.should_not_receive(:promote_draft!)
      @object.should_receive(:update_attributes!).once
      put :update, :id => 1
    end
  end
  
  after :each do
    logout
  end
end


describe Admin::PagesController, "with concurrent_draft functions" do
  it_should_behave_like 'controller with scheduled draft promotion'
end

describe Admin::SnippetsController, "with concurrent_draft functions" do
  it_should_behave_like 'controller with scheduled draft promotion'
end

describe Admin::LayoutsController, "with concurrent_draft functions" do
  it_should_behave_like 'controller with scheduled draft promotion'
end