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

  salary_total > 60000 ||
  salary_total < 58000 ||
  lineup.find_all { |x| x[2] == "PG" }.length != 2 ||
  lineup.find_all { |x| x[2] == "SG" }.length != 2 ||
  lineup.find_all { |x| x[2] == "SF" }.length != 2 ||
  lineup.find_all { |x| x[2] == "PF" }.length != 2 ||
  lineup.find_all { |x| x[2] == "C" }.length != 1

end

file = File.open("output.csv", "w")

fanduel = fanduel.slice(1, 150).map { |x| x.slice(0, 3) }

filtered.shuffle.take(fanduel.length).each_with_index do |lineup, index|
  qb = find_all_ids_by_position(lineup, "PG")
  rb = find_all_ids_by_position(lineup, "SG")
  wr = find_all_ids_by_position(lineup, "SF")
  te = find_all_ids_by_position(lineup, "PF")
  d = find_all_ids_by_position(lineup, "C")


  csv_string = CSV.generate("", {:force_quotes => true})  do |csv|
    csv << fanduel[index] + qb + rb + wr + te + d
  end

  file.write(csv_string)
end

file.close
puts filtered.length
