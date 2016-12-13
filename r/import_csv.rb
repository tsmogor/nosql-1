# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rails db:seed command
# (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts '=' * 16, 'Authors', '=' * 16

authors = [
  { first_name: 'David', last_name: 'Flanagan' },
  { first_name: 'Yukihiro', last_name: 'Matsumoto' },
  { first_name: 'Dave', last_name: 'Thomas' },
  { first_name: 'Chad', last_name: 'Fowler' },
  { first_name: 'Andy', last_name: 'Hunt' },
  { first_name: 'Sam', last_name: 'Ruby' },
  { first_name: 'David', last_name: 'Hansson' }
]

authors.each do |attr|
  puts "#{attr[:last_name]}, #{attr[:first_name]}"
  Author.find_or_create_by(last_name: attr[:last_name], first_name: attr[:first_name])
end

puts '=' * 16, 'Articles', '=' * 16

books = [
  { title: 'The Ruby Programming Language', isbn: '978-0-59651-617-8', pub_date: 'February 1, 2008' },
  { title: 'Programming Ruby 1.9', isbn: '978-1-93435-608-1', pub_date: 'April 15, 2009' },
  { title: 'Agile Web Development with Rails', isbn: '978-1-93435-654-8', pub_date: '2011-03-31' },
  { title: 'jQuery Pocket Reference', isbn: '978-1-4493-9722-7', pub_date: 'December 2010' }
]

books.each do |attr|
  puts attr[:title]
  Article.find_or_create_by(title: attr[:title], isbn: attr[:isbn], pub_date: attr[:pub_date])
end

puts '=' * 16, 'articles_authors', '=' * 16

Author.find(1).articles << Article.find([1, 4])
Author.find(2).articles << Article.find(1)
Author.find(3).articles << Article.find([2, 3])
Author.find(4).articles << Article.find(2)
Author.find(5).articles << Article.find(2)
Author.find(6).articles << Article.find(3)
Author.find(7).articles << Article.find(3)

# rails console
#
# require 'cvs'

# csv = CSV.new(open("db/a.csv"), :headers => true, :header_converters => :symbol, :converters => :all)
# csv.each { |row| puts row }

# csv = CSV.new(open("db/a.csv"), :headers => true, :header_converters => :symbol, :converters => :all)
# csv.each { |row| row.delete(0); ap row.to_hash }
# {
#       :faa => "0P2",
#      :name => "Shoestring Aviation Airfield",
#       :lat => 39.7948244,
#       :lon => -76.6471914,
#       :alt => 1000,
#        :tz => -5,
#       :dst => "U",
#     :tzone => "America/New_York"
# }

# Zlib::GzipReader.open("db/a.csv.gz") do |gz|
#   csv = CSV.new(gz, :headers => true, :header_converters => :symbol, :converters => :all)
#   csv.each do |row|
#     row.delete(0)
#     ap row
#   end
# end
