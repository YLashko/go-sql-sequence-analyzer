## Go sql sequence analyzer

This program analyzes all the files in provided directory to find dependencies inside them and outputs the sequence in which these files should be executed to satisfy all the dependencies. It's main purpose is for SQL, where objects that have not been created yet but are present in a file could cause some pain.
