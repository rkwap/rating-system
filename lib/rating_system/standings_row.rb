module RatingSystem
  class StandingsRow
    attr_accessor :rank, :user_id, :points

    def initialize(user_id, points)
      @rank = 0.0
      @user_id = user_id
      @points = points
    end
  end
end
