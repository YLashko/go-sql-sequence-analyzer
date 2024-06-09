package analyzer

import (
	"regexp"
	"sort"
	"strings"
)

// replace all regexp occurencies with a [space] (to prevent strings sticking to each other)
func Remove_comments(text string, regexp_expr string) string {
	regexp_pattern, err := regexp.Compile(regexp_expr)
	if err != nil {
		panic(err)
	}
	return regexp_pattern.ReplaceAllString(text, " ")
}

// split text into an array of strings based on multiple delimiters; UTF-8 ready (should be)
func Split_text_multiple_delimiters(text string, delimiters_regex string) []string {

	regexp_pattern, err := regexp.Compile(delimiters_regex)
	if err != nil {
		panic(err)
	}
	return strings.Split(regexp_pattern.ReplaceAllString(text, " "), " ")
}

// find text occurencies in an array of strings
func Find_dependencies(splitted_text []string, objects []string, case_sensitive bool) []string {
	sorted_objects := make([]string, len(objects))

	if !case_sensitive { // if case insensitive, set to lowercase
		for i := 0; i < len(objects); i++ {
			sorted_objects[i] = strings.ToLower(objects[i])
		}
	} else {
		copy(sorted_objects, objects)
	}

	sort.Strings(sorted_objects) // sort objects to search using binary search

	// each element in this array mirrors the sorted_objects, indicating if [splitted_text] contains dependency
	dependencies_is_found := make([]bool, len(objects))
	var found_dependency_index int
	for i := 0; i < len(splitted_text); i++ {
		if case_sensitive {
			found_dependency_index = get_dependency_index(splitted_text[i], sorted_objects)
		} else {
			found_dependency_index = get_dependency_index(strings.ToLower(splitted_text[i]), sorted_objects)
		}

		if found_dependency_index != -1 {
			dependencies_is_found[found_dependency_index] = true
		}
	}

	// count found dependencies
	found_dependencies_count := 0
	for i := 0; i < len(dependencies_is_found); i++ {
		if dependencies_is_found[i] {
			found_dependencies_count++
		}
	}

	// and put them into the return array
	found_dependencies := make([]string, found_dependencies_count)
	found_dependency_index = 0
	for i := 0; i < len(dependencies_is_found); i++ {
		if dependencies_is_found[i] {
			found_dependencies[found_dependency_index] = sorted_objects[i]
			found_dependency_index++
		}
	}

	return found_dependencies
}

func get_dependency_index(text string, objects []string) int {
	if len(text) == 0 {
		return -1
	}

	index, found := sort.Find(len(objects), func(i int) int {
		return strings.Compare(text, objects[i])
	})

	if found {
		return index
	} else {
		return -1
	}
}
