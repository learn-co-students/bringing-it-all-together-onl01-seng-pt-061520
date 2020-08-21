class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: id, name: name, breed: breed)
        @id = nil
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
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?,?);
        SQL
        DB[:conn].execute(sql, name, breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
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
        Dog.new(name: name, breed: breed)
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
end