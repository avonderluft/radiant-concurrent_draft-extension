require File.dirname(__FILE__) + '/../spec_helper'

admin_controllers = [Admin::PagesController, Admin::SnippetsController, Admin::LayoutsController]
admin_controllers.each do |controller|

  # Re-raise errors caught by the controller.
  controller.class_eval { def rescue_action(e) raise e end }

  describe controller, "with concurrent_draft functions" do
    dataset :users

    before :each do
      create_user "Publisher", :publisher => true
      @klass = controller.model_class
      @model_symbol = @klass.name.symbolize
      @object = mock_model(@klass, :promote_draft! => nil, :save => true, :url => '')
      @object.errors.stub!(:full_messages).and_return([])
      @klass.stub!(:find).and_return(@object)
      
      def do_post(options={})
        post(:schedule_draft_promotion, {:id => '1'}.merge(options))
      end
      
    end
    
    describe "allowed users" do
      [:admin, :publisher].each do |user|
        before :each do
          login_as user
        end      
        it "should allow #{user}" do
          @controller.authorized_user?.should be_true
          do_post(:commit => @klass.promote_now_text)
          response.should be_redirect
          response.should redirect_to(:action => "edit")
          flash[:error].should be_blank
        end  
        after :each do
          logout
        end
      end
    end
    
    describe "denied users" do    
      [:non_admin, :existing, :another].each do |user|
        before :each do
          login_as user
        end
        it "should deny #{user}" do
          @controller.authorized_user?.should be_false
          do_post(:commit => @klass.promote_now_text)
          response.should be_redirect
          response.should redirect_to(:action => "edit")
          flash[:error].should == 'You must have publisher privileges to execute this action.'
        end
        after :each do
          logout
        end
      end
    end
  
    describe "publisher actions" do
          
      before :each do
        login_as :publisher
      end
      
      it "should load the model" do 
        @klass.should_receive(:find).with('1').and_return(@object)
        do_post(:commit => @klass.promote_now_text) 
        assigns[@model_symbol].should == @object
      end
      
      it "should redirect back to the edit screen" do
        do_post(:commit => @klass.promote_now_text) 
        response.should be_redirect
        response.should redirect_to(:action => "edit")      
      end
      describe "promoting/publishing now" do
        it "should promote the draft" do
          @object.should_receive(:promote_draft!)
          do_post(:commit => @klass.promote_now_text) 
        end

        it "should set the flash message" do
          do_post(:commit => @klass.promote_now_text) 
          flash[:notice].should match(/published|promoted/)
        end
      end
      
      describe "scheduling draft promotion" do
                
        before :each do
          @post_attrs = {'draft_promotion_scheduled_at' => 3.days.from_now}
          @object.stub!(:update_attributes)
          @object.stub!(:draft_promotion_scheduled_at).and_return(3.days.from_now)
        end

        it "should not promote the draft" do
          @object.should_not_receive(:promote_draft!)
          do_post(@model_symbol => @post_attrs,:commit => @klass.schedule_promotion_text)
        end

        it "should not cancel the draft" do
          @object.should_not_receive(:cancel_draft!)
          do_post(@model_symbol => @post_attrs,:commit => @klass.schedule_promotion_text)
        end

        it "should set the flash notice message when the scheduled time is valid" do
          @object.should_receive(:update_attributes).with(@post_attrs).and_return(true)
          do_post(@model_symbol => @post_attrs,:commit => @klass.schedule_promotion_text)
          flash[:notice].should match(/will be promoted/)
        end

        it "should set the flash error message when the scheduled time is invalid" do
          @object.should_receive(:update_attributes).with(@post_attrs).and_return(false)
          do_post(@model_symbol => @post_attrs,:commit => @klass.schedule_promotion_text)
          flash[:error].should be
        end
      end
      
      describe "cancelling promotion" do
        before :each do
          @object.stub!(:cancel_promotion!)
        end

        it "should cancel the draft promotion" do
          @object.should_receive(:cancel_promotion!)
          do_post(:commit => Page.cancel_promotion_text)
        end

        it "should set the flash message" do
          do_post(:commit => Page.cancel_promotion_text)
          flash[:notice].should match(/cancelled/)
        end
      end
      
      describe "promotion in conjunction with saving" do
        before :each do
          @klass.stub!(:find_by_id).and_return(@object)
          controller.stub!(:handle_new_or_edit_post_without_promotion).and_return(false)
        end

        it "should promote the draft when the 'Save and Promote Now' button was pushed" do
          @object.should_receive(:promote_draft!)
          do_post(:commit => @klass.promote_now_text)
          post(:edit, :id => '1', :promote => "Save and Promote Now")
        end

        it "should not promote the draft when the 'Save and Promote Now' button was not pushed" do
          @object.should_not_receive(:promote_draft!)
          post(:edit, :id => '1', :commit => "Save and Exit")
        end
      end
      
      after :each do
        logout
      end
    end

  end
end  

