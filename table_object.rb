# require_relative 'question'
# require_relative 'reply'
require_relative 'questions_database'
# require_relative 'question_follow'
# require_relative 'question_like'
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

  def save
    @id ? update : create
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
    binding.pry
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
    binding.pry
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
    instance_variables.filter_map { |var| instance_variable_get(var) }
  end
end