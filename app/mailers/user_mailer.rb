class UserMailer < ActionMailer::Base
  default from: "apoorvi.kapoor@gmail.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user)
    @user = user
    mail :to => user.email, :subject => "Password Reset"
  end
  
  # attachments => { filename => file_path}
  # to => user email or user_name <user_email>
  # subject => email subject
  # template => mail template name.
  # template_path => path to template like 'mail_templates' for template app/views/mail_templates/mail.html.erb
  # headers => hash to contain various mail headers
  def send_mail(mail_options,user)
    #attach all the files
    return if Rails.env == 'development'
    @to_user = user[0]
    @from_user = user[1]
    files_attach = mail_options[:attachments]

    if files_attach 
      files_attach.each do |file, path|
        attachments[file] = File.read path
      end
    end
    
    #set header if any
    headers mail_options[:headers] if mail_options[:headers]
    
    to = mail_options[:to] || @user.email
    subject = mail_options[:subject]
    template_path = mail_options[:template_path] || 'mail_templates'
    template = mail_options[:template]
    
    
    message = mail(:to => to,
            :subject => subject,
            :template_path => template_path,
            :template_name => template)
            
    message.deliver
  end
end
