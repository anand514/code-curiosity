class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show]

  def index
    @users = current_user.is_judge? ? User.contestants : [current_user]
  end

  def show
    @user = User.find_by_slug(params[:id])

    if @user
      render layout: current_user ? 'application' : 'public'
    else
      redirect_to root_url, notice: 'Invalid user name'
    end
  end

  def sync
    unless current_user.gh_data_syncing?
      CommitJob.perform_later(current_user, 'all')
      ActivityJob.perform_later(current_user, 'all')
    end

    redirect_to repositories_path, notice: I18n.t('messages.repository_sync')
  end
end
