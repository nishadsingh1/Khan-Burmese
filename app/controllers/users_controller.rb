class UsersController < ApplicationController

  @@LEADERBOARD_LIMIT = 10
  
  def show
    @user = User.find(params[:id])
    @assigned_videos = @user.untranslated_videos
    @translated_videos = @user.translated_videos
    @reviewed_videos = @user.reviewed_videos
  end

  def update
    @user = User.find params[:id]

    authorize! :edit, @user

    if @user.update_attributes!(params[:user])
      respond_to do |format|
        format.html { redirect_to @user }
        format.json { render :json => @user }
      end
    else
      respond_to do |format|
        format.html { redirect_to :back }
        format.json { render :nothing => true }
      end
    end
  end

  def leaderboard
    @standings = params[:standings]
    if @standings.nil?
      redirect_to leaderboard_path(:standings => 'all_time')
      return
    end
    @leaders = User.leaders(@standings).take(@@LEADERBOARD_LIMIT)
  end
end
