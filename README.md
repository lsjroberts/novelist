# Novelist

The writer's story-telling environment.


## State

```
Model
    Ui
        Binder
            List File
        Workspace
        Maybe File
    Novel
        List Scene
            Name
            Content
                List Token
            History
                List (List Token)
```


## Views

```
Frame
    Editor
        Menu
        Panel
            Binder
                Manuscript
                Plan
                Notes
                Characters
                Locations
        Workspace
            Header
                Title
                Author
            Scene
                Heading
                Content
        Panel
            Scene Meta
                Characters
                Locations
                Plan
        Footer
            Statistics
            Targets
```


## Project File

```
project.nvl/
    .git/
    project.json
        {
            "name": "Project",
            "author": "Author",
            "files": [
                {
                    id: "sha10001",
                    parent: null,
                    fileType: "scene",
                    name: "Chapter One"
                }
            ],
        }
    sha10001.txt
    sha10002.txt
    sha10003.txt
```
