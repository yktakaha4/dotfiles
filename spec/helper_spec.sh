Describe '.helper.sh'
  Include ./.helper.sh

  Describe 'd_prompt'
    beforeEach() {
      cd "$(mktemp -d)" || exit
    }

    BeforeEach 'beforeEach'

    It 'git管理外ではブランチ名が表示されない'
      When call d_prompt
      The output should equal "
%F{8}%~%F{3}%F{8}%F{1}
%f$ "
    End

    It '実行時間、エラーコードが表示される'
      # shellcheck disable=SC2034
      DOTFILES_EXEC_TIME="3.5s"
      # shellcheck disable=SC2034
      DOTFILES_RETURN_CODE="127"

      When call d_prompt
      The output should equal "
%F{8}%~%F{3}%F{8} 3.5s%F{1} (127)
%f$ "
    End

    It 'git管理内でブランチ名が表示される'
      git init -qb main

      When call d_prompt
      The output should equal "
%F{8}%~ main%F{3} →%F{8}%F{1}
%f$ "
    End

    It '未トラックのマークが表示される'
      git init -qb main
      touch untracked

      When call d_prompt
      The output should equal "
%F{8}%~ main%F{3} ?→%F{8}%F{1}
%f$ "
    End

    It 'ステージされた変更のマークが表示される'
      git init -qb main
      touch staged
      git add staged

      When call d_prompt
      The output should equal "
%F{8}%~ main%F{3} +→%F{8}%F{1}
%f$ "
    End

    It 'クローンしたリポジトリの場合マークが表示されない'
      git clone -q "https://github.com/yktakaha4/dotfiles_test" .

      When call d_prompt
      The output should equal "
%F{8}%~ main%F{3}%F{8}%F{1}
%f$ "
    End
  End
End
