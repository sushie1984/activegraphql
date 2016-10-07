describe ActiveGraphQL::Helpers::ModelHelper do
  let(:described_class) do
    Class.new { extend ActiveGraphQL::Helpers::ModelHelper }
  end

  RSpec.shared_examples "map_to_s" do |parameter, expected_value|

    it "transforms '#{parameter}' to '#{expected_value}'" do
      expect(described_class.map_to_s(parameter)).to eq(expected_value)
    end
  end

  describe '#map_to_s' do

    it_behaves_like 'map_to_s', '', ''
    it_behaves_like 'map_to_s', '  ', ''
    it_behaves_like 'map_to_s', nil, ''
    it_behaves_like 'map_to_s', 'FIELD ASC', 'FIELD ASC'
    it_behaves_like 'map_to_s', { name: :asc }, 'name asc'
    it_behaves_like 'map_to_s', { name: :asc, id: :desc }, 'name asc, id desc'
    it_behaves_like 'map_to_s', Class.new, ''

  end
end
