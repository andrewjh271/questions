require './question.rb'

describe Question do
  describe '.find_by_author_id' do
    it 'returns User object for author' do
      expect(Question.find_by_author_id(4).map(&:title)).to contain_exactly(
        'Giraffes', 'Yesterday'
      )
    end
  end

  describe '.most_followed' do
    it 'returns n most followed questions' do
      expect(Question.most_followed(2).map(&:title)).to contain_exactly(
        'Giraffes', 'Snowden'
      )
    end
  end

  describe '.most_liked' do
    it 'returns n most liked questions' do
      expect(Question.most_liked(3).map(&:title)).to contain_exactly(
        'Giraffes', 'Yesterday', 'Breakfast'
      )
    end
  end

  describe '#author' do
    it 'returns User object for author' do
      expect(Question.find_by_id(2).author.fname).to eq('Beth')
    end
  end

  describe '#replies' do
    it 'returns Reply object(s) for all replies' do
      expect(Question.find_by_id(3).replies.map(&:body)).to contain_exactly(
        'Giraffes will always be tall',
        "Thanks for your input, but that doesn't really answer my question."
      )
    end
  end

  describe '#followers' do
    it 'returns User object(s) for all followers' do
      expect(Question.find_by_id(5).followers.map(&:fname)).to contain_exactly(
        'Andrew', 'Beth', 'Nicole'
      )
    end
  end

  describe '#likers' do
    it 'returns User object(s) for all likers' do
      expect(Question.find_by_id(3).likers.map(&:fname)).to contain_exactly(
        'Andrew', 'Tommy', 'Nicole', 'Diana'
      )
    end
  end

  describe '#num_likes' do
    it 'returns the number of likes' do
      expect(Question.find_by_id(3).num_likes).to eq(4)
    end

    it 'returns the number of likes' do
      expect(Question.find_by_id(2).num_likes).to eq(2)
    end

    it 'returns the number of likes' do
      expect(Question.find_by_id(1).num_likes).to eq(0)
    end
  end
end