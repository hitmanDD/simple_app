class UserMailer < ApplicationMailer

  def account_activation(user)
    @user = user
    mail to: user.email, subject: "Account activation"
  end

  # Обязательно добавь (user) здесь
  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset"
  end
end