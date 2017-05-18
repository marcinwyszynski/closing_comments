RSpec.describe Boom::Bacon do
  shared_context 'with tasty bacon' do
    let(:taste) { 'awesome' }
  end

  shared_examples 'ensures it is awesome' do
    it { expect(bacon).to be_tasty }
  end

  describe '#eat' do
    context 'when delicious' do
      it { expect(bacon.delicious).to be_truthy }
    end
  end
end
