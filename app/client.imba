let p = console.log
let o = "hello world"

let tasks = [{desc:"do it!", time:"13:00", duration:"1h"}]
let adding = false
let add_task_text = ""

css .bottom-button
	bg:cyan1 ff:arial bdt:3px solid sky2
	h:70px pos:fixed b:0 l:0 r:0
	d:flex fld:row jc:center ai:center
	fs:20px c:blue5 zi:1000 cursor:pointer
	user-select:none

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
	if (time = parse_time words[0]) and (is_duration? words[1])
		duration = words[1]
		desc = words.slice(2).join(" ")
		return {time, duration, desc}
	elif time = parse_time(words[0])
		desc = words.slice(1).join(" ")
		return {time, desc}
	elif is_duration? words[0]
		duration = words[0]
		desc = words.slice(1).join(" ")
		time = "0:00"
		return {time, duration, desc}
	else
		time = "0:00"
		desc = words.join(" ")
		return {time, desc}

tag Schedule
	def render
		<self[w:100%]>
			<div> for item in tasks
				<Task data=item>
			<div.bottom-button@click=adding=!adding> "ADD"

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

	def handle_add
		if !add_task_text
			return
		let task = parse_task_text add_task_text
		insert_task task
		add_task_text = ""
		adding = !adding

	def render
		<self>
			<input[w:100% h:50px fs:25px p:10px] bind=add_task_text>
			<div.bottom-button@click=handle_add> "DONE"

tag Task
	def render
		let { desc, time, duration } = data
		rd = 5px
		<self[d:flex h:70px w:100% fld:row jc:space-between pb:10px]
		@mousedown=handle_task_click(id)>
			css .middle
				px:7px py:2px w:100%
				bg:{done ? "cyan1" : "blue1"}
				transform:{done ? "scale(0.97)" : "none"}
				text-decoration:{done ? "line-through" : "none"}
				transition:transform 250ms
				d:flex fld:row jc:flex-start ai:center
				cursor:pointer user-select:none user-select:none
			css .side d:flex fld:column jc:center min-width:50px ta:center bg:{done ? "cyan2" : "blue2"}
			css .left rdl:{rd}
			css .right rdr:{rd}
			if time
				<div.side.left> time
			<div.middle> desc
			if duration
				<div.side.right> duration || ""

tag App

	def handle_task_click id
		lines = get_lines_from_text!
		done_msg = "DONE "
		if lines[id].startsWith(done_msg)
			lines[id] = lines[id].slice(done_msg.length)
		else
			lines[id] = done_msg + lines[id]
		text = lines.join("\n")

	def render_difference one, two
		<div[ta:center]> "-- {two.time} - {one ? one.time : ""} --"

	def render
		<self [d:flex fld:column mb:70px]>
			if adding
				<AddTaskPage>
			else
				<Schedule>

imba.mount <App>
