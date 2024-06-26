require_relative 'table_object'
require_relative 'question'
require_relative 'reply'
require_relative 'question_follow'
require_relative 'question_like'

class User < TableObject
  attr_accessor :fname, :lname

  def self.find_by_name(fname, lname)
    data = QuestionsDatabase.instance.get_first_row(<<-SQL, fname, lname)
      SELECT *
      FROM users
      WHERE
        fname = ?
        AND lname = ?;
    SQL
    User.new(data)
  end

  def initialize(data)
    @id = data['id']
    @fname = data['fname']
    @lname = data['lname']
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    QuestionsDatabase.instance.get_first_value(<<-SQL, @id)
      SELECT AVG(likes) AS karma
      FROM (
        SELECT COUNT(question_likes.question_id) AS likes
        FROM users
        LEFT JOIN questions ON users.id = questions.user_id
        LEFT JOIN question_likes ON questions.id = question_likes.question_id
        WHERE users.id = ?
        GROUP BY questions.id
      );
    SQL
  end
end