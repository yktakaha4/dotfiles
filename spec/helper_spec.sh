Describe '.helper.sh'
  Include ./.helper.sh

  Describe 'd_require'
    It '依存解決ができる場合'
      When call d_require git tmux
      The output should equal ""
      The error should equal ""
      The status should equal 0
    End

    It '依存解決ができない場合'
      When call d_require git unknowncommand
      The output should equal ""
      The error should equal ""
      The status should equal 1
    End
  End

  Describe 'd_exists'
    It '対象が存在する場合'
      target_file="$(mktemp)"
      target_dir="$(mktemp -d)"

      When call d_exists "$target_file" "$target_dir"
      The output should equal ""
      The error should equal ""
      The status should equal 0
    End

    It '対象が存在しない場合'
      target_file="$(mktemp)"
      When call d_exists "$target_file" "./unknownfile"
      The output should equal ""
      The error should equal ""
      The status should equal 1
    End
  End

  Describe 'd_os'
    It 'DarwinをそのままlowercaseにしてDarwinを返す'
      Mock uname
        echo "Darwin"
      End
      When call d_os
      The output should equal "darwin"
      The error should equal ""
      The status should equal 0
    End

    It 'LinuxをそのままlowercaseにしてLinuxを返す'
      Mock uname
        echo "Linux"
      End
      When call d_os
      The output should equal "linux"
      The error should equal ""
      The status should equal 0
    End
  End

  Describe 'd_arch'
    It 'x86_64をamd64に変換する'
      Mock uname
        echo "x86_64"
      End
      When call d_arch
      The output should equal "amd64"
      The error should equal ""
      The status should equal 0
    End

    It 'aarch64をarm64に変換する'
      Mock uname
        echo "aarch64"
      End
      When call d_arch
      The output should equal "arm64"
      The error should equal ""
      The status should equal 0
    End

    It 'arm64をそのまま返す'
      Mock uname
        echo "arm64"
      End
      When call d_arch
      The output should equal "arm64"
      The error should equal ""
      The status should equal 0
    End
  End

  Describe 'd_datetime'
    It '現在日時が所定の書式で取得できる'
      When call d_datetime
      The output should match pattern '????-??-??T??:??:??'
      The error should equal ""
      The status should equal 0
    End
  End

  Describe 'd_epoch_to_ms'
    Parameters
         0     0 "0.0s"
      1000  1000 "0.0s"
      1000    "" "0.0s"
      1500   500 "0.0s"
      # shellcheck disable=SC2286
        ""    "" "0.0s"
      # shellcheck disable=SC2286
        ""  1500 "0.0s"
      1000  2000 "1.0s"
      1000  3499 "2.5s"
         0 12345 "12.3s"
         x     y "0.0s"
    End

    It "エポックミリ秒が変換される($1, $2, $3)"
      When call d_epoch_to_ms "$1" "$2"
      The output should equal "$3"
      The error should equal ""
      The status should equal 0
    End
  End

  Describe 'd_prompt'
    remote_dir="$(mktemp -d)" || exit
    beforeAll() {
      git clone -q "https://github.com/yktakaha4/dotfiles_test" "$remote_dir"
    }

    beforeEach() {
      cd "$(mktemp -d)" || exit
    }

    BeforeAll 'beforeAll'
    BeforeEach 'beforeEach'

    It 'git管理外ではブランチ名が表示されない'
      When call d_prompt
      The output should equal "
%F{8}%~%F{3}%F{4}%F{8}%F{1}
%f$ "
    End

    It '時刻、実行時間、エラーコード、k8sコンテキストが表示される'
      DOTFILES_EXEC_DATETIME="YYYY-MM-DDTHH:MM:SS"
      # shellcheck disable=SC2034
      DOTFILES_EXEC_TIME="3.5s"
      # shellcheck disable=SC2034
      DOTFILES_RETURN_CODE="127"
      # shellcheck disable=SC2034
      DOTFILES_KUBE_CONTEXT="ctx:ns"

      When call d_prompt
      The output should equal "
%F{8}%~%F{3}%F{4} $DOTFILES_KUBE_CONTEXT%F{8} $DOTFILES_EXEC_DATETIME $DOTFILES_EXEC_TIME%F{1} ($DOTFILES_RETURN_CODE)
%f$ "
    End

    It 'git管理内でブランチ名が表示される'
      git init -qb main

      When call d_prompt
      The output should equal "
%F{8}%~ main%F{3} →%F{4}%F{8}%F{1}
%f$ "
    End

    It '未トラックのマークが表示される'
      git init -qb main
      touch untracked

      When call d_prompt
      The output should equal "
%F{8}%~ main%F{3} ?→%F{4}%F{8}%F{1}
%f$ "
    End

    It 'ステージされた変更のマークが表示される'
      git init -qb main
      touch staged
      git add staged

      When call d_prompt
      The output should equal "
%F{8}%~ main%F{3} +→%F{4}%F{8}%F{1}
%f$ "
    End

    It 'クローンした直後のリポジトリの場合pushマークが表示されない'
      cp -pr "$remote_dir/." .

      When call d_prompt
      The output should equal "
%F{8}%~ main%F{3}%F{4}%F{8}%F{1}
%f$ "
    End

		It 'コミットを積むとpushマークが表示される'
			cp -pr "$remote_dir/." .
      echo "new file" > new.txt
      git add .
      git commit -qm "add new file"

			When call d_prompt
      The output should equal "
%F{8}%~ main%F{3} ↑%F{4}%F{8}%F{1}
%f$ "
		End

    It 'force pushが必要な状態に対してpushマークが表示される'
      cp -pr "$remote_dir/." .
      git commit --amend -qm "amend"

      When call d_prompt
      The output should equal "
%F{8}%~ main%F{3} ↑↓%F{4}%F{8}%F{1}
%f$ "
    End

  End
End
