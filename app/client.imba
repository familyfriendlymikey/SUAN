let p = console.log
let o = "hello world"

tag Schedule
	def render
		<self[w:100%]> for item in tasks
			<Task data=item>

tag AddTaskPage
	def render
		<self> <input[w:100% h:50px fs:25px p:10px]>

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
			<div.side.left> "test"
			<div.middle> desc
			<div.side.right> "test"

tag AddTaskButton
	def render
		<self[
				bg:cyan1 ff:arial bdt:3px solid sky2
				h:70px pos:fixed b:0 l:0 r:0
				d:flex fld:row jc:center ai:center
				fs:20px c:blue5 zi:1000 cursor:pointer
				user-select:none
			]
		@click=handle_add> "ADD"

tag App
	prop tasks = [{desc:"do it!"}]
	prop adding = true

	def parse_time time
		if time.length <= 2 and parseInt(time) < 24
			return time + ":00"
		elif time.length == 3 and parseInt(time.substr(1)) < 60
			return time[0] + ":" + time.substr(1)
		elif time.length == 4 and parseInt(time.substr(0,2)) < 24 and parseInt(time.substr(2)) < 60
			return time.substr(0,2) + ":" + time.substr(2)
		else
			return "INVALID"

	def parse_task_text item, id
		words = item.trim().split(/\s/)
		done = false

		const is_duration? = do |duration| (/^\d+[hms]$/).test(duration)
		const is_time? = do |time| (/^\d+$/).test(time)

		if words[0] == 'DONE'
			words = words.slice(1)
			done = true

		if is_time? words[0]
			time = parse_time words[0]

		if is_duration? words[1]
			duration = words[1]
			desc = words.slice(2).join(" ")
			return {type: "FULL_TASK", time, duration, desc, done, id}
		else
			desc = words.slice(1).join(" ")
			return {type: "NO_DURATION", time, desc, done, id}

	def handle_add
		adding = !adding

	def handle_task_click id
		lines = get_lines_from_text!
		done_msg = "DONE "
		if lines[id].startsWith(done_msg)
			lines[id] = lines[id].slice(done_msg.length)
		else
			lines[id] = done_msg + lines[id]
		text = lines.join("\n")

	def compare_time item1, item2
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

	def get_lines_from_text
		text.trim().split('\n')

	def parse_and_sort_lines_by_time lines
		data = []
		for line, id in lines
			data.push parse_task_text line, id
		data.sort compare_time
		data

	def render_difference one, two
		<div[ta:center]> "-- {two.time} - {one ? one.time : ""} --"

	def render
		<self [d:flex fld:column mb:70px]>
			<AddTaskButton handle_add=handle_add.bind(self)>
			if adding
				<AddTaskPage>
			else
				<Schedule tasks>

imba.mount <App>
