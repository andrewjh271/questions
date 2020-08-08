require './user.rb'
require './questions_database.rb'

describe User do
  describe '.find_by_name' do
    it 'returns User object that matches parameters' do
      expect(QuestionsDatabase.instance).to receive(
        :get_first_row).exactly(1).times.and_call_original
      user_obj = User.find_by_name('Andrew', 'Hayhurst')
      expect(user_obj).to be_a(User)
      expect(user_obj.fname).to eq('Andrew')
      expect(user_obj.lname).to eq('Hayhurst')
    end
  end

  describe '#authored_questions' do
    subject { User.find_by_id(4) }

    it 'returns Question object(s) for all authored questions' do
      expect(QuestionsDatabase.instance).to receive(:execute).exactly(3).times.and_call_original
      expect(subject.authored_questions.length).to eq(2)
      expect(subject.authored_questions[0].title).to eq('Giraffes')
    end

    it 'returns empty array if no authored questions' do
      expect(QuestionsDatabase.instance).to receive(:execute).exactly(2).times.and_call_original
      uninquisitive_user = User.find_by_id(5)
      expect(uninquisitive_user.authored_questions).to eq([])
    end
  end

  describe '#authored_replies' do
    subject { User.find_by_id(1) }

    it 'returns Reply object(s) for all authored replies' do
      expect(QuestionsDatabase.instance).to receive(:execute).exactly(3).times.and_call_original
      expect(subject.authored_replies[1].parent_reply).to eq(1)
      expect(subject.authored_replies[2].body).to eq('Pancakes')
    end
  end

  describe '#followed_questions' do
    subject { User.find_by_id(2) }

    it 'returns Question object(s) for all followed questions' do
      expect(QuestionsDatabase.instance).to receive(:execute).exactly(2).times.and_call_original
      expect(subject.followed_questions.map(&:title)).to contain_exactly(
        'Snowden', 'Giraffes'
      )
    end
  end

  describe '#liked_questions' do
    subject { User.find_by_id(6) }

    it 'returns Question object(s) for all liked questions' do
      expect(QuestionsDatabase.instance).to receive(:execute).exactly(2).times.and_call_original
      expect(subject.liked_questions.map(&:title)).to contain_exactly(
        'Breakfast', 'Giraffes', 'Yesterday'
      )
    end
  end

  describe '#average_karma' do
    it "returns average number of likes for user's questions" do
      expect(QuestionsDatabase.instance).to receive(:execute).exactly(3).times.and_call_original
      expect(QuestionsDatabase.instance).to receive(:get_first_value).exactly(3).times.and_call_original
      expect(User.find_by_id(4).average_karma).to eq(3)
      expect(User.find_by_id(3).average_karma).to eq(1)
      expect(User.find_by_id(1).average_karma).to eq(0)
    end
  end
end