module Encryptor
  ENCRYPTOR = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base)

  def self.encrypt(arg)
    ENCRYPTOR.encrypt_and_sign(arg)
  end

  def self.decrypt(arg)
    ENCRYPTOR.decrypt_and_verify(arg)
  end
end
