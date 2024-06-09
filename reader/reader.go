package reader

import (
	"bytes"
	"io"
	"os"
	"strings"
)

type File_info struct {
	File_name    string
	File_path    string
	Object_name  string
	Dependencies []string
	Order        int
}

func Read_file(filename string) string {
	fi, err := os.Open(filename)
	if err != nil {
		panic(err)
	}

	defer func() {
		err := fi.Close()
		if err != nil {
			panic(err)
		}
	}()

	buf := bytes.NewBuffer(nil)
	io.Copy(buf, fi)

	return buf.String()
}

func Empty_dir(dir_path string) {
	dir, err := os.Open(dir_path)
	if err != nil {
		panic(err)
	}

	dir_perm, err := dir.Stat()
	if err != nil {
		panic(err)
	}

	os.RemoveAll(dir_path)

	err = os.MkdirAll(dir_path, dir_perm.Mode())
	if err != nil {
		panic(err)
	}
}

func Copy_file(from_path string, to_path string) {
	from_file, err := os.Open(from_path)
	if err != nil {
		panic(err)
	}
	defer from_file.Close()

	from_file_perm, err := from_file.Stat()
	if err != nil {
		panic(err)
	}

	to_file, err := os.Create(to_path)
	if err != nil {
		panic(err)
	}
	defer to_file.Close()

	os.Chmod(to_path, from_file_perm.Mode())

	_, err = io.Copy(to_file, from_file)
	if err != nil {
		panic(err)
	}
}

func Listdir_recursive(dir_path string, filter_type string) []File_info {
	files, err := os.ReadDir(dir_path)
	local_files := make([]File_info, 0)

	if err != nil {
		panic(err)
	}

	for c := 0; c < len(files); c++ {
		file := files[c]
		name_split := strings.Split(file.Name(), ".")

		var file_name, file_type string
		if len(name_split) >= 2 {
			file_name, file_type = name_split[len(name_split)-2], name_split[len(name_split)-1]
		} else {
			file_name, file_type = file.Name(), ""
		}

		if file.IsDir() {
			local_files = append(local_files, Listdir_recursive(dir_path+"/"+file.Name(), filter_type)...)
		} else if strings.EqualFold(file_type, filter_type) {
			local_files = append(local_files, File_info{
				file.Name(),
				dir_path + "/" + file.Name(),
				strings.ToLower(file_name),
				make([]string, 0),
				-1,
			})
		}
	}

	return local_files
}
