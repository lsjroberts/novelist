# Novelist

The writer's story-telling environment.


## State

```
app : Novelist
    editor : Editor

Editor
    project : Project

Project
    name : String
    path : String
    manuscript : Manuscript
    notes : Notes
    plans : List ( StoryGrid | Snowflake | Free )
    history : List Actions

Manuscript : List File

File
    name : String
    path : String
    children : FileChildren -- List File
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
