module RatingSystem
  class Contestant
    attr_accessor :user_id, :rank, :points, :rating, :delta, :seed, :need_rating

    def initialize(user_id, rank, points, rating)
      @user_id = user_id
      @rank = rank
      @points = points
      @rating = rating
    end
  end
end
