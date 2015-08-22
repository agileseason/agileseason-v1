# bucket = s3.bucket('agile-season-development')
# obj = bucket.object('hello')
# obj.put(body:'Hello World!')
# obj.public_url
class S3Api
  class << self
    def direct_post
      bucket.
        presigned_post(
          key: "#{dir_path}/${filename}",
          # content_type_starts_with: 'image/',
          content_type: 'image/png',
          acl: 'public-read',
          # content_length_range: 0..1024,
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

    def dir_path
      "uploads/#{Time.current.strftime('%Y-%m-%d')}/#{SecureRandom.uuid}"
    end
  end
end
