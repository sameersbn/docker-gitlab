# To enable smtp email delivery for your GitLab instance do next: 
# 1. Rename this file to smtp_settings.rb
# 2. Edit settings inside this file
# 3. Restart GitLab instance
#
if Rails.env.production?
  Gitlab::Application.config.action_mailer.delivery_method = :smtp

  ActionMailer::Base.smtp_settings = {
    address: "{{SMTP_HOST}}",
    port: {{SMTP_PORT}},
    user_name: "{{SMTP_USER}}",
    password: "{{SMTP_PASS}}",
    domain: "{{SMTP_DOMAIN}}",
    authentication: "{{SMTP_AUTHENTICATION}}",
    openssl_verify_mode: "{{SMTP_OPENSSL_VERIFY_MODE}}",
    enable_starttls_auto: {{SMTP_STARTTLS}},
    ca_path: "{{SMTP_CA_PATH}}",
    ca_file: "{{SMTP_CA_FILE}}",
    tls: {{SMTP_TLS}}
  }
end
