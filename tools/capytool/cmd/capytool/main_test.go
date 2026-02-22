package main

import (
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestRun_Version(t *testing.T) {
	// --version flag should succeed without error
	if err := run([]string{"--version"}); err != nil {
		t.Fatalf("expected no error, got: %v", err)
	}
}

func TestRun_NoArgs(t *testing.T) {
	err := run([]string{})
	if err == nil {
		t.Fatal("expected error for no arguments, got nil")
	}
	if !strings.Contains(err.Error(), "no command specified") {
		t.Fatalf("unexpected error message: %v", err)
	}
}

func TestRun_UnknownCommand(t *testing.T) {
	err := run([]string{"unknown"})
	if err == nil {
		t.Fatal("expected error for unknown command, got nil")
	}
	if !strings.Contains(err.Error(), "unknown command") {
		t.Fatalf("unexpected error message: %v", err)
	}
}

func TestRun_Help(t *testing.T) {
	// --help returns flag.ErrHelp wrapped in a ContinueOnError FlagSet
	err := run([]string{"--help"})
	if err == nil {
		t.Fatal("expected error (flag.ErrHelp) for --help, got nil")
	}
}

// writeTempJSON writes content to a temporary JSON file and returns its path.
func writeTempJSON(t *testing.T, content string) string {
	t.Helper()
	dir := t.TempDir()
	path := filepath.Join(dir, "input.json")
	if err := os.WriteFile(path, []byte(content), 0600); err != nil {
		t.Fatalf("failed to write temp file: %v", err)
	}
	return path
}

func TestRun_GenerateClaudeCodeSettings_NoFiles(t *testing.T) {
	err := run([]string{"generate-claude-code-settings"})
	if err == nil {
		t.Fatal("expected error when no files given, got nil")
	}
	if !strings.Contains(err.Error(), "at least one JSON file") {
		t.Errorf("unexpected error: %v", err)
	}
}

func TestRun_GenerateClaudeCodeSettings_FileNotFound(t *testing.T) {
	err := run([]string{"generate-claude-code-settings", "/nonexistent/path.json"})
	if err == nil {
		t.Fatal("expected error for missing file, got nil")
	}
}

func TestRun_GenerateClaudeCodeSettings_InvalidJSON(t *testing.T) {
	path := writeTempJSON(t, "not-json")
	err := run([]string{"generate-claude-code-settings", path})
	if err == nil {
		t.Fatal("expected error for invalid JSON, got nil")
	}
	if !strings.Contains(err.Error(), "parse") {
		t.Errorf("unexpected error: %v", err)
	}
}

func TestRun_GenerateClaudeCodeSettings_SingleFile(t *testing.T) {
	path := writeTempJSON(t, `{"key":"value"}`)
	if err := run([]string{"generate-claude-code-settings", path}); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
}

func TestRun_GenerateClaudeCodeSettings_ArrayDeduplicate(t *testing.T) {
	// Use runGenerateClaudeCodeSettings directly so we can capture behaviour;
	// the actual output goes to stdout which is fine for integration-level checks.
	// Here we call the helper that exercises the merge logic end-to-end.
	file1 := writeTempJSON(t, `{"permissions":{"allow":["Bash"]}}`)
	file2 := writeTempJSON(t, `{"permissions":{"allow":["Read","Bash"]}}`)

	// Redirect stdout is non-trivial; instead we exercise runGenerateClaudeCodeSettings
	// and trust that TestMerge_* in the mergejson package covers the logic.
	// We only verify no error is returned.
	if err := run([]string{"generate-claude-code-settings", file1, file2}); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
}

func TestRunGenerateClaudeCodeSettings_MergeResult(t *testing.T) {
	// Verify merged output by calling the internal function directly and
	// capturing what it writes to stdout via a pipe.
	origStdout := os.Stdout
	r, w, err := os.Pipe()
	if err != nil {
		t.Fatalf("pipe: %v", err)
	}
	os.Stdout = w

	file1 := writeTempJSON(t, `{"permissions":{"allow":["Bash"]}}`)
	file2 := writeTempJSON(t, `{"permissions":{"allow":["Read","Bash"]}}`)
	runErr := runGenerateClaudeCodeSettings([]string{file1, file2})

	w.Close()
	os.Stdout = origStdout

	if runErr != nil {
		t.Fatalf("unexpected error: %v", runErr)
	}

	buf := make([]byte, 4096)
	n, _ := r.Read(buf)
	output := string(buf[:n])

	var result map[string]any
	if err := json.Unmarshal([]byte(output), &result); err != nil {
		t.Fatalf("output is not valid JSON: %v\noutput: %s", err, output)
	}

	perms, ok := result["permissions"].(map[string]any)
	if !ok {
		t.Fatalf("expected permissions to be object, got %T", result["permissions"])
	}
	allow, ok := perms["allow"].([]any)
	if !ok {
		t.Fatalf("expected allow to be array, got %T", perms["allow"])
	}
	if len(allow) != 2 {
		t.Errorf("expected 2 entries after dedup, got %d: %v", len(allow), allow)
	}
}
