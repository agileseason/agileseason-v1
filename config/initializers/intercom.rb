IntercomRails.config do |config|
  # == Intercom app_id
  #
  config.app_id = ENV['INTERCOM_APP_ID'] || 'xxw8dl34'

  # == Intercom secret key
  # This is required to enable secure mode, you can find it on your Setup
  # guide in the "Secure Mode" step.
  #
  config.api_secret = ENV['AGILE_SEASON_INTERCOM_API_SECRET']

  # == Enabled Environments
  # Which environments is auto inclusion of the Javascript enabled for
  #
  #config.enabled_environments = ['development', 'production']
  config.enabled_environments = ['production']

  # == Current user method/variable
  # The method/variable that contains the logged in user in your controllers.
  # If it is `current_user` or `@user`, then you can ignore this
  #
  # config.user.current = Proc.new { current_user }

  # == Include for logged out Users
  # If set to true, include the Intercom messenger on all pages, regardless of whether
  # The user model class (set below) is present. Only available for Apps on the Acquire plan.
  # config.include_for_logged_out_users = true

  # == User model class
  # The class which defines your user model
  #
  # config.user.model = Proc.new { User }

  # == Exclude users
  # A Proc that given a user returns true if the user should be excluded
  # from imports and Javascript inclusion, false otherwise.
  #
  # config.user.exclude_if = Proc.new { |user| user.deleted? }

  # == User Custom Data
  # A hash of additional data you wish to send about your users.
  # You can provide either a method name which will be sent to the current
  # user object, or a Proc which will be passed the current user.

  config.user.custom_data = {
    name: :github_username,
    github_username: :github_username,
    github: Proc.new { |current_user| "https://github.com/#{current_user.github_username}" }
  }

  # == User -> Company association
  # A Proc that given a user returns an array of companies
  # that the user belongs to.
  #
  # config.user.company_association = Proc.new { |user| user.companies.to_a }
  # config.user.company_association = Proc.new { |user| [user.company] }

  # == Current company method/variable
  # The method/variable that contains the current company for the current user,
  # in your controllers. 'Companies' are generic groupings of users, so this
  # could be a company, app or group.
  #
  # config.company.current = Proc.new { current_company }

  # == Company Custom Data
  # A hash of additional data you wish to send about a company.
  # This works the same as User custom data above.
  #
  # config.company.custom_data = {
  #   :number_of_messages => Proc.new { |app| app.messages.count },
  #   :is_interesting => :is_interesting?
  # }

  # == Company Plan name
  # This is the name of the plan a company is currently paying (or not paying) for.
  # e.g. Messaging, Free, Pro, etc.
  #
  # config.company.plan = Proc.new { |current_company| current_company.plan.name }

  # == Company Monthly Spend
  # This is the amount the company spends each month on your app. If your company
  # has a plan, it will set the 'total value' of that plan appropriately.
  #
  # config.company.monthly_spend = Proc.new { |current_company| current_company.plan.price }
  # config.company.monthly_spend = Proc.new { |current_company| (current_company.plan.price - current_company.subscription.discount) }

  # == Custom Style
  # By default, Intercom will add a button that opens the messenger to
  # the page. If you'd like to use your own link to open the messenger,
  # uncomment this line and clicks on any element with id 'Intercom' will
  # open the messenger.
  #
  # config.inbox.style = :custom
end
