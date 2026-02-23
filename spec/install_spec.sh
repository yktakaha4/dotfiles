Describe 'install.sh'
  subject() {
    target_dir="$(mktemp -d || exit 1)"

    export DOTFILES_SKIP_INSTALL_DEPS=1
    export DOTFILES_TARGET_DIR="$target_dir"

    touch "$DOTFILES_TARGET_DIR/.zprofile"

    mkdir -p "$DOTFILES_TARGET_DIR/.codex/skills/task"
    touch "$DOTFILES_TARGET_DIR/.codex/skills/task/existing_file.md"

    ./install.sh
  }

  It '依存関係のインストールがスキップされる'
    When call subject

    The output should include "install dependencies: skipped."
    The error should equal ""
    The status should be success
  End

  It 'Symlinkとコピーが正しく設定される'
    When call subject

    The output should include "done."
    The error should equal ""
    The status should be success

    The path "$DOTFILES_TARGET_DIR/.zshrc" should be a symlink

    The path "$DOTFILES_TARGET_DIR/.zprofile" should be a file

    The path "$DOTFILES_TARGET_DIR/.claude/skills/task/SKILL.md" should be a file

    The path "$DOTFILES_TARGET_DIR/.codex/skills/task/SKILL.md" should be a file
    The path "$DOTFILES_TARGET_DIR/.codex/skills/task/existing_file.md" should not be exist
  End

  It 'claude codeの設定ファイルが生成される'
    When call subject

    The output should include "done."
    The error should equal ""
    The status should be success

    The path "$DOTFILES_TARGET_DIR/.claude/settings.json" should be a file
    The contents of file "$DOTFILES_TARGET_DIR/.claude/settings.json" should include 'Write(tkhstmp/**)'
  End
End
