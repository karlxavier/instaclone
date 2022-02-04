class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  STATUS = { 
    pending: 'pending',
    requested: 'requested',
    accepted: 'accepted',
    declined: 'declined'
  }

  validates_presence_of :user_id, :friend_id
  validates_uniqueness_of :user_id, scope: [:friend_id]
  validates :status, inclusion: { in: STATUS.keys.map(&:to_s) }, allow_blank: true

  class << self
    def request(user, friend)
      unless user == friend or user.friends.exists?(friendships: { friend_id: friend.id })
        transaction do
          create(user: user, friend: friend, status: STATUS[:pending], requested_at: Time.now)
          create(user: friend, friend: user, status: STATUS[:requested], requested_at: Time.now)
        end
      end
    end

    def accept(user, friend)
      if user.pending_requests.exists?(friend_id: friend.id)
        transaction do
          accepted_at = Time.now
          acceptance(user, friend, accepted_at)
          acceptance(friend, user, accepted_at)
        end
      end
    end

    def decline(user, friend)
      if user.pending_requests.exists?(friend_id: friend.id)
        request = find_by_user_id_and_friend_id(user, friend)
        request.status = STATUS[:declined]
        request.save!
      end
    end

    def acceptance(user, friend, accepted_at)
      request = find_by_user_id_and_friend_id(user, friend)
      return false unless request.present?
  
      request.status = STATUS[:accepted]
      request.accepted_at = accepted_at
      request.save!
    end
  end
end
