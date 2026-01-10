Describe 'Integrated test'
  It '読み込み時にエラーにならない'
    subject() {
      . ./.zprofile
      . ./.zshrc
    }

    When call subject
    The output should equal ""
    The error should equal ""
    The status should be success
    The variable EDITOR should equal vim
  End
End
