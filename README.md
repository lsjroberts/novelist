# Novelist

A writer's integrated story-telling environment


## State

```
welcome
wizard
editor
    open
    active
    project
        name
        manuscript
            scenes
                tokens
        plan ( StoryGrid | Snowflake | Free )
        notes
            files
                files
```

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
