require_relative 'table_object'
require_relative 'user'
require_relative 'question'

class Reply < TableObject
  attr_accessor :question_id, :parent_reply, :user_id, :body

  def self.find_by_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT *
      FROM replies
      WHERE user_id = ?;
    SQL
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT *
      FROM replies
      WHERE question_id = ?;
    SQL
    data.map { |datum| Reply.new(datum) }
  end

  def initialize(data)
    @id = data['id']
    @question_id = data['question_id']
    @parent_reply = data['parent_reply']
    @user_id = data['user_id']
    @body = data['body']
  end

  def author
    data = QuestionsDatabase.instance.execute(<<-SQL, @user_id)
      SELECT *
      FROM users
      WHERE id = ?;
    SQL
    User.new(data.first)
  end

  def question
    data = QuestionsDatabase.instance.execute(<<-SQL, @question_id)
      SELECT *
      FROM questions
      WHERE id = ?;
    SQL
    Question.new(data.first)
  end

  def parent_reply_obj
    data = QuestionsDatabase.instance.execute(<<-SQL, @parent_reply).first
      SELECT *
      FROM replies
      WHERE id = ?;
    SQL
    data ? Reply.new(data) : nil
  end

  def child_replies
    data = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT *
      FROM replies
      WHERE parent_reply = ?;
    SQL
    data.map { |datum| Reply.new(datum) }
  end
end