class Dog
    attr_accessor :id, :name, :breed

    def initialize(id: nil, name: name, breed: breed)
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
            );
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE dogs;
        SQL
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?,?);
            SQL
            DB[:conn].execute(sql, name, breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
        end
        self
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.new_from_db(array)
        id = array[0]
        name = array[1]
        breed = array[2]
        Dog.new(id: id, name: name, breed: breed)
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE id  = ?
            LIMIT 1;
        SQL
        DB[:conn].execute(sql, id).map do |array|
            self.new_from_db(array)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ? AND breed = ?;
        SQL
        dog = DB[:conn].execute(sql, name, breed)

        if !dog.empty?
            dog_values = dog[0]
            dog = Dog.new(id: dog_values[0], name: dog_values[1], breed: dog_values[2])
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs
            WHERE name = ?
            LIMIT 1;
        SQL
        DB[:conn].execute(sql, name).map do |array|
            self.new_from_db(array)   
        end.first
    end

    def update
        sql = <<-SQL
            UPDATE dogs
            SET name = ?
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.id)
    end
end