# Schedule
[HOST](https://familyfriendlymikey.github.io/schedule)

## What
I thought it might be an interesting practice to write out everything I do in a spreadsheet every single day,
but that would take too much time and effort for something I don't even know will benefit my life in the first place.
Instead, every night I started writing out a to-do list for the next day,
which worked well but also felt a little lacking.

I wanted something that would:

### Log all completions
- Log every user interaction in the app, store it locally (window.localStorage), and be able to view analytics of this information or export it in some data format.
- Be able to quickly "start" and "pause/stop" a task, before ultimately marking it as done, where the entire active duration of the task gets logged.
- For the analytics to actually be able to show correlations,
adding a task may have to bring up a fuzzy filtered list of all previous tasks so you can select the same exact one (with the same exact ID?),
or use some sort of tagging system.

I am not sure if this will be useful, but I would rather try than not.
At the very least it could be like github's contribution section that shows a green box for each day you have pushed a commit,
but filterable to certain tasks or viewable as a graph to show progress or correlations.

### Display Accumulated Time
- Show an accumulation of how much time is being allocated to tasks and how much free time I have (left?).

### Shift Tasks In Time
- If operating on a delay,
perhaps shift tasks marked as `dynamic` later in the day,
and show a task as red or green depending on the average time I finish that exact task compared to the current time.
This may get annoying, we'll see.

### Timer Support
- Perhaps allow for intermittent timers,
so that sort of activity will be automatically logged.
For example,
if you work from home using a pomodoro timer,
you could just do it in the app,
and it would automatically log the current time and time spent on that task for analytics later.
- If not, at the very least, allow users to start and stop tasks as mentioned, but have the active time subtracted from the task's duration if there is one,
and once the duration is through, show a "+" and the extra time spent on that task.
For tasks that don't have a duration, simply show the "+" and the time spent on that task.

## Long Term

### View Analytics
Logging is easy, so that can be implemented immediately, but actually viewing analytics, showing averages, displaying graphs will take more work.

### Templates
Something like
```
8:00 wake up
8:10 shower
8:20 brush teeth, drink water
...
0:00 go to bed
```
should be possible to import automatically.
