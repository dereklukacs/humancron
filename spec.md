## Background
1. A lot of knowledge worker tasks are recurring and repetitive.
2. **Spiky** A lot of the value of these tasks are not in getting them done, but in the *doing*
3. Getting through these things is best done in a batched manner
4. Going through these chores is a great way of building momentum
5. One of the goals is to quickly go and gather information from the source in order to load the context into the users mental RAM.
6. The biggest challenge to going through these steps is staying on task

## The Application
A desktop application, primarily for Mac OS.

It's purpose is as the user's execution guide or preflight checklist. It is not exactly a todolist, but more of a set of SOPs / routines that the user seeks to execute as efficiently as possible. The app provides automations and workflows to keep the user in flow. 

These automations include:
- Automatic Application and Link opening
- Configurable n8n automations

## User stories

Derek is beginning his work day and has a variety of tasks to complete. One of his humancron workflows called "inbox cleanse" consists of the following steps:
- Check calendar
- Review slack messages
- Clean email, leaving only important emails
- Review github PRs
- Review linear inbox

Derek launches the app with option+spacebar

Derek selects an sop using the arrow keys then presses enter. On pressing enter the SOP gets started

On pressing enter he launches into the first task which is "check calendar". This step is configured with a link: notion-calendar:// which launches the notion calendar app locally. 

After reviewing the calendar he presses option+space again to pull up the humancron app. He sees the current task: "review calendar" and the next task "review slack messages". He can press "enter" to move to the next task or command+enter to move to the next task and trigger the next automation.


## Other must haves
- Workflows are encoded in yml and stored in a centralized place for VCS support
- Systray indicator for the current SOP
- SOPs reset when they are finished. Each SOP is ephemeral.
- A way to trigger n8n tasks (and presumably also authenticate with n8n)

## Nice to haves
- a way of skipping /come back later on steps
- prelaunch apps for faster loading? I.e. At the beginning of the SOP launch all of the links, then when you get to the step the app is already open.

## Out of scope / won't do:
- keeping stats



## Tech stack
Primary: SwiftUI


## North star design principles
- Built for speed
- Hotkeys for everything
- Focused design to stay in flow
- local + plain files first

## Inspiration apps:
- Raycast
- cron (notion calendar)
- superhuman

## Screens:
- systray: shows the current active step
- routine selector







