require "byebug"

class Election
  attr_reader :candidates, :votes, :winners

    def self.fromCSV(filename)
        votes = []
        candidates = []
        File.foreach(filename).with_index do |line, line_num|
            if line_num == 0
                candidates = line.split(',').map(&:strip)
            else
                ranks = line.split(',')
                  .map { |raw_rank| raw_rank.strip.to_i }
                hash = candidates.zip(ranks).to_h
                hash.reject! { |_, rank| rank == 0 } # remove votes where no preference (assuming 0 is from empty column)
                votes.push(Vote.new(hash))
            end
        end

        return Election.new(candidates, votes)
    end

    def initialize(candidates, votes)
      @candidates = candidates
      @votes = votes
      compute_results()
    end

    private

    def compute_results(iteration = 0)
        if iteration > candidates.length
          raise "Help, I'm stuck in an infinite loop!"
        end

        current_rankings = Hash.new { |hash, key| hash[key] = 0 }
        total_votes = 0.0

        votes.each do |vote|
          if vote.preferred_candidate() != nil
            current_rankings[vote.preferred_candidate()] += 1
            total_votes += 1
          end
        end

        puts "Round #{iteration}: \n"
        current_rankings.sort_by { |k,v| -v }.each do |candidate, votes|
          puts "\t#{candidate}: #{votes}\n"
        end
          
        winners = current_rankings.select { |candidate, votes| votes > total_votes / 2.0 }
        if winners.length > 0
          @winners = winners.keys
        else
          # what if tie? - this returns only one value
          # could break ties with second choice, but would it affect ultimate outcome?

          loser = current_rankings.min_by { |candidate, votes| votes }[0]
          votes.each do |vote|
            vote.remove_candidate(loser)
          end
          compute_results(iteration + 1)
        end
    end
end


class Vote
  attr_reader :rankings

    def initialize(rankings)
      # rankings is a Map<string,int> of candidate name to ranking
      @rankings = rankings
    end

    def remove_candidate(candidate)
        @rankings.delete(candidate)
    end

    def preferred_candidate()
        @rankings.min_by { |candidate, rank| rank }[0]
    end
end