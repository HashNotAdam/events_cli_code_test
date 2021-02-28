# README
### Overview
There is an events company called Mad Events that specializes in virtual conferencing.
They have tasked you with building an application that will allow clients to set up events with the following requirements:
- Clients can create an event
- An event can include any number of talks
- A talk must have 1 speaker
- A talk must have a start and end time
- Talk times cannot overlap; they must be in sequential order. For example; a client cannot add a talk from 10am to 10:30am when a talk from 9:30am to 10:30am already exists in the event
### Task
Build a CLI program that meets the above requirements and will accept the following commands:
- CREATE EVENT event_name
- CREATE SPEAKER speaker_name
- CREATE TALK event_name talk_name talk_start_time talk_end_time speaker_name
- PRINT TALKS event_name => output the talks for an event sorted by the start time
### Example
`CREATE EVENT an_event`
`CREATE SPEAKER John`
`CREATE TALK an_event 'My Talk' 9:00am 10:00am John`
`CREATE EVENT new_event`
`CREATE SPEAKER Sam`
`CREATE TALK new_event 'hello world' 2:00pm 2:30pm Sam`
`CREATE SPEAKER Bob`
`CREATE TALK an_event 'code challenges' 2:00pm 2:30pm Bob`
`CREATE SPEAKER Ben`
`CREATE TALK an_event 'Joint Talk' 10:30am 12:00am Ben`
`PRINT TALKS an_event`
```
9:00am - 10:00am
  My First Talk presented by John
10:30am - 12:00am
  Joint Talk presented by Ben
2:00pm - 2:30pm
  code challenges presented by Bob
```
`PRINT TALKS new_event`
```
2:00pm - 2:30pm
  hello world presented by Sam
```
### Notes
- use Ruby
- try not to spend more than 2 hours maximum
- there is no need for any GUIs; we're more interested in your approach to solving the given task, not how fancy you can make it look
- don't use any frameworks (rails, spring etc), or any external jars/gems (unless it's for testing or build/dependency mgt)
When you've finished, send through the link to your github-repo.
Happy coding!!!
