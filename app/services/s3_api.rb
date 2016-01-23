class S3Api
  class << self
    def direct_post(user, board)
      bucket.
        presigned_post(
          key: "#{dir_path(user, board)}/#{SecureRandom.hex.first(6)}/${filename}",
          content_type: 'image/png',
          acl: 'public-read',
          # content_length_range: 0..1024, - Doesn't work. Return 400.
          success_action_status: '201'
        )
    end

    def client
      @client ||= Aws::S3::Resource.new(
        credentials: Aws::Credentials.new(
          ENV['AWS_ACCESS_KEY_ID'],
          ENV['AWS_SECRET_ACCESS_KEY']
        ),
        region: 'us-east-1' # => 'US Standard', see - http://docs.aws.amazon.com/general/latest/gr/rande.html
      )
    end

    def bucket
      @bucket ||= client.bucket("agile-season-#{Rails.env}")
    end

    def dir_path(user, board)
      "uploads/#{user.id}/#{board.id}/#{Time.current.strftime('%Y%m%d')}"
    end
  end
end
