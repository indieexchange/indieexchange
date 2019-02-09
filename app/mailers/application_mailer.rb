class ApplicationMailer < ActionMailer::Base
  default from: 'tech@indiepubexchange.com' # change to support@, and search app-wide
  layout 'mailer'
end
