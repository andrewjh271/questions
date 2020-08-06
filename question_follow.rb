require_relative 'user'

class QuestionFollow
  def self.followers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.id,
        users.fname,
        users.lname
      FROM users
      INNER JOIN question_follows ON users.id = question_follows.user_id
      WHERE question_follows.question_id = ?;
    SQL
    data.map { |datum| User.new(datum) }
  end

  def self.followed_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.id,
        questions.title,
        questions.body,
        questions.user_id
      FROM questions
      INNER JOIN question_follows ON questions.id = question_follows.question_id
      WHERE question_follows.user_id = ?;
    SQL
    data.map { |datum| Question.new(datum) }
  end

  def self.most_followed_questions(n = 1)
    data = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
        questions.id,
        questions.title,
        questions.body,
        questions.user_id
      FROM questions
      INNER JOIN question_follows ON questions.id = question_follows.question_id
      GROUP BY questions.id
      ORDER BY COUNT(*) DESC;
    SQL
    Question.new(data[n - 1])
  end
end