let p = console.log
let o = "hello world"

import { nanoid as generate_id } from 'nanoid'

let state = {}

def getInitialState
	state.tasks = []
	state.adding = no
	state.viewing_complete = no
	state.add_task_text = ""
	state.view = "SCHEDULE"

def loadState
	try
		state.tasks = JSON.parse(window.localStorage._ffm_tasks)
	catch
		window.localStorage._ffm_backup = window.localStorage._ffm_tasks

getInitialState!
loadState!

global css @root
	ff: 'Open Sans', sans-serif
	-webkit-touch-callout:none
	-webkit-user-select:none
	-moz-user-select:none
	user-select:none

css .bottom-button
	bg:cyan1 bdt:3px solid sky2
	h:70px pos:fixed b:0 l:0 r:0
	d:flex fld:row jc:center ai:center
	fs:20px c:blue5 zi:1000 cursor:pointer
	pb:30px ta:center
	px:10px
	user-select:none

def save_data
	window.localStorage._ffm_tasks = JSON.stringify state.tasks

def parse_task_text item
	let words = item.trim().split(/\s/)

	const is_duration? = do |duration| (/^\d+[hms]$/).test(duration)

	def parse_time time
		unless /^\d+$/.test(time)
			return false
		if time.length <= 2 and parseInt(time) < 24
			return time + ":00"
		elif time.length == 3 and parseInt(time.substr(1)) < 60
			return time[0] + ":" + time.substr(1)
		elif time.length == 4 and parseInt(time.substr(0,2)) < 24 and parseInt(time.substr(2)) < 60
			return time.substr(0,2) + ":" + time.substr(2)
		else
			return false

	let task = {done:false, active_duration:0}
	let desc
	let time
	let duration

	if (time = parse_time words[0]) and (is_duration? words[1])
		task.duration = words[1]
		task.desc = words.slice(2).join(" ")
	elif time = parse_time(words[0])
		task.desc = words.slice(1).join(" ")
	elif is_duration? words[0]
		task.duration = words[0]
		task.desc = words.slice(1).join(" ")
		task.time = "0:00"
	else
		task.time = "0:00"
		task.desc = words.join(" ")
	
	task

tag Options

	def reset
		getInitialState!

	def render
		<self[d:flex fld:column jc:center ai:center]>
			css div fl:1 w:90% bg:blue1 d:flex fld:row jc:center ai:center p:20px mb:10px
			<div@click=state.view="SCHEDULE"> "HOME"
			<div@click=reset> "RESET APP"


tag Schedule

	def get_tasks_list
		if state.viewing_complete
			state.tasks.filter(|t| t.done)
		else
			state.tasks.filter(|t| !t.done)
	
	def view_options
		state.view = "OPTIONS"

	def get_total_active_time
		let total = 0
		for item of state.tasks
			total += item.active_duration
		parseInt(total/1000)

	def render
		<self[w:100% d:flex fld:column jc:center ai:center]>
			if (let tasks = get_tasks_list!).length > 0
				<div [w:100%]> for item in tasks
					<Task data=item $key=item.id>
			else
				<h1> "Add A Task Below"
			<div[pos:fixed bottom:100px h:70px d:flex fld:row jc:flex-end w:90% ai:center]> "ACTIVE TIME: " + get_total_active_time!
			<div.bottom-button>
				css div d:flex fl:1 fld:row jc:center ai:center h:100%
				<div@click=view_options> "OPTIONS"
				<div@click=state.viewing_complete=!state.viewing_complete> state.viewing_complete ? "VIEW INCOMPLETE" : "VIEW COMPLETE"
				<div@click=state.adding=!state.adding> "ADD"

tag AddTaskPage
	def cmp_time item1, item2
		let time1 = item1.time.split(":")
		let time2 = item2.time.split(":")
		let hours1 = parseInt time1[0]
		let mins1 = parseInt time1[1]
		let hours2 = parseInt time2[0]
		let mins2 = parseInt time2[1]
		if hours1 > hours2
			return true
		elif hours1 < hours2
			return false
		else
			if mins1 > mins2
				return true
			elif mins1 < mins2
				return false
			else
				return false

	def insert_task task_to_insert
		for task, index in state.tasks
			if cmp_time(task, task_to_insert)
				state.tasks.splice(index, 0, task_to_insert)
				return
		state.tasks.splice(state.tasks.length, 0, task_to_insert)

	def tasks_are_same? task1, task2
		for own key of task1
			if task1[key] != task2[key]
				return false
		return true

	def handle_add
		if !state.add_task_text
			state.adding = !state.adding
			return
		let task = parse_task_text state.add_task_text
		if state.tasks.length < 1 || !tasks_are_same? task, state.tasks[0]
			task.id = generate_id!
			insert_task task
			save_data!
		state.add_task_text = ""
		state.adding = !state.adding

	def render
		<self>
			<input[w:100% h:50px fs:25px p:10px] placeholder="[0-2359] [1h, 30m, 10s] [description]" bind=state.add_task_text>
			<div.bottom-button@click=handle_add> "DONE"

tag Task

	prop timeout
	prop animating = no
	prop active = no
	prop start_time

	def handle_task_pointerdown
		def mark_done
			state.tasks[state.tasks.indexOf data].done = !state.tasks[state.tasks.indexOf data].done
			animating = no
			imba.commit!
			if active and start_time
				data.active_duration += new Date() - start_time
				p data.active_duration
				active = false
				start_time = null
			save_data!

		animating = true
		timeout = setTimeout(mark_done, 600)

	def handle_task_pointerup
		animating = no
		clearTimeout(timeout)

	def handle_task_click
		if data.done
			return
		if active and start_time
			data.active_duration += new Date() - start_time
			p data.active_duration
			active = false
			start_time = null
		elif !active and !start_time
			start_time = new Date()
			active = true
	
	def get_middle_bg
		if animating
			"cyan1"
		else
			if active
				"blue5"
			else
				"blue1"

	def get_side_bg
		if animating
			"cyan1"
		else
			if active
				"blue4"
			else
				"blue2"

	def render
		let bg = get_middle_bg!
		let { desc, time, duration, done, active_duration } = data
		rd = 5px
		<self[
			d:flex h:70px flex:1 fld:row jc:space-between pb:10px
		]
			@pointerdown=handle_task_pointerdown
			@pointerup=handle_task_pointerup
			@click=handle_task_click
			autorender=1fps
		>
			css div
				bg:{bg}
				transition:background-color 600ms
			css .middle
				px:7px py:2px w:100%
				d:flex fld:row jc:flex-start ai:center
				cursor:pointer user-select:none user-select:none
				text-decoration:{done ? "line-through" : "none"}
			css .side
				d:flex
				fld:column
				jc:center
				min-width:50px
				ta:center
				bg:{get_side_bg!}
			css .left rdl:{rd}
			css .right rdr:{rd}
			<div.side.left> time
			<div.middle> desc
			if duration
				<div.side.right> duration
			else
				if start_time
					<div.side.right> parseInt(data.active_duration/1000 + (Date.now! - start_time)/1000)
				else
					<div.side.right> parseInt(data.active_duration/1000)

tag App
	def render
		<self [d:flex fld:column mb:70px]>
			if state.adding
				<AddTaskPage>
			else
				if state.view == "OPTIONS"
					<Options>
				else
					<Schedule>

imba.mount <App>
