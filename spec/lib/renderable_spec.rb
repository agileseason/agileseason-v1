describe Renderable do
  class TestClass < Renderable
  end

  describe '.to_css' do
    context 'self' do
      subject { Renderable.to_css }
      it { is_expected.to eq 'renderable' }
    end

    context 'inheritor' do
      subject { TestClass.to_css }
      it { is_expected.to eq 'test-class' }
    end
  end

  describe '#to_css' do
    context 'self instance' do
      subject { Renderable.new.to_css }
      it { is_expected.to eq 'renderable' }
    end

    context 'inheritor instance' do
      subject { TestClass.new.to_css }
      it { is_expected.to eq 'test-class' }
    end
  end
end
