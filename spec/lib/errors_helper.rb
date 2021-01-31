RSpec.shared_examples 'Unprocessable Entity Error' do
  let(:request_body) { { } }
  it 'returns an error' do
    expect(subject).to have_http_status(:unprocessable_entity)
  end
end

RSpec.shared_examples 'Not Found Error' do
  let(:school_id) { 0 }
  it 'returns an error' do
    expect(subject).to have_http_status(:not_found)
  end
end