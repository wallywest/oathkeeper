require 'active_record'
require 'logger'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')
ActiveRecord::Base.logger = Logger.new(SPEC_ROOT.join('debug.log'))
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :users, :force => true do |t|
    t.column :name, :string
    t.column :username, :string
    t.column :password, :string
    t.column :activated, :boolean
    t.column :suspended_at, :datetime
    t.column :logins, :integer, :default => 0
    t.column :created_at, :datetime
    t.column :updated_at, :datetime
  end

  create_table :companies, :force => true do |t|
    t.column :name, :string
    t.column :owner_id, :integer
  end

  create_table :authors, :force => true do |t|
    t.column :name, :string
  end

  create_table :books, :force => true do |t|
    t.column :author_id, :integer
    t.column :title, :string
  end

  create_table :pages, :force => true do |t|
    t.column :book_id, :integer
    t.column :number, :integer
    t.column :words, :integer
  end

  create_table :reviews, :force => true do |t|
    t.column :company_id, :integer
    t.column :book_id, :integer
    t.column :score, :integer
    t.column :review, :text
  end
end
