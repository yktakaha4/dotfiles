package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"

	"github.com/yktakaha4/dotfiles/tools/capytool/internal/mergejson"
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

	fs.Usage = func() {
		fmt.Fprintf(fs.Output(), "Usage: capytool [flags] <command> [arguments]\n\n")
		fmt.Fprintf(fs.Output(), "Commands:\n")
		fmt.Fprintf(fs.Output(), "  generate-claude-code-settings <json-files...>\n")
		fmt.Fprintf(fs.Output(), "    \tMerge JSON files and write the result to stdout.\n")
		fmt.Fprintf(fs.Output(), "    \tLater files take precedence; array values are deduplicated.\n\n")
		fmt.Fprintf(fs.Output(), "Flags:\n")
		fs.PrintDefaults()
	}

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

	switch fs.Arg(0) {
	case "generate-claude-code-settings":
		return runGenerateClaudeCodeSettings(fs.Args()[1:])
	}

	return fmt.Errorf("unknown command: %s", fs.Arg(0))
}

// runGenerateClaudeCodeSettings reads one or more JSON files, deep-merges them
// in order (later files win), and writes the merged JSON to stdout.
func runGenerateClaudeCodeSettings(files []string) error {
	if len(files) == 0 {
		return fmt.Errorf("generate-claude-code-settings: at least one JSON file must be specified")
	}

	result := map[string]any{}

	for _, path := range files {
		data, err := os.ReadFile(path)
		if err != nil {
			return fmt.Errorf("generate-claude-code-settings: read %q: %w", path, err)
		}

		var obj map[string]any
		if err := json.Unmarshal(data, &obj); err != nil {
			return fmt.Errorf("generate-claude-code-settings: parse %q: %w", path, err)
		}

		result = mergejson.Merge(result, obj)
	}

	out, err := json.MarshalIndent(result, "", "  ")
	if err != nil {
		return fmt.Errorf("generate-claude-code-settings: marshal output: %w", err)
	}

	fmt.Println(string(out))
	return nil
}
