require 'spec_helper'

describe TranslationsController do
  describe "create translation" do
    login_user

    before(:each) do
      @user = User.find_by_email('normal@user.com')
      @video = FactoryGirl.create(:video)
    end

    it "should create a single translation" do
      expect {
        put 'create', :user_id => @user.id, :video_id => @video.id
      }.to change(Translation, :count).by(1)
    end

    it "error upon creating two translations for the same user and video" do
      put 'create', :user_id => @user.id, :video_id => @video.id

      expect {
        put 'create', :user_id => @user.id, :video_id => @video.id
      }.not_to change(Translation, :count)
    end
  end
  describe "destroy translation" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @video = FactoryGirl.create(:video)
      @translation = Translation.create(:user => @user, :video => @video)
    end

    it "should delete a single translation" do
      expect{@translation.destroy}.to change(Translation, :count).by(-1)
    end

    it "should remove association between user and video" do
      @translation.destroy
      expect(@user.translation_videos).not_to include @video
      expect(@video.translators).not_to include @user
    end
  end
  describe "upload, vote" do
    before(:each) do
      @user = User.all.first || FactoryGirl.create(:user)
      @video = Video.all.first || FactoryGirl.create(:video)
      @translation = Translation.create(:user => @user, :video => @video)
      controller.stub(:params).and_return({:video_id => @video.id, :translation_id => @translation.id})
      controller.stub(:redirect_to).and_return(nil)
      controller.stub(:current_user).and_return(@user)
      controller.stub(:authorize!)
      controller.stub(:render).and_return(nil)
    end

    it "should raise an error if the uploading fails" do
      @translation.stub(:upload_srt).and_raise("error")
      controller.upload
      expect(controller.flash[:alert]).to include "Missing file."
    end

     it "should correctly register a vote" do
      expect {controller.vote}.to change(@translation, :net_votes).by(1)
    end
  end
end
