# Odin Setup

CLI tool to generate Odin projects with VSCode debugging support. Creates the required .vscode configuration files and basic project structure.

I made this tool for my own educational purposes, but I hope it can be useful for someone else.

## Usage

```bash
odin-setup <project-name>
```

## Features

- Configures VSCode debugging for Windows (cppvsdbg) and Unix (lldb)
- Generates launch.json, tasks.json and settings.json
- Creates minimal "Hello World" program
- Cross-platform support

## Requirements

- Odin compiler
- Visual Studio Code

In Windows, you need [C++ Build Tools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools)
In Unix, you need [CodeLLDB](https://marketplace.visualstudio.com/items?itemName=vadimcn.vscode-lldb)
