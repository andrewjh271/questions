require_relative 'question'
require_relative 'reply'
require_relative 'questions_database'
require_relative 'question_follow'
require_relative 'question_like'
require 'pry'

class User
  attr_accessor :fname, :lname

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM users
      WHERE id = ?;
    SQL
    User.new(data.first)
  end

  def self.find_by_name(fname, lname)
    data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT *
      FROM users
      WHERE
        fname = ?
        AND lname = ?;
    SQL
    User.new(data.first)
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
    data = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT AVG(likes) AS karma
      FROM (
        SELECT
          users.lname,
          questions.title,
          COUNT(question_likes.question_id) AS likes
        FROM users
        LEFT JOIN questions ON users.id = questions.user_id
        LEFT JOIN question_likes ON questions.id = question_likes.question_id
        WHERE users.id = ?
        GROUP BY questions.title
      );
    SQL
    data.first['karma']
  end

  def save
    @id ? update : create
  end

  private

  def update
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE users
      SET
        fname = ?,
        lname = ?
      WHERE id = ?;
    SQL
  end

  def create
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users(fname, lname)
      VALUES
        (?, ?);
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end
end