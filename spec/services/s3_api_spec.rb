describe S3Api do
  describe '.direct_post' do
    subject { S3Api.direct_post }
    let(:bucket) { double }
    let(:expected_path_prefix) { Time.current.strftime('%Y-%m-%d') }
    before { allow(bucket).to receive(:presigned_post) }
    before { allow(S3Api).to receive(:bucket).and_return(bucket) }
    before { allow(SecureRandom).to receive(:uuid).and_return('abc') }
    before { subject }

    it do
      expect(bucket).
        to have_received(:presigned_post).
        with(
          key: "uploads/#{expected_path_prefix}/abc/${filename}",
          content_type: 'image/png',
          acl: 'public-read',
          success_action_status: '201'
        )
    end
  end
end
