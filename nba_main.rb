require 'csv'

def find_all_by_position(ary, pos)
  ary.find_all { |x| x[2] == pos }
end

def find_all_ids_by_position(ary, pos)
  find_all_by_position(ary, pos).map { |x| x[1] }
end

fanduel = CSV.read(ARGV[0])

players = CSV.read('lineup.csv')
#
# def get_players(entries)
#   entries[7..-1].map { |x| x[13..-1] }.reject do |player|
#     player[12] == "O" ||
#     player[6].to_f < 12
#   end
# end
#
# players = get_players(fanduel)
# puts players.length

# all_pg = players.select { |x| x[2] == "PG" }
#
# all_sg = players.select { |x| x[2] == "SG" }
# puts all_sg.combination(2).to_a.length
# all_sf = players.select { |x| x[2] == "SF" }
# puts all_sf.combination(2).to_a.length
# all_pf = players.select { |x| x[2] == "PF" }
# puts all_pf.combination(2).to_a.length
# all_c = players.select { |x| x[2] == "C" }
# puts all_c.length

# all_pg.combination(2).to_a.each do |pg|
#   all_sg.combination(2).to_a.each do |sg|
#     all_sf.combination(2).to_a.each do |sf|
#       all_pf.combination(2).to_a.each do |pf|
#         all_c.each do |c|
#           puts pg, sg, sf, pf, c, "---"
#         end
#       end
#     end
#   end
# end

filtered =  players.combination(9).to_a.reject do |lineup|
  salary_total = lineup.reduce(0) { |sum, n| sum + n[8].to_i }

  salary_total > 60000 ||
  salary_total < 58000 ||
  lineup.reduce([]) { |ary, n| ary.push(n[10]) }.uniq.length < 7 ||
  lineup.find_all { |x| x[2] == "PG" }.length != 2 ||
  lineup.find_all { |x| x[2] == "SG" }.length != 2 ||
  lineup.find_all { |x| x[2] == "SF" }.length != 2 ||
  lineup.find_all { |x| x[2] == "PF" }.length != 2 ||
  lineup.find_all { |x| x[2] == "C" }.length != 1

end

puts filtered.length


file = File.open("output.csv", "w")

csv_string = CSV.generate("", {:force_quotes => true})  do |csv|
  csv << fanduel[0]
end

file.write(csv_string)

fanduel = fanduel.slice(1, 141).map { |x| x.slice(0, 3) }

filtered.shuffle.take(fanduel.length).each_with_index do |lineup, index|
  pg = find_all_ids_by_position(lineup, "PG")
  sg = find_all_ids_by_position(lineup, "SG")
  sf = find_all_ids_by_position(lineup, "SF")
  pf = find_all_ids_by_position(lineup, "PF")
  c = find_all_ids_by_position(lineup, "C")


  csv_string = CSV.generate("", {:force_quotes => true})  do |csv|
    csv << fanduel[index] + pg + sg + sf + pf + c
  end

  file.write(csv_string)
end

file.close
