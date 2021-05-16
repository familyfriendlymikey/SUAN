let p = console.log
let o = "hello world"

import { nanoid as generate_id } from 'nanoid'

let tasks
try
	tasks = JSON.parse(window.localStorage._ffm_tasks)
catch
	window.localStorage._ffm_backup = window.localStorage._ffm_tasks
	tasks = [{desc:"Add a task below.", time:"13:00", duration:"1h", id:generate_id!}]
let adding = no
let viewing_complete = no
let add_task_text = ""

css .bottom-button
	bg:cyan1 ff:arial bdt:3px solid sky2
	h:70px pos:fixed b:0 l:0 r:0
	d:flex fld:row jc:center ai:center
	fs:20px c:blue5 zi:1000 cursor:pointer
	user-select:none

def save_data
	window.localStorage._ffm_tasks = JSON.stringify tasks

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

	let time
	let duration
	let desc
	let done = false
	if (time = parse_time words[0]) and (is_duration? words[1])
		duration = words[1]
		desc = words.slice(2).join(" ")
		return {time, duration, desc, done}
	elif time = parse_time(words[0])
		desc = words.slice(1).join(" ")
		return {time, desc, done}
	elif is_duration? words[0]
		duration = words[0]
		desc = words.slice(1).join(" ")
		time = "0:00"
		return {time, duration, desc, done}
	else
		time = "0:00"
		desc = words.join(" ")
		return {time, desc, done}

tag Schedule

	def get_tasks_list
		if viewing_complete
			tasks.filter(|t| t.done)
		else
			tasks.filter(|t| !t.done)

	def reset
		tasks = [{desc:"Add a task below.", time:"13:00", duration:"1h", id:generate_id!}]
		window.localStorage._ffm_tasks = tasks

	def render
		<self[w:100%]>
			<div> for item in get_tasks_list!
				<Task data=item $key=item.id>
			<div.bottom-button>
				css div d:flex fl:1 fld:row jc:center ai:center h:100%
				<div@click=viewing_complete=!viewing_complete> viewing_complete ? "VIEW INCOMPLETE" : "VIEW COMPLETE"
				if viewing_complete
					<div@click=reset> "RESET"
				else
					<div@click=adding=!adding> "ADD"

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
		for task, index in tasks
			if cmp_time(task, task_to_insert)
				tasks.splice(index, 0, task_to_insert)
				return
		tasks.splice(tasks.length, 0, task_to_insert)

	def tasks_are_same? task1, task2
		for own key of task1
			if task1[key] != task2[key]
				return false
		return true

	def handle_add
		if !add_task_text
			adding = !adding
			return
		let task = parse_task_text add_task_text
		if !tasks_are_same? task, tasks[0]
			task.id = generate_id!
			insert_task task
			save_data!
		add_task_text = ""
		adding = !adding

	def render
		<self>
			<input[w:100% h:50px fs:25px p:10px] placeholder="[0-2359] [1h, 30m, 10s] [description]" bind=add_task_text>
			<div.bottom-button@click=handle_add> "DONE"

tag Task

	prop timeout
	prop animating = no

	def handle_task_pointerdown
		def mark_done
			tasks[tasks.indexOf data].done = !tasks[tasks.indexOf data].done
			animating = no
			imba.commit!
			save_data!
		animating = true
		timeout = setTimeout(mark_done, 600)

	def handle_task_pointerup
		animating = no
		clearTimeout(timeout)

	def handle_task_click
		p "EDIT_TASK"

	def render
		let { desc, time, duration, done } = data
		rd = 5px
		<self[
			d:flex h:70px w:100% fld:row jc:space-between pb:10px
		]
			@pointerdown=handle_task_pointerdown
			@pointerup=handle_task_pointerup
			@click=handle_task_click
		>
			css div
				bg:{animating ? "cyan1" : "blue1"}
				transition:background-color 600ms
			css .middle
				px:7px py:2px w:100%
				d:flex fld:row jc:flex-start ai:center
				cursor:pointer user-select:none user-select:none
			css .side
				d:flex
				fld:column
				jc:center
				min-width:50px
				ta:center
				bg:{animating ? "cyan1" : "blue2"}
			css .left rdl:{rd}
			css .right rdr:{rd}
			<div.side.left> time
			if time and duration
				<div.middle> desc
			elif duration
				<div.middle[rdl:{rd}]> desc
			else
				<div.middle[rdr:{rd}]> desc
			if duration
				<div.side.right> duration

tag App
	def render
		<self [d:flex fld:column mb:70px]>
			if adding
				<AddTaskPage>
			else
				<Schedule>

imba.mount <App>
