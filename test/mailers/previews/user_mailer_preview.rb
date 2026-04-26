class UserMailerPreview < ActionMailer::Preview

  def account_activation
    user = User.first
    user.activation_token = User.new_token
    UserMailer.account_activation(user)
  end

  def password_reset
    user = User.first
    if user.nil?
      user = User.new(name: "Example User", email: "user@example.com",
                      activation_token: User.new_token)
    end
    user.reset_token = User.new_token
    UserMailer.password_reset(user)
  end
end # ВОТ ЭТОГО ЭНДА НЕ ХВАТАЛО