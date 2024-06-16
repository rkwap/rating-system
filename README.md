# Rating System
A simple implementation of a modified Elo-based Rating System for Multiplayer Games and tournaments, which is currently used by Codeforces. This implementation is based on: [MikeMirzayanov's Submission](https://codeforces.com/contest/1/submission/13861109).

## Features

- Calculates new ratings for players based on their performance in a tournament.
- Modified Elo rating system adapted for multiplayer games.

# Installation

Add this line to your application's Gemfile:

```ruby
gem 'rating_system'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install rating_system
```

## Usage

In a tournament, player A, with a rating of `1500`, plays against opponents with the following ratings: `1500`, `1658`, `1256`, `1353`.

Let's assume the rankings of players after the tournament ends are:

- A -> 1
- B -> 2
- C -> 3
- D -> 4
- E -> 5

So, to calculate the new ratings based on the lastest ranks, we would use this gem like this:

```ruby
contestants = [
  {
    position: 1,
    user_id: 'A',
    previous_rating: 1500
  },
  {
    position: 2,
    user_id: 'B',
    previous_rating: 1500
  },
  {
    position: 3,
    user_id: 'C',
    previous_rating: 1658
  },
  {
    position: 4,
    user_id: 'D',
    previous_rating: 1256
  },
  {
    position: 5,
    user_id: 'E',
    previous_rating: 1353
  }
]

RatingSystem::RatingCalculator.get_new_ratings(contestants) # Gets new ratings array

OUTPUT:

[
  {:position=>1, :user_id=>"A", :previous_rating=>1500, :delta=>125, :new_rating=>1625},
  {:position=>2, :user_id=>"B", :previous_rating=>1500, :delta=>31, :new_rating=>1531},
  {:position=>3, :user_id=>"C", :previous_rating=>1658, :delta=>-72, :new_rating=>1586},
  {:position=>4, :user_id=>"D", :previous_rating=>1256, :delta=>0, :new_rating=>1256},
  {:position=>5, :user_id=>"E", :previous_rating=>1353, :delta=>-93, :new_rating=>1260}
]
```

## Benchmarks

Benchmarks for the rating system are coming soon. Stay tuned for performance metrics and comparisons!


## License

The code is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
