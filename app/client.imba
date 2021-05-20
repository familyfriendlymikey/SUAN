let p = console.log
let o = "hello world"

import { nanoid as generate_id } from 'nanoid'

let api_version = "0.01"
let state = {}

def getInitialState
	state.tasks = []
	state.adding = no
	state.viewing_complete = no
	state.add_task_text = ""
	state.view = "SCHEDULE"

def get_tasks_key
	return "tasks_" + api_version

def loadState
	if localStorage.hasOwnProperty(let tasks_key = get_tasks_key!)
		state.tasks = JSON.parse(localStorage[tasks_key])

def save_state
	let tasks_key = get_tasks_key!
	localStorage[tasks_key] = JSON.stringify state.tasks

def format_time_from_seconds s
	if s / 3600 >= 1
		return new Date(s * 1000).toISOString().substr(11, 8)
	else
		return new Date(s * 1000).toISOString().substr(14, 5)

getInitialState!
loadState!

global css @root
	ff: 'Open Sans', sans-serif
	-webkit-touch-callout:none
	-webkit-user-select:none
	-moz-user-select:none
	user-select:none

global css body
	m:0
	pos:fixed
	left:0
	right:0
	bottom:0
	top:0

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

	if (task.time = parse_time words[0]) and (is_duration? words[1])
		task.duration = words[1]
		task.desc = words.slice(2).join(" ")
	elif task.time = parse_time(words[0])
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
			<div@click=window.location.reload(true)> "UPDATE"


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
		<self[w:100% h:100% d:flex fld:column jc:space-between ai:center]>
			css .bottom-button
				bg:cyan1
				c:blue5
				h:100px b:0 l:0 r:0
				w:100%
				box-sizing:border-box
				d:flex fld:row jc:center ai:center
				fs:20px cursor:pointer
				pb:30px ta:center
				px:10px
				user-select:none
			if (let tasks = get_tasks_list!).length > 0
				<div [w:100% box-sizing:border-box px:10px pt:10px overflow-y:scroll]> for item in tasks
					<Task data=item $key=item.id>
			else
				<h1> "Add A Task Below"
			<div[w:100%]>
				<div[bg:cyan2 c:blue5 d:flex fld:row jc:center w:100% h:30px ai:center]> format_time_from_seconds(get_total_active_time!)
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
			save_state!
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
		p "pointerdown"
		def mark_done
			state.tasks[state.tasks.indexOf data].done = !state.tasks[state.tasks.indexOf data].done
			animating = no
			imba.commit!
			if active and start_time
				data.active_duration += new Date() - start_time
				p data.active_duration
				active = false
				start_time = null
			save_state!

		animating = true
		timeout = setTimeout(mark_done, 600)

	def handle_task_pointercancel
		p "pointercancel"
		animating = no
		clearTimeout(timeout)

	def handle_task_click
		p "click"
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
		elif data.done
			"cyan3"
		else
			if active
				"blue5"
			else
				"blue1"

	def get_side_bg
		if animating
			"cyan1"
		elif data.done
			"cyan3"
		else
			if active
				"blue4"
			else
				"blue2"

	def get_task_active_duration
		if start_time
			return parseInt(data.active_duration/1000 + (Date.now! - start_time)/1000)
		else
			return parseInt(data.active_duration/1000)

	def render
		let bg = get_middle_bg!
		let { desc, time, duration, done, active_duration } = data
		rd = 5px
		<self[
			d:flex h:70px flex:1 fld:row jc:space-between pb:10px
		]
			@pointerdown=handle_task_pointerdown
			@pointercancel=handle_task_pointercancel
			@pointerup=handle_task_pointercancel
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
			css .side
				d:flex
				fld:column
				jc:center
				ta:center
				bg:{get_side_bg!}
			css .left
				rdl:{rd}
				min-width:50px
			css .right
				rdr:{rd}
				min-width:85px
			<div.side.left> time
			<div.middle> desc
			if duration
				<div.side.right> duration
			else
				<div.side.right> "+" + format_time_from_seconds(get_task_active_duration!)

tag App
	def render
		<self [d:flex fld:column h:100%]>
			if state.adding
				<AddTaskPage>
			else
				if state.view == "OPTIONS"
					<Options>
				else
					<Schedule>

imba.mount <App>
