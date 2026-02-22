package main

import (
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
