class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, :lockable, :timeoutable

  has_many :tweets, dependent: :destroy
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  has_many :reverse_relationships, foreign_key: "followed_id",
                                   class_name: 'Relationship',
                                   dependent: :destroy
  has_many :followers, through: :reverse_relationships, source: :follower

  before_save { self.email = email.downcase }
 
  validates :name, presence: true, length: { maximum: 50 }
  validates :slug, uniqueness: true

  def to_param
    slug
  end

  def feed
    r = Relationship.arel_table
    t = Tweet.arel_table
    sub_query = t[:user_id].in(r.where(r[:follower_id].eq(id)).project(r[:followed_id]))
    Tweet.where(sub_query.or(t[:user_id].eq(id)))

    # - No Arel -
    # followed_user_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
    # where("user_id IN (#{followed_user_ids}) OR user_id = :user_id", user_id: user)
  end

  def following?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by(followed_id: other_user.id).destroy
  end

end
