## Go sql sequence analyzer

This program analyzes all the files in provided directory to find dependencies inside them and outputs the sequence in which these files should be executed to satisfy all the dependencies. It's main purpose is for SQL, where objects that have not been created yet but are present in a file could cause some pain.
There are still a lot of things in ToDo: it hasn't been tested properly, config.json is nonexistent yet... but at least it works on my sql statements project :)
