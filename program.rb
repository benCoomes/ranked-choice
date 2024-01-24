require './election'

e = Election.fromCSV('votes.csv')
puts e.winners