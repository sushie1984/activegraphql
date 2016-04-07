describe ActiveGraphQL::Query do
  let(:query) do
    described_class.new(url: url,
                        action: action,
                        params: params)
  end

  let(:url) { 'some-url' }
  let(:action) { :some_long_action_name }
  let(:params) do
    { some_long_param_name1: 'value1',
      some_long_param_name2: 'value2' }
  end

  let(:graph) do
    [:attr1,
     { object: [:nested_attr, nested_object: [:super_nested_attr]] },
     :attr2]
  end

  let(:expected_query_with_params) do
    '{ someLongActionName'\
    '(someLongParamName1: "value1", someLongParamName2: "value2") { ' \
    'attr1, object { nestedAttr, nestedObject { superNestedAttr } }, attr2 }' \
    ' }'
  end

  let(:expected_query_without_params) do
    '{ someLongActionName { ' \
    'attr1, object { nestedAttr, nestedObject { superNestedAttr } }, attr2 }' \
    ' }'
  end

  describe '#get' do
    before do
      expect(HTTParty).to receive(:get)
        .with(url, query: { query: expected_query_with_params })
        .and_return(response)
    end

    subject { query.get(*graph) }

    context 'with no errors in the response' do
      let(:response) do
        { 'data' => { 'someLongActionName' => { 'someExpected' => 'data' } } }
      end

      it { is_expected.to eq(some_expected: 'data') }
    end

    context 'with errors in the response' do
      let(:response) do
        {
          'errors' => [
            { 'message' => 'message1' },
            { 'message' => 'message2' }
          ]
        }
      end

      it 'fails with an error' do
        expect { subject }.to raise_error(ActiveGraphQL::Query::ServerError,
                                          /"message1", "message2"/)
      end
    end
  end

  describe '#to_s' do
    subject do
      query.tap { |q| q.graph = graph }.to_s
    end

    context 'without params' do
      let(:params) { nil }

      it { is_expected.to eq expected_query_without_params }
    end

    context 'with params' do
      it { is_expected.to eq expected_query_with_params }
    end
  end

  describe '#qaction' do
    subject { query.qaction }

    it { is_expected.to eq 'someLongActionName' }
  end

  describe 'qparams' do
    subject { query.qparams }

    context 'without params' do
      let(:params) { nil }

      it { is_expected.to be_nil }
    end

    context 'with params' do
      it { is_expected.to eq "someLongParamName1: \"value1\", someLongParamName2: \"value2\"" }
    end
  end

  describe '#qgraph' do
    subject { query.qgraph(graph) }

    it { is_expected.to eq 'attr1, object { nestedAttr, nestedObject { superNestedAttr } }, attr2' }
  end
end
