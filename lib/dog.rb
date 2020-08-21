class Dog 
    attr_accessor :name, :breed 
    attr_reader :id 
    def initialize(name:, breed:, id: nil)
        @name = name 
        @breed = breed 
        @id = id 
    end 

    def self.create_table
        sql = <<-SQL 
        CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
        SQL
        DB[:conn].execute(sql)
    end 

    def self.drop_table 
        sql = <<-SQL 
        DROP TABLE dogs 
        SQL
        DB[:conn].execute(sql)
    end 

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES(?,?)
        SQL
        a = DB[:conn].execute(sql,self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end 
    
    def self.new_from_db(row)
        nono = Dog.new(name: row[1], breed: row[2], id: row[0])
        nono
    end 

    def self.create(ats)
        nee = Dog.new(name: ats[:name], breed: ats[:breed])
        nee.save 
    end 

    def self.find_by_id(i)
        sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
        SQL
        self.new_from_db(DB[:conn].execute(sql, i)[0])
    end 

    def self.find_or_create_by(dog)
        sql = <<-SQL 
        SELECT * FROM dogs WHERE name = ? AND breed = ? 
        SQL
        a = DB[:conn].execute(sql, dog[:name], dog[:breed])
        if a.empty?
            self.create(dog)
        else 
            self.new_from_db(a[0])
        end 
    end 

    def self.find_by_name(name)
        sql = <<-SQL 
        SELECT * FROM dogs WHERE name = ?
        SQL
        self.new_from_db(DB[:conn].execute(sql, name)[0])
    end 

    def update
        sql = <<-SQL
        UPDATE dogs 
        SET name = ?, breed = ? WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end 
end 