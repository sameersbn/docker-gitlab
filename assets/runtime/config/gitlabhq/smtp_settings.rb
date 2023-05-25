# To enable smtp email delivery for your GitLab instance do the following:
# 1. Rename this file to smtp_settings.rb
# 2. Edit settings inside this file
# 3. Restart GitLab instance
#
# For full list of options and their values see http://api.rubyonrails.org/classes/ActionMailer/Base.html
#
# If you change this file in a merge request, please also create a merge request on https://gitlab.com/gitlab-org/omnibus-gitlab/merge_requests

if Rails.env.production?
  Rails.application.config.action_mailer.delivery_method = :smtp
  secrets = Gitlab::Email::SmtpConfig.secrets

  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
    address: "{{SMTP_HOST}}",
    port: {{SMTP_PORT}},
    user_name: "{{SMTP_USER}}",
    password: "{{SMTP_PASS}}",
    ## If you are using encrypted smtp credentials then you should instead use the secrets user_name/password
    ## See: https://docs.gitlab.com/ee/administration/raketasks/smtp.html#secrets
    # user_name: secrets.username,
    # password: secrets.password,
    domain: "{{SMTP_DOMAIN}}",
    authentication: "{{SMTP_AUTHENTICATION}}",
    enable_starttls_auto: {{SMTP_STARTTLS}},
    openssl_verify_mode: '{{SMTP_OPENSSL_VERIFY_MODE}}', # See ActionMailer documentation for other possible options
    ca_path: "{{SMTP_CA_PATH}}",
    ca_file: "{{SMTP_CA_FILE}}",
    tls: {{SMTP_TLS}}
  }
end

# To use an SMTP connection pool, uncomment the following section:
#
# require 'mail/smtp_pool'
#
# ActionMailer::Base.add_delivery_method :smtp_pool, Mail::SMTPPool
#
# if Rails.env.production?
#   Rails.application.config.action_mailer.delivery_method = :smtp_pool
#   secrets = Gitlab::Email::SmtpConfig.secrets
#
#   ActionMailer::Base.delivery_method = :smtp_pool
#   ActionMailer::Base.smtp_pool_settings = {
#     pool: Mail::SMTPPool.create_pool(
#       pool_size: Gitlab::Runtime.max_threads,
#       address: "email.server.com",
#       port: 465,
#       user_name: "smtp",
#       password: "123456",
#       ## If you are using encrypted smtp credentials then you should instead use the secrets user_name/password
#       ## See: https://docs.gitlab.com/ee/administration/raketasks/smtp.html#secrets
#       # user_name: secrets.username,
#       # password: secrets.password,
#       domain: "gitlab.company.com",
#       authentication: :login,
#       enable_starttls_auto: true,
#       openssl_verify_mode: 'peer' # See ActionMailer documentation for other possible options
#     )
#   }
# end
