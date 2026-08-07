package main

import (
	"errors"
	"flag"
	"strings"
	"testing"
)

func TestRunVersion(t *testing.T) {
	if err := run([]string{"--version"}); err != nil {
		t.Fatalf("expected no error, got: %v", err)
	}
}

func TestRunNoArgs(t *testing.T) {
	err := run(nil)
	if err == nil || !strings.Contains(err.Error(), "no command specified") {
		t.Fatalf("unexpected error: %v", err)
	}
}

func TestRunUnknownCommand(t *testing.T) {
	err := run([]string{"unknown"})
	if err == nil || !strings.Contains(err.Error(), "unknown command") {
		t.Fatalf("unexpected error: %v", err)
	}
}

func TestRunHelp(t *testing.T) {
	if err := run([]string{"--help"}); !errors.Is(err, flag.ErrHelp) {
		t.Fatalf("expected flag.ErrHelp, got: %v", err)
	}
}
