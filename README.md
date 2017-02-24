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
    project.nvlj
        {
            "name": "Project",
            "manuscript": {
                "sha10001": {
                    "sha10003.txt": true,
                },
                "sha10002.txt": true,
            },
        }
    manuscript/
        sha10001.txt
        sha10002.txt
        sha10003.txt
    plan/
    notes/
```
