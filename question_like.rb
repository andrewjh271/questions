require_relative 'user'
require_relative 'question'

class QuestionLike
  def self.likers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.id,
        users.fname,
        users.lname
      FROM users
      INNER JOIN question_likes ON users.id = question_likes.user_id
      WHERE question_likes.question_id = ?;
    SQL
    data.map { |datum| User.new(datum) }
  end

  def self.num_likes_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT COUNT(*) AS num
      FROM question_likes
      WHERE question_likes.question_id = ?;
    SQL
    data.first['num']
  end

  def self.liked_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.id,
        questions.title,
        questions.body,
        questions.user_id
      FROM questions
      INNER JOIN question_likes ON questions.id = question_likes.question_id
      WHERE question_likes.user_id = ?;
    SQL
    data.map { |datum| Question.new(datum) }
  end

  def self.most_liked_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        questions.id,
        questions.title,
        questions.body,
        questions.user_id
      FROM questions
      INNER JOIN question_likes ON questions.id = question_likes.question_id
      GROUP BY questions.id
      ORDER BY COUNT(*) DESC;
    SQL
    data.first(n).map { |datum| Question.new(datum) }
  end
end