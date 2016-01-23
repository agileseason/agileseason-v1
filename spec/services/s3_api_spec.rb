describe S3Api do
  describe '.direct_post' do
    subject { S3Api.direct_post(user, board) }
    let(:user) { build_stubbed :user }
    let(:board) { build_stubbed :board }
    let(:bucket) { double }
    let(:expected_path_prefix) do
      "#{user.id}/#{board.id}/#{Time.current.strftime('%Y%m%d')}"
    end
    before { allow(bucket).to receive(:presigned_post) }
    before { allow(S3Api).to receive(:bucket).and_return(bucket) }
    before { allow(SecureRandom).to receive(:hex).and_return('abcdefg') }
    before { subject }

    it do
      expect(bucket).
        to have_received(:presigned_post).
        with(
          key: "uploads/#{expected_path_prefix}/abcdef/${filename}",
          content_type: 'image/png',
          acl: 'public-read',
          success_action_status: '201'
        )
    end
  end
end
