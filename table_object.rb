require_relative 'questions_database'
require 'active_support/inflector'
require 'facets/string/squish'
require 'pry'

class TableObject
  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM #{to_s.tableize}
      WHERE id = ?;
    SQL
    new(data.first)
  end

  def self.where(options)
    # Uses LIKE instead of = for added functionality while
    # still sanitizing input
    query = <<-SQL.squish
      SELECT *
      FROM #{to_s.tableize}
      WHERE #{where_clause(options)};
    SQL
    binding.pry

    data = QuestionsDatabase.instance.execute(query, options.values)

    data.map { |datum| new(datum) }
  end

  def self.find_by(options)
    # alias
    where(options)
  end

  def save
    @id ? update : create
  end

  def self.where_clause(options)
    options.each_with_object([]) do |(column, _value), clause|
      clause << "#{column} LIKE ?"
    end.join(' AND ')
  end

  private

  def update
    # squish removes newline characters (included in Rails ActiveSupport)
    # but used Facets gem instead b/c it is lighter
    query = <<-SQL.squish
      UPDATE #{self.class.to_s.tableize}
      SET #{set_clause}
      WHERE id = ?;
    SQL
    # rotate data set to make @id last
    QuestionsDatabase.instance.execute(query, instance_variables_get.rotate)
  end

  def create
    values = instance_variables_get
    query = <<-SQL.squish
      INSERT INTO
        #{self.class.to_s.tableize}(#{insert_clause})
      VALUES
        (#{placeholder_clause(values.length)});
    SQL
    QuestionsDatabase.instance.execute(query, values)
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def insert_clause
    instance_variables.filter_map do |var|
      next if var == :@id

      var.to_s[1..-1]
    end.join(', ')
  end

  def placeholder_clause(n)
    placeholders = []
    n.times { placeholders << '?' }
    placeholders.join(', ')
  end

  def set_clause
    instance_variables.filter_map do |var|
      next if var == :@id

      column = var.to_s[1..-1]
      "#{column} = ?"
    end.join(', ')
  end

  def instance_variables_get
    values = instance_variables.map { |var| instance_variable_get(var) }
    values.shift if values.first.nil? && instance_variables.first == :@id
    values
  end
end