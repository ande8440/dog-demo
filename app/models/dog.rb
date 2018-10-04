class Dog < ApplicationRecord
  has_many_attached :images
  belongs_to :owner, :class_name => "User", optional: true
  acts_as_votable

  scope :by_likes, -> (t='hour') {
  					joins("left outer join votes on votes.votable_id = dogs.id")
  					.where("votes.votable_type = ? AND votes.created_at >= ?", "Dog", 1.send("#{t}").ago)
  					.select("dogs.*, count(votes.votable_id) as vote_count").group("dogs.id").order("vote_count DESC")
  				}

end