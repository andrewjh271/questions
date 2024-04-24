require './table_object.rb'
require './user.rb'
require './question.rb'
require './reply.rb'
require './questions_database.rb'

describe TableObject do
  describe '.find_by_id' do
    it 'returns object of self type with given id' do
      user = User.find_by_id(2)
      expect(user).to be_a(User)
      expect(user.fname).to eq('Beth')
    end

    it 'works for Question class' do
      question = Question.find_by_id(2)
      expect(question).to be_a(Question)
      expect(question.title).to eq('Breakfast')
    end

    it 'works for Reply class' do
      reply = Reply.find_by_id(2)
      expect(reply).to be_a(Reply)
      expect(reply.body).to eq('Sorry, I meant Application Programming Interface')
    end
  end

  describe '.where' do
    it 'returns object of self type with given constraints' do
      expect(User.where(fname: 'Beth').map(&:fname)).to contain_exactly('Beth')
    end

    it 'works with wildcard character %' do
      expect(User.where(fname: 'A%').map(&:fname)).to contain_exactly(
        'Andrew', 'Andy'
      )
    end

    it 'works with wildcard character _' do
      expect(User.where(fname: '____').map(&:fname)).to contain_exactly(
        'Beth', 'Andy'
      )
    end

    it 'works for Question class' do
      expect(Question.where(body: '%what%').map(&:title)).to contain_exactly(
        'API??', 'Breakfast'
      )
    end

    it 'works for Reply class' do
      expect(Reply.where(user_id: 5).map(&:body)).to contain_exactly(
        'Yesterday is sometimes there.'
      )
    end
  end

  describe '#save' do
    before(:each) do
      @test = QuestionsDatabase.instance
      @test.transaction
    end

    after(:each) { @test.rollback }

    it 'updates the database for an existing user' do
      user = User.where(fname: 'Beth').first
      user.fname = 'Bethany'
      user.save
      expect(User.find_by_id(2).fname).to eq('Bethany')
    end

    it 'updates the database for a new user' do
      user = User.new('fname' => 'Kenneth', 'lname' => 'Liao')
      user.save
      expect(User.find_by_id(7).lname).to eq('Liao')
    end

    it 'updates the database for an existing question' do
      question = Question.find_by_id(3)
      question.body = 'This is a bad question.'
      question.save
      expect(Question.find_by_id(3).body).to eq('This is a bad question.')
    end

    it 'updates the database for a new question' do
      question = Question.new(
        'title' => 'Tonight',
        'body' => 'Will tonight be like any other night?',
        'user_id' => 1
      )
      question.save
      expect(Question.where(title: 'tonight').first.body).to eq(
        'Will tonight be like any other night?')
    end

    it 'updates the database for an existing reply' do
      reply = Reply.find_by_id(3)
      reply.body = 'This is a bad reply.'
      reply.save
      expect(Reply.find_by_id(3).body).to eq('This is a bad reply.')
    end

    it 'updates the database for a new reply' do
      reply = Reply.new(
        'question_id' => 3,
        'parent_reply' => 4,
        'user_id' => 1,
        'body' => 'Unrelated, but zebras are cool.'
      )
      reply.save
      expect(Reply.where(question_id: 3, parent_reply: 4, user_id: 1).first.body).to eq(
        'Unrelated, but zebras are cool.')
    end
  end

  describe 'destroy' do
    before(:each) do
      @test = QuestionsDatabase.instance
      @test.transaction
    end

    after(:each) { @test.rollback }

    it 'can\'t delete rows with foreign key dependencies' do
      user = User.new('fname' => 'Kenneth', 'lname' => 'Liao')
      user.save
      question = Question.new(
        'title' => 'Tonight',
        'body' => 'Will tonight be like any other night?',
        'user_id' => 7
      )
      question.save
      reply = Reply.new(
        'question_id' => 6,
        'user_id' => 7,
        'body' => 'Unrelated, but zebras are cool.'
      )
      reply.save

      expect { user.destroy }.to raise_error(SQLite3::ConstraintException)
      expect { question.destroy }.to raise_error(SQLite3::ConstraintException)
    end

    it 'deletes users' do
      user = User.new('fname' => 'Kenneth', 'lname' => 'Liao')
      user.save
      expect(User.find_by_id(7)).to be_a(User)
      user.destroy
      expect(User.where(fname: 'Kenneth')).to eq([])
    end

    it 'deletes questions' do
      question = Question.new(
        'title' => 'Tonight',
        'body' => 'Will tonight be like any other night?',
        'user_id' => 4
      )
      question.save
      expect(Question.find_by_id(6)).to be_a(Question)
      question.destroy
      expect(Question.find_by_id(6)).to be_nil
    end

    it 'deletes replies' do
      reply = Reply.new(
        'question_id' => 3,
        'user_id' => 4,
        'body' => 'Unrelated, but zebras are cool.'
      )
      reply.save
      expect(Reply.where(body: 'Unr%zebras%').first).to be_a(Reply)
      reply.destroy
      expect(Reply.where(body: 'Unr%zebras%').first).to be_nil
    end
  end
end