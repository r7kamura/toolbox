RSpec.describe FactoryBot do
  describe '.lint' do
    subject do
      described_class.lint(factories)
    end

    let(:factories) do
      described_class.factories.reject do |factory|
        ignored_factory_names.include?(factory.name)
      end
    end

    let(:ignored_factory_names) do
      Set[
        :foo,
        :bar,
      ]
    end

    # To print full error message, avoid using `expect { ... }.not_to raise_error`.
    it 'succeeds' do
      subject
    end
  end
end
