module VirtusService
  extend ActiveSupport::Concern

  included do
    include Service
    include Virtus.model
  end
end
