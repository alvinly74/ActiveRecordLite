require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns

    columns = DBConnection.execute2(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
    SQL

    columns = columns.first.map{|el| el.to_sym}


  end

  def self.finalize!
    columns.each do |column|
      define_method("#{column}=") do |value|
        attributes[column] = value
        #instance_variable_set("@#{column}", value)
      end
      define_method("#{column}") do
        attributes[column]
        #instance_variable_get("@#{column}")
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    hash_ray = DBConnection.execute(<<-SQL)
    SELECT
      #{self.table_name}.*
    FROM
      #{self.table_name}
    SQL

    self.parse_all(hash_ray)

  end

  def self.parse_all(results)
    results.map do |hash|
      self.new(hash)
    end
  end

  def self.find(id)
    self.all.find {|obj| obj.id == id }
  end

  def initialize(params = {})
    columns = self.class.columns
    params.each do |key, val|
      key_sym = key.to_sym
      raise "unknown attribute '#{key}'" if !columns.include?(key_sym)
      self.send("#{key_sym}=", val)
    end
  end

  def attributes
    @attributes ||= {}
    @attributes
  end

  def attribute_values
    @attributes.values
    self.class.columns.map {|column| send(column)}
  end

  def insert
    col_names = self.class.columns
    question_marks = ["?"] * col_names.count
    DBConnection.execute(<<-SQL, *attribute_values)
    INSERT INTO
      #{self.class.table_name} (#{col_names.join(", ")})
    VALUES
      (#{question_marks.join(", ")})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.columns.map{|column| "#{column} = ?"}
    set_line = set_line.join(",")
    DBConnection.execute(<<-SQL, *(attribute_values << self.id))
    UPDATE
      #{self.class.table_name}
    SET
      #{set_line}
    WHERE
      id = ?
    SQL
  end

  def save
    self.id.nil? ? insert : update
  end
end
