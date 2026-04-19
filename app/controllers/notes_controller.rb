class NotesController < ApplicationController
  before_action :logged_in_user # Этот метод нужно взять из книги Хартла

  def create
    @note = current_user.notes.build(note_params)
    if @note.save
      flash[:success] = "Заметка создана!"
      redirect_to root_url
    else
      render 'static_pages/home'
    end
  end

  private

  def note_params
    params.require(:note).permit(:content)
  end
end