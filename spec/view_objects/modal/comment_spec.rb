describe Modal::Comment do
  let(:comment) { Modal::Comment.new(github_comment, markdown) }
  let(:markdown) { '<p>test</p>' }
  let(:github_comment) do
    OpenStruct.new(
      id: 102,
      body: 'test',
      user: stub_user,
      created_at: Time.current
    )
  end

  describe '#to_h' do
    subject { comment.to_h }

    it do
      is_expected.to eq ({
        id: github_comment.id,
        type: :comment,
        body: github_comment.body,
        markdown: markdown,
        created_at: github_comment.created_at,
        created_at_str: github_comment.created_at.strftime('%b %d, %H:%M'),
        user: github_comment.user.to_h
      })
    end
  end
end
