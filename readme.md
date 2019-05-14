# Small Powershell housekeeping tool
## Introduction

In `clean.config.xml` you can specify file paths that should be cleaned depending on the age of the files.
There's also an option to include subfolders or not.
Note that this tool does not remove folders.

The user or task running this script should have access to all the files.

After running the script a `clean.log` file will be created with logs of the last run.
Note that the log file will be removed at the beginning of every run.

## How to schedule a Powershell script
1. Create a new task in the Task Scheduler
2. Select an admin user to execute the task
3. Select "Run whether user is logged on or not"
4. Set the trigger (e.g.: every day at 0:00)
5. Create an action:
	- Program: `Powershell.exe`
	- Add arguments: `-ExecutionPolicy Bypass F:\Housekeeping\clean.ps1`
		* Path depends on where the script is located


Reference: https://community.spiceworks.com/how_to/17736-run-powershell-scripts-from-task-scheduler