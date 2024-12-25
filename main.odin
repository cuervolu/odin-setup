package main

import "base:runtime"
import "core:fmt"
import "core:log"
import "core:os"
import "core:strings"

Config :: struct {
	program_name: string,
	is_windows:   bool,
}

Project_Error :: enum {
	None,
	Directory_Creation_Failed,
	File_Write_Failed,
	Path_Change_Failed,
}

main :: proc() {
	context.logger = log.create_console_logger()
	log.info("Program started")

	if len(os.args) < 2 {
		fmt.println("Use: odin-setup <project-name>")
		os.exit(1)
	}

	is_windows := false
	when ODIN_OS == .Windows {
		is_windows = true
		log.info("Running on Windows")
	} else {
		log.info("Running on Linux")
	}

	config := Config {
		program_name = os.args[1],
		is_windows   = is_windows,
	}

	if err := create_project(config); err != .None {
		log.error("Failed to create project: ", err)
		os.exit(1)
	}

	log.destroy_console_logger(context.logger)
}

create_project :: proc(config: Config) -> Project_Error {
	log.info("Creating project: ", config.program_name)

	if err := os.make_directory(config.program_name); err != 0 {
		log.error("Failed to create project directory")
		return .Directory_Creation_Failed
	}

	if err := os.set_current_directory(config.program_name); err != 0 {
		log.error("Failed to change directory")
		return .Path_Change_Failed
	}

	if err := os.make_directory(".vscode"); err != 0 {
		log.error("Failed to create .vscode directory")
		return .Directory_Creation_Failed
	}

	if err := create_launch_json(config); err != .None {
		return err
	}
	if err := create_settings_json(); err != .None {
		return err
	}
	if err := create_tasks_json(); err != .None {
		return err
	}
	if err := create_main_odin(); err != .None {
		return err
	}

	fmt.println("Project created successfully!")
	return .None
}

create_launch_json :: proc(config: Config) -> Project_Error {
	log.info("Creating launch.json")

	program_path := strings.concatenate(
		{"${workspaceFolder}/${workspaceFolderBasename}", config.is_windows ? ".exe" : ""},
	)
	debugger_type := config.is_windows ? "cppvsdbg" : "lldb"

	launch_content := strings.concatenate(
		{
			`{
        "version": "0.2.0",
        "configurations": [
            {
                "type": "`,
			debugger_type,
			`",
                "request": "launch",
                "preLaunchTask": "Build",
                "name": "Debug",
                "program": "`,
			program_path,
			`",
                "args": [],
                "cwd": "${workspaceFolder}"
            }
        ]
    }`,
		},
	)

	if ok := os.write_entire_file(".vscode/launch.json", transmute([]byte)launch_content); !ok {
		log.error("Failed to write launch.json")
		return .File_Write_Failed
	}

	log.info("launch.json created")
	return .None
}

create_settings_json :: proc() -> Project_Error {
	log.info("Creating settings.json")

	settings_content := `{
    "debug.allowBreakpointsEverywhere": true
}`


	if ok := os.write_entire_file(".vscode/settings.json", transmute([]byte)settings_content);
	   !ok {
		log.error("Failed to write settings.json")
		return .File_Write_Failed
	}

	log.info("settings.json created")
	return .None
}

create_tasks_json :: proc() -> Project_Error {
	log.info("Creating tasks.json")

	tasks_content := `{
    "version": "2.0.0",
    "command": "",
    "args": [],
    "tasks": [
        {
            "label": "Build",
            "type": "shell",
            "command": "odin build . -debug",
            "group": "build"
        }
    ]
}`


	if ok := os.write_entire_file(".vscode/tasks.json", transmute([]byte)tasks_content); !ok {
		log.error("Failed to write tasks.json")
		return .File_Write_Failed
	}

	log.info("tasks.json created")
	return .None
}

create_main_odin :: proc() -> Project_Error {
	log.info("Creating main.odin")

	main_content := `package main

import "core:fmt"

main :: proc() {
    fmt.println("Hello World!")
}`


	if ok := os.write_entire_file("main.odin", transmute([]byte)main_content); !ok {
		log.error("Failed to write main.odin")
		return .File_Write_Failed
	}

	log.info("main.odin created")
	return .None
}
