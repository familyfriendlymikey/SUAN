let p = console.log
let o = "hello world"

import { nanoid as generate_id } from 'nanoid'

let api_version = "0.06"
let state = {}

getInitialState!
loadState!

def getInitialState
	state.tasks = []
	state.adding = no
	state.viewing_complete = no
	state.add_task_text = ""
	state.view = "SCHEDULE"

def loadState
	if localStorage.hasOwnProperty(let tasks_key = get_tasks_key!)
		state.tasks = JSON.parse(localStorage[tasks_key])

def save_state
	let tasks_key = get_tasks_key!
	localStorage[tasks_key] = JSON.stringify state.tasks

def get_tasks_key
	return "tasks_" + api_version

def format_time_from_seconds s
	if s / 3600 >= 1
		return new Date(s * 1000).toISOString().substr(11, 8)
	else
		return new Date(s * 1000).toISOString().substr(14, 5)

def get_completed_tasks
	state.tasks.filter(|t| t.done)

def get_incomplete_tasks
	state.tasks.filter(|t| !t.done)

def get_tasks_list
	if state.viewing_complete
		get_completed_tasks!
	else
		get_incomplete_tasks!

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

def parse_task_text item
	let words = item.trim().split(/\s/)

	const str_is_digit = do |s|
		/^\d+$/.test(s)

	const str_is_hours = do |s|
		s.length <= 2 and parseInt(s) < 24

	const str_is_hours_and_tens = do |s|
		s.length == 3 and parseInt(s.substr(1)) < 60

	const str_is_hours_and_mins = do |s|
		s.length == 4 and parseInt(s.substr(0,2)) < 24 and parseInt(s.substr(2)) < 60

	const parse_time = do |s|
		if !str_is_digit s
			return false
		if str_is_hours s
			return s + ":00"
		elif str_is_hours_and_tens s
			return s[0] + ":" + s.substr(1)
		elif str_is_hours_and_mins s
			return s.substr(0,2) + ":" + s.substr(2)
		else
			return false

	const parse_duration = do |s|
		if !str_is_digit s
			return false
		if str_is_hours s
			return parseInt(s) * 3600
		elif str_is_hours_and_tens s
			p s
			return (parseInt(s[0]) * 3600) + (parseInt(s.substr(1)) * 60)
		elif str_is_hours_and_mins s
			return (parseInt(s.substr(0,2)) * 3600) + (parseInt(s.substr(2) * 60))
		else
			return false

	let task = {done:false, active_duration:0, start_time:null}
	let desc
	let time
	let duration
	
	if (task.time = parse_time words[0]) and (task.duration = parse_duration words[1])
		task.desc = words.slice(2).join(" ")
	elif (task.time = parse_time(words[0]))
		task.desc = words.slice(1).join(" ")
	else
		task.time = "0:00"
		task.desc = words.join(" ")
	
	task

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
	bg:blue1
	d:flex
	fld:column
	jc:center
	ai:center

global css .bottom-button
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


tag Options

	def reset
		getInitialState!

	def render
		<self[w:100% h:100% d:flex fld:column jc:space-between ai:center]>
			<div[d:flex fld:column jc:flex-start ai:center w:100% mt:20px]>
				css div w:85% bg:blue2 d:flex fld:row jc:center ai:center p:20px mb:20px rd:20px c:blue5 fs:20px cursor:pointer
				<div@click=reset> "RESET APP"
				<div@click=window.location.reload(true)> "UPDATE"
			<div[w:100%]>
				<div.bottom-button@click=state.view="SCHEDULE">
					css div d:flex fl:1 fld:row jc:center ai:center h:100%
					<div@click=view_options> <svg src='./assets/home.svg'>


tag Schedule
	
	def view_options
		state.view = "OPTIONS"

	def get_total_active_time
		let total = 0
		for item of state.tasks
			total += item.active_duration
		parseInt(total/1000)

	def render
		let tasks = get_tasks_list!
		<self[w:100% h:100% d:flex fld:column jc:space-between ai:center]>
			<div[
				fl:1
				d:flex
				fld:column
				jc:flex-start
				ai:center
				w:100%
				bg:{tasks.length == 0 ? "cyan2" : "none"}
				overflow-y:scroll
				transition:background-color 700ms
			]>
				if tasks.length > 0
					<div [w:100% box-sizing:border-box px:10px pt:10px]> for item in tasks
						<Task data=item $key=item.id>
			<div[w:100%]>
				<div[bg:cyan2 c:blue5 d:flex fld:row jc:center w:100% h:30px ai:center]> format_time_from_seconds(get_total_active_time!)
				<div.bottom-button>
					css div d:flex fl:1 fld:row jc:center ai:center h:100%
					<div@click=view_options> <svg src='./assets/settings.svg'>
					<div@click=state.viewing_complete=!state.viewing_complete>
						if state.viewing_complete
							<svg src='./assets/x.svg'>
						else
							<svg src='./assets/check.svg'>
					<div@click=state.adding=!state.adding> <svg src='./assets/plus.svg'>


tag AddTaskPage

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
		state.add_task_text = ""
		state.adding = !state.adding
	
	def focus_and_select
		$add_task_input.focus!
		$add_task_input.select!

	def render
		<self@click=focus_and_select [d:flex fl:1 fld:column jc:center ai:center]>
			<form @submit.prevent=handle_add>
				<input$add_task_input [w:100% h:50px fs:25px p:10px] placeholder="[0-2359] [0-2359] [description]" bind=state.add_task_text>


tag Task

	prop timeout

	def clear_timeout
		clearTimeout(timeout)
		timeout = null

	def deactivate_task
		data.active_duration += Date.now! - data.start_time
		data.start_time = null

	def handle_long_press
		clear_timeout!
		if data.done
			delete_task!
			imba.commit!
		else
			data.done = true
			imba.commit!
			if data.start_time
				deactivate_task!

	def handle_task_pointerdown
		p "pointerdown"
		timeout = setTimeout(handle_long_press.bind(self), 600)

	def handle_task_pointercancel
		p "pointercancel"
		clear_timeout!
	
	def delete_task
		state.tasks = state.tasks.filter(do |t| t.id != data.id)

	def handle_task_pointerup
		p "pointerup"
		if timeout
			clear_timeout!
			if data.done
				data.done = no
			elif data.start_time
				deactivate_task!
			else
				data.start_time = Date.now!
	
	def get_middle_bg
		if timeout
			"cyan1"
		elif data.done
			"cyan3"
		else
			if data.start_time
				"blue4"
			else
				"blue2"

	def get_side_bg
		if timeout
			"cyan1"
		elif data.done
			"cyan3"
		else
			"blue4"
	
	def get_pink_bg
		let active_task_duration = get_task_active_duration!
		if data.duration > 0
			p active_task_duration / data.duration

	def get_task_active_duration
		if data.start_time
			return parseInt(data.active_duration/1000 + (Date.now! - data.start_time)/1000)
		else
			return parseInt(data.active_duration/1000)

	def render
		let bg = get_middle_bg!
		let { desc, time, duration, done, active_duration } = data
		let rd = 5px
		get_pink_bg!
		css .task@active transform:scale(0.97) transition:transform 25ms
		<self.task[ d:flex h:70px flex:1 fld:row jc:space-between pb:10px ]
			@pointerdown=handle_task_pointerdown
			@pointercancel=handle_task_pointercancel
			@pointerleave=handle_task_pointercancel
			@pointerup=handle_task_pointerup
			autorender=1fps
		>
			css div bg:{bg} transition:background-color 300ms
			css .middle px:7px py:2px w:100% d:flex fld:row jc:flex-start ai:center cursor:pointer
			css .side d:flex fld:column jc:center ta:center bg:{get_side_bg!}
			css .left rdl:{rd} min-width:50px
			css .right rdr:{rd} min-width:85px
			<div.side.left> time
			<div.middle> desc
			let active_task_duration = get_task_active_duration!
			if duration && duration > active_task_duration
				<div.side.right[bg:pink3]> "-" + format_time_from_seconds(duration - active_task_duration)
			elif duration
				<div.side.right[bg:green3]> "+" + format_time_from_seconds(Math.abs(duration - active_task_duration))
			else
				<div.side.right> "+" + format_time_from_seconds(active_task_duration)


tag App

	def render
		save_state!
		<self [d:flex fld:column h:100% max-width:500px w:100%]>
			if state.adding
				<AddTaskPage>
			else
				if state.view == "OPTIONS"
					<Options>
				else
					<Schedule>

imba.mount <App>
