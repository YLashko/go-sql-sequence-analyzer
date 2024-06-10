package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"main/analyzer"
	"main/reader"
	"os"
	"strings"
)

type Config_data struct {
	In_folder         string
	Out_folder        string
	Comments_regexp   string
	Delimiters_regexp string
}

func main() {
	// files := analyze("./data/in", "(\\/\\*(.|\n)*?\\*\\/)|(--(.)*(\n|$))|(\\'(.|\n)*?\\')", "[\\(\\[\\{.,:=+\\|/*\\}\\]\\)"+string(byte(10))+string(byte(13))+"]")
	var config_data Config_data
	config_file_contents := reader.Read_file("./config.json")
	err := json.Unmarshal([]byte(config_file_contents), &config_data)
	if err != nil {
		panic(err)
	}

	files := analyze(config_data.In_folder, config_data.Comments_regexp, config_data.Delimiters_regexp)
	output_files(files, config_data.Out_folder)
	fmt.Println("Finished, press enter to exit")
	io_reader := bufio.NewReader(os.Stdin)
	io_reader.ReadString('\n')
}

func output_files(files []reader.File_info, out_folder_path string) {
	reader.Empty_dir(out_folder_path)
	for i := 0; i < len(files); i++ {
		reader.Copy_file(files[i].File_path, out_folder_path+"/"+lpad(fmt.Sprint(files[i].Order), "0", 5)+"-"+files[i].File_name)
	}
}

func analyze(folder_path string, comments_regexp string, delimiters_regexp string) []reader.File_info {
	files := reader.Listdir_recursive(folder_path, "sql")
	possible_dependencies := get_possible_dependencies(files)

	for i := 0; i < len(files); i++ {
		fmt.Println("Scanning " + files[i].File_path)
		file_contents := reader.Read_file(files[i].File_path)
		removed_comments := analyzer.Remove_comments(file_contents, comments_regexp)
		splitted := analyzer.Split_text_multiple_delimiters(removed_comments, delimiters_regexp)
		files[i].Dependencies = analyzer.Find_dependencies(splitted, possible_dependencies, false)
		fmt.Println("Dependencies: " + "[" + strings.Join(files[i].Dependencies, ", ") + "]")
	}

	found_dependencies := make(map[string]int)
	for i := 0; i < len(possible_dependencies); i++ {
		found_dependencies[possible_dependencies[i]] = -1
	}

	files_added := 0
	cycle := 0
	for files_added != len(files) {
		files_added_this_cycle := 0
		for i := 0; i < len(files); i++ {
			found_dependencies_for_file := 0

			if files[i].Order != -1 { // skip if already found
				continue
			}

			for di := 0; di < len(files[i].Dependencies); di++ { // count found dependencies
				dependency := files[i].Dependencies[di]
				if (found_dependencies[dependency] != -1 &&
					found_dependencies[dependency] < cycle) ||
					(dependency == files[i].Object_name) {
					found_dependencies_for_file += 1
				}
			}

			if found_dependencies_for_file == len(files[i].Dependencies) { // all dependencies have been found
				files_added++
				files_added_this_cycle++
				files[i].Order = cycle
				found_dependencies[files[i].Object_name] = cycle
			}
		}

		if files_added_this_cycle == 0 {
			fmt.Println("Circular reference found, finishing")
			break
		}

		cycle++
	}

	return files
}

func lpad(text string, char string, length int) string {
	out_str := text
	for i := 0; i < (length - len(text)); i++ {
		out_str = char + out_str
	}
	return out_str
}

func get_possible_dependencies(files []reader.File_info) []string {
	possible_dependencies := make([]string, len(files))
	for i := 0; i < len(files); i++ {
		possible_dependencies[i] = files[i].Object_name
	}
	return possible_dependencies
}
