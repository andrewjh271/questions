require './reply.rb'

describe Reply do
  describe '.find_by_user_id' do
    it "returns Reply object(s) for given user's replies" do
      expect(Reply.find_by_user_id(1).map(&:question_id)).to contain_exactly(1, 1, 2)
    end
  end

  describe '.find_by_question_id' do
    it 'returns Reply object(s) for a given question' do
      expect(Reply.find_by_question_id(3).map(&:user_id)).to contain_exactly(6, 4)
    end
  end

  describe '#author' do
    it 'returns User object for author' do
      expect(Reply.find_by_id(6).author.fname).to eq('Andy')
    end
  end

  describe '#question' do
    it 'returns Question object for question' do
      expect(Reply.find_by_id(6).question.title).to eq('Yesterday')
    end
  end

  describe '#parent_reply_obj' do
    it 'returns Reply object for parent reply' do
      expect(Reply.find_by_id(5).parent_reply_obj.body).to eq(
        'Giraffes will always be tall'
      )
    end
  end

  describe '#child_replies' do
    it 'returns Reply object(s) for child replies' do
      expect(Reply.find_by_id(1).child_replies.map(&:body)).to contain_exactly(
        'Sorry, I meant Application Programming Interface'
      )
    end
  end
end