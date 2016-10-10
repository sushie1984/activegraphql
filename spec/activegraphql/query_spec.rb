describe ActiveGraphQL::Query do
  let(:query) do
    described_class.new(config: config,
                        action: action,
                        params: params)
  end

  let(:config) do
    { url: url }
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

  describe '#call' do
    let(:response) do
      { 'data' => { 'someLongActionName' => { 'someExpected' => 'data' } } }
    end

    context 'focus config timeout & bearer' do
      before do
        expect(HTTParty)
          .to receive(:get).with(url, expected_request_options)
          .and_return(response)
      end

      subject { query.call(*graph) }

      context 'with timeout configured' do
        let(:expected_request_options) do
          { query: { query: expected_query_with_params }, timeout: 0.1 }
        end

        let(:config) do
          { url: url,
            http: { timeout: 0.1 } }
        end

        it { is_expected.to eq(some_expected: 'data') }
      end

      context 'without timeout configured' do
        let(:expected_request_options) do
          { query: { query: expected_query_with_params } }
        end

        context 'with no errors in the response' do
          it { is_expected.to eq(some_expected: 'data') }

          context 'with locale' do
            let(:locale) { :en }

            let(:expected_request_options) do
              { headers: { 'Accept-Language' => locale.to_s },
                query: { query: expected_query_with_params } }
            end

            before { query.locale = locale }

            it { is_expected.to eq(some_expected: 'data') }
          end
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

      context 'with bearer auth strategy configured' do
        let(:token) { 'some.token' }

        let(:expected_request_options) do
          { query: { query: expected_query_with_params },
            headers: { 'Authorization' => "Bearer #{token}" } }
        end

        let(:config) do
          { url: url,
            auth: { strategy: :bearer, class: Object } }
        end

        before do
          expect(Object).to receive(:encode).and_return(token)
        end

        it { is_expected.to eq(some_expected: 'data') }
      end
    end

    context 'focus config http query methods' do
      context 'method not configured' do
        before do
          expect(HTTParty)
            .to receive(:get).with(url, expected_request_options)
            .and_return(response)
        end

        let(:expected_request_options) do
          { query: { query: expected_query_with_params } }
        end

        let(:config) do
          { url: url }
        end

        subject { query.call(*graph) }

        it { is_expected.to eq(some_expected: 'data') }
      end

      context 'method post configured' do
        before do
          expect(HTTParty)
            .to receive(:post).with(url, expected_request_options)
            .and_return(response)
        end

        let(:expected_request_options) do
          { query: { query: expected_query_with_params } }
        end

        let(:config) do
          { url: url, method: :post }
        end

        subject { query.call(*graph) }

        it { is_expected.to eq(some_expected: 'data') }
      end

      context 'method patch configured' do
        before do
          expect(HTTParty)
            .to receive(:get).with(url, expected_request_options)
            .and_return(response)

          expect do
            warn('patch is not supported, using default get')
          end.to output.to_stderr
        end

        let(:expected_request_options) do
          { query: { query: expected_query_with_params } }
        end

        let(:config) do
          { url: url, method: :patch }
        end

        subject { query.call(*graph) }

        it { is_expected.to eq(some_expected: 'data') }
      end
    end
  end
end
