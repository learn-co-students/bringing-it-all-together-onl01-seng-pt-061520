class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(array)
    Dog.new(array[0], array[1], array[2])
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      # why doesn't @id or self.id work here?
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    end
    # binding.pry
    self

  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
  end

  def self.new_from_db(array)
    Dog.new(id: array[0], name: array[1], breed: array[2])
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL
    self.new_from_db(DB[:conn].execute(sql, id)[0])
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
      if !dog.empty?
        dog = dog[0] #remove outer array
        dog = Dog.new(id: dog[0], name: dog[1], breed: dog[2])
      else
        dog = self.create(name: name, breed: breed)
      end
    dog
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    Dog.new(id: result[0], name: result[1], breed: result[3])
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
