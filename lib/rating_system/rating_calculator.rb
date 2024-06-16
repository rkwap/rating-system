module RatingSystem
  class RatingCalculator
    class << self
      def get_new_ratings(contestants)
        # previous_ratings
        previous_ratings = {}
        contestants.each { |c| previous_ratings[c[:user_id]] = c[:previous_rating] }

        # standings_rows
        standings_rows = []
        total = 1_000_000

        contestants.each do |c|
          points = total - c[:position]
          if points.negative?
            raise StandardError, "Position of contestant is higher than length:\n        '  #{c[:position]}', '#{c[:user_id]}"
          end

          standings_rows << RatingSystem::StandingsRow.new(c[:user_id], points)
        end

        rating_calculator = RatingSystem::RatingCalculator.new
        rating_changes = rating_calculator.calculate_rating_changes(previous_ratings, standings_rows)

        contestants.each do |c|
          c[:delta] = rating_changes[c[:user_id]]
          c[:new_rating] = c[:previous_rating].to_i + c[:delta].to_i
        end

        contestants
      end

      def run_benchmarks(contestant_count = 100)
        start = Time.now
        contestants = []
        (1..contestant_count).each do |i|
          h = {
            position: i,
            user_id: i,
            previous_rating: 1500
          }
          contestants << h
        end

        RatingSystem::RatingCalculator.get_new_ratings(contestants)
        finish = Time.now

        diff = finish - start
        p "total execution time: #{diff} seconds"
      end
    end

    def calculate_rating_changes(previous_ratings, standings_rows)
      contestants = []

      standings_rows.each do |standings_row|
        rank = standings_row.rank
        user_id = standings_row.user_id
        contestants << RatingSystem::Contestant.new(user_id, rank, standings_row.points, previous_ratings[user_id])
      end

      contestants = process(contestants)

      rating_changes = {}
      contestants.each { |contestant| rating_changes[contestant.user_id] = contestant.delta }

      rating_changes
    end

    def process(contestants)
      return if contestants.length.zero?

      contestants = reassign_ranks(contestants)

      contestants.each do |contestant|
        contestant.seed = get_seed(contestants, contestant, contestant.rating)
        # calculating geometric mean of rank and seed
        mid_rank = Math.sqrt(contestant.rank * contestant.seed)
        contestant.need_rating = get_rating_to_rank(contestants, contestant, mid_rank)
        contestant.delta = ((contestant.need_rating - contestant.rating) / 2.00).truncate
      end

      contestants = adjust_inflation(contestants)
      validate_deltas(contestants)
      contestants
    end

    def adjust_inflation(contestants)
      contestants = sort_by_rating_desc(contestants)

      # Total sum should not be more than zero.
      sum = 0
      contestants.each { |c| sum += c.delta }

      inc = (-sum / contestants.length - 1)
      contestants.each { |c| c.delta += inc }

      # Sum of top-4*sqrt should be adjusted to zero.
      sum = 0
      zero_sum_count = [4 * Math.sqrt(contestants.length).round, contestants.length].min.truncate

      (0..zero_sum_count - 1).each { |i| sum += contestants[i].delta }

      inc = [[(-sum / zero_sum_count).truncate, -10].max, 0].min
      contestants.each { |c| c.delta += inc }
      contestants
    end

    def reassign_ranks(contestants)
      contestants = sort_by_points_desc(contestants)

      contestants.each do |contestant|
        contestant.rank = 0
        contestant.delta = 0
      end

      first = 0
      points = contestants.first.points

      (1..contestants.length - 1).each do |i|
        next if contestants[i].points >= points

        (first..i).each { |j| contestants[j].rank = i }
        first = i
        points = contestants[i].points
      end

      rank = contestants.length
      (first..contestants.length - 1).each { |j| contestants[j].rank = rank }

      contestants
    end

    def sort_by_points_desc(contestants)
      contestants.sort! { |a, b| b.points <=> a.points }
    end

    def get_elo_win_probability(ra, rb)
      1.0 / (1 + (10**((rb - ra) / 400.0)))
    end

    def get_rating_to_rank(contestants, contestant, rank)
      left = 1
      right = 8000

      while (right - left) > 1
        mid_rating = ((left + right) / 2.00).truncate

        if get_seed(contestants, contestant, mid_rating) < rank
          right = mid_rating
        else
          left = mid_rating
        end
      end

      left
    end

    # get seed for a contestant if the constant has a particular rating
    def get_seed(contestants, contestant, rating)
      result = 1
      contestants.each do |other|
        result += get_elo_win_probability(other.rating, rating) if other.user_id != contestant.user_id
      end
      result
    end

    def sort_by_rating_desc(contestants)
      contestants.sort! { |a, b| b.rating <=> a.rating }
    end

    def validate_deltas(contestants)
      contestants = sort_by_points_desc(contestants)
      (0..contestants.length - 1).each do |i|
        (i + 1..contestants.length - 1).each do |j|
          # Contestant i has better place than j
          if contestants[i].rating > contestants[j].rating && (contestants[i].rating + contestants[i].delta < contestants[j].rating + contestants[j].delta)
            raise StandardError,
                  "First rating invariant failed #{contestants[i].user_id} vs. #{contestants[j].user_id.user_id}"
          end

          if contestants[i].rating < contestants[j].rating && (contestants[i].delta < contestants[j].delta)
            raise StandardError,
                  "Second rating invariant failed #{contestants[i].user_id} vs. #{contestants[j].user_id}"
          end
        end
      end
    end
  end
end
