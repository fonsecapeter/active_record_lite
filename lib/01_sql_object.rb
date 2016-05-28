require_relative 'monkeypatches/tablisms'
require_relative 'db_connection'
# require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  attr_reader :id

  def self.columns
    @columns ||
      @columns = DBConnection
                  .execute2("SELECT * FROM #{table_name}")
                  .first.map { |col| col.to_sym }
  end

  def self.finalize!
    self.columns.each do |column|
      # getter
      define_method(column) do
        attributes[column]
      end

      # setter
      define_method("#{column}=") do |value|
        attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.tablize
  end

  def self.all
    data = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    parse_all(data)
  end

  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
  end

  def self.find(id)
    data = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL

    parse_all(data).first
  end

  def initialize(params = {})
    params.each do |param, val|
      raise "unknown attribute \'#{param}\'" unless respond_to?(param)
      self.send("#{param}=", val)
    end
  end

  def attributes
    @attributes || @attributes = {}
  end

  def attribute_values
    @attributes.values
  end

  def insert
    raise "#{self} already in database" unless self.id.nil?

    # not including id, ex => "fnam, lname, house_id"
    col_names = self
                  .class
                  .columns
                  .map{ |col| col.to_s }[1..-1]
                  .join(', ')

    # one "?" for each col_name, ex => "?, ?, ?"
    question_marks = col_names
                      .split(', ')
                      .map{ '?' }
                      .join(', ')

    # actual values to match each "?", ex => "'Bert', 'Mackelin', 2"
    values = attribute_values

    DBConnection.execute(<<-SQL, *values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    raise "#{self} not in database" if self.id.nil?

    # not including id, one "col = ?" line per col, ex:
    #   => "fname = ?, lname = ?, house_id = ?"
    cols = self
            .class
            .columns[1..-1]
            .map { |col| "#{col} = ?"}
            .join(", ")

    # actual values to match each statement above, ex:
    #   => "'Bert', 'Mackelin', 2"
    vals = attribute_values[1..-1]

    DBConnection.execute(<<-SQL, vals, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{cols}
      WHERE
        id = ?
    SQL
  end

  def save
    self.id.nil? ? insert : update
  end

end
