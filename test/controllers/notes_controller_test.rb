require "test_helper"

class NotesControllerTest < ActionDispatch::IntegrationTest

  test "should redirect create when not logged in" do
    assert_no_difference 'Note.count' do
      post notes_path, params: { note: { content: "Lorem ipsum" } }
    end
    assert_redirected_to login_url
  end

  #test "should redirect destroy when not logged in" do
  #  assert_no_difference 'Note.count' do
  #   delete note_path(notes(:one)) # Если есть фикстуры
  #  end
  #  assert_response :see_other
  #  assert_redirected_to login_url
  #end
end