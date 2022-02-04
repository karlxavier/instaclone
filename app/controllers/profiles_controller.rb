# frozen_string_literal: true

class ProfilesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  before_action :authenticate_user!, only: %i[request accept decline]
  before_action :set_friend, only: %i[request accept decline]

  def index
    @users = if params[:username]&.present?
               User.where(username: params[:username])
             else
               User.limit(20)
             end
  end

  def show
    @user = User.find_by! username: params[:username]
  end

  def request
    Friendship.request(current_user, friend) if friend.present?
    redirect_to :back
  end

  def accept
    Friendship.accept(current_user, friend) if friend.present?
    redirect_to :back
  end

  def decline
    Friendship.decline(current_user, friend) if friend.present?
    redirect_to :back
  end

  private

  def set_friend
    friend = User.find(params[:id])
  end
end
