package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/yktakaha4/dotfiles/tools/capytool/internal/version"
)

// buildVersion is the version string injected via ldflags at build time.
// Example: go build -ldflags="-X main.buildVersion=v1.0.0" ./cmd/capytool
var buildVersion = version.Default

func main() {
	if err := run(os.Args[1:]); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func run(args []string) error {
	fs := flag.NewFlagSet("capytool", flag.ContinueOnError)
	showVersion := fs.Bool("version", false, "print version and exit")

	if err := fs.Parse(args); err != nil {
		return err
	}

	if *showVersion {
		fmt.Printf("capytool %s\n", buildVersion)
		return nil
	}

	if fs.NArg() == 0 {
		return fmt.Errorf("no command specified; run with --help for usage")
	}

	return fmt.Errorf("unknown command: %s", fs.Arg(0))
}
