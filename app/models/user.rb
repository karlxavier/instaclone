# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :confirmable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, presence: true, uniqueness: { case_sensitive: false }

  has_many :photos, dependent: :delete_all
  has_many :comments, dependent: :delete_all

  has_many :friendships, dependent: :destroy
  has_many :friends, -> { where(friendships: { status: Friendship::STATUS[:accepted] }) }, through: :friendships

  def pending_requests
    friendships.where(status: Friendship::STATUS[:pending])
  end
end
