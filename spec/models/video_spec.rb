require 'spec_helper'

describe Video, :type => :model do
  describe "accessing translations and related users" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @video = FactoryGirl.create(:video)
      @translation = Translation.create(:user => @user, :video => @video)
    end

    it "should be able to access translations through video.translations" do
      expect {@video.translations}.not_to raise_error
      translations = @video.translations
      expect(translations).to include @translation
    end

    it "should be able to access users through video.translators" do
      expect {@video.translators}.not_to raise_error
      translators = @video.translators
      expect(translators).to include @user
    end
  end
  describe "methods related to translations" do
    before(:each) do
      @video = FactoryGirl.create(:video)
      @user = FactoryGirl.create(:user)
      @translation = Translation.create(:user => @user, :video => @video)
    end

    it "should claim it is unassigned if there is no user/video associated with it" do
      expect(Video.new.assigned?).to eq false
    end
    it "should claim it is assigned if there is a user/video associated with it" do
      expect(@video.assigned?).to eq true
    end
  end
  describe "uploading CRTs" do
    it "should reject a missing file" do
      expect {Video.import(nil)}.to raise_error
    end 
    it "should reject a file with the wrong extension" do
      expect {Video.import("a.csv")}.to raise_error
    end 
    it "should correctly identify when translated are not recent" do
      @video.stub(:translations).and_return([@translation])
      @translation.stub(:complete?).and_return(true)
      @translation.stub(:time_updated).and_return(1.day.ago)
      expect(Video.recently_translated_videos(Time.now)).not_to include @video
    end
  end
end
