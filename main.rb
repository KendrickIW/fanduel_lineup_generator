require 'csv'

def find_all_by_position(ary, pos)
  ary.find_all { |x| x[2] == pos }
end

def find_all_ids_by_position(ary, pos)
  find_all_by_position(ary, pos).map { |x| x[1] }
end

fanduel = CSV.read(ARGV[0])

players = CSV.read('lineup.csv')

players = players.slice(1, players.length)

filtered =  players.combination(9).to_a.reject do |lineup|
  salary_total = lineup.reduce(0) { |sum, n| sum + n[8].to_i }
  wrs = lineup.find_all { |x| x[2] == "WR" }

  salary_total > 60000 ||
  salary_total < 58000 ||
  lineup.find_all { |x| x[2] == "K" }.length != 1 ||
  lineup.find_all { |x| x[2] == "D" }.length != 1 ||
  lineup.find_all { |x| x[2] == "TE" }.length != 1 ||
  wrs.length != 3 ||
  wrs.map { |x| x[10] }.uniq.length != 3 ||
  lineup.find_all { |x| x[2] == "RB" }.length != 2 ||
  lineup.find_all { |x| x[2] == "QB" }.length != 1

end

file = File.open("output.csv", "w")

fanduel = fanduel.slice(1, 150).map { |x| x.slice(0, 3) }

filtered.shuffle.take(fanduel.length).each_with_index do |lineup, index|
  qb = find_all_ids_by_position(lineup, "QB")
  rb = find_all_ids_by_position(lineup, "RB")
  wr = find_all_ids_by_position(lineup, "WR")
  te = find_all_ids_by_position(lineup, "TE")
  d = find_all_ids_by_position(lineup, "D")
  k = find_all_ids_by_position(lineup, "K")

  csv_string = CSV.generate("", {:force_quotes => true})  do |csv|
    csv << fanduel[index] + qb + rb + wr + te + k + d
  end

  file.write(csv_string)
end

file.close
puts filtered.length
