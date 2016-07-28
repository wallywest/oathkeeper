class User < ActiveRecord::Base
  oath_keeper :ignore => ["logins"]
end

class Company < ActiveRecord::Base
  oath_keeper
end
class Author < ActiveRecord::Base
  oath_keeper
  has_many :books
end

class Book < ActiveRecord::Base
  oath_keeper :meta => [[:author, :name]]
  belongs_to :author
end

class Pages < ActiveRecord::Base
  belongs_to :book
end

class Reviews < ActiveRecord::Base
  belongs_to :book
  belongs_to :company
end
