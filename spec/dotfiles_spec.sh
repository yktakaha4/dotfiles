Describe 'Integrated test'
  It '読み込み時にエラーにならない'
    setup() {
      . ./.zprofile
      . ./.zshrc
    }

    When call setup
    The output should equal ""
    The error should equal ""
    The status should be success
    The variable EDITOR should equal vim
  End
End
