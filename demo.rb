require_relative 'active_record_lite'

class Cat < SQLObject
  belongs_to :human,
    foreign_key: :owner_id

  has_one_through :home,
    :human,
    :house

  finalize!
end

class Human <SQLObject
  self.table_name = 'humans'

  has_many :cats,
    foreign_key: :owner_id

  belongs_to :house

  finalize!
end

class House < SQLObject
  has_many :humans

  finalize!
end


if __FILE__ == $0
  cat = Cat.find(1)
  human = cat.human
  house = cat.home

  puts "the cat, Breakfast"
  puts " => <Cat #{cat.attributes}>"
  puts "belongs to the human, Devon"
  puts " => <Human #{human.attributes}>"
  puts "and has one house, "
  puts " => <House #{house.attributes}>"
  puts "through Devon."
end
