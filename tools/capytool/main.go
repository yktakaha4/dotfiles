package main

import (
	"flag"
	"fmt"
	"os"
)

const version = "0.1.0"

func main() {
	var showVersion bool
	flag.BoolVar(&showVersion, "version", false, "show version")
	flag.BoolVar(&showVersion, "v", false, "show version (shorthand)")
	flag.Parse()

	if showVersion {
		fmt.Printf("capytool version %s\n", version)
		os.Exit(0)
	}

	fmt.Println("capytool - A CLI tool for dotfiles management")
	fmt.Println("Use -version or -v to show version")
}
