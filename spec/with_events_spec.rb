RSpec.describe WithEvents do
  describe 'When included' do
    let(:dummy_class) do
      Class.new { include WithEvents }
    end

    it 'Then defines .stream method' do
      expect(dummy_class.methods).to include(:stream)
    end
  end
end
