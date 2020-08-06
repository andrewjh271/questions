# require_relative 'question'
# require_relative 'reply'
require_relative 'questions_database'
# require_relative 'question_follow'
# require_relative 'question_like'
require 'active_support/inflector'
require 'pry'

class TableObject
  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM #{self.to_s.tableize}
      WHERE id = ?;
    SQL
    self.new(data.first)
  end
end