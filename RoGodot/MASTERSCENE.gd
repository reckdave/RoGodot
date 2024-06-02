extends Node2D

var loglocation

var lines
var lastline
var lastcoderan

var oldlines = []

var loaded = false

var thread : Thread = Thread.new()

func _ready():
	loglocation = OS.get_environment("LOCALAPPDATA") + "\\Roblox\\logs"
	loglocation = get_most_recent_file(loglocation)
	var file = File.new()
	file.open(loglocation,File.WRITE)
	file.store_string("")
	file.close()
	thread.start(self,"mainThread")
	loaded = true

func mainThread(_u):
	mainfunc()

func _exit_tree():
	thread.wait_to_finish()

func get_most_recent_file(folder_path : String):
	var dir = Directory.new()
	var error = dir.open(folder_path)
	if error == OK:
		dir.list_dir_begin()
		
		var most_recent_file = ""
		var most_recent_time = 0
		
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
			else:
				var file = File.new()
				var file_path = folder_path + "\\" + file_name
				file.open(file_path,File.READ_WRITE)
				var file_time = file.get_modified_time(file_path)
				
				if file_time > most_recent_time:
					most_recent_time = file_time
					most_recent_file = file_path
				file.close()
			file_name = dir.get_next()
		return most_recent_file
	else:
		print(error)

func difference(arr1, arr2):
	var only_in_arr1 = []
	for v in arr1:
		if not (v in arr2):
			only_in_arr1.append(v)
	return only_in_arr1

func readfile():
	var file = File.new()
	file.open(loglocation,File.READ)
	var text = file.get_as_text()
	lines = text.split("\n")
	var differences = difference(lines, oldlines)
	for line in differences:
		if "[GAME]" in line:
			if "> " in line: return
			var codestring = line.split("[GAME]")
			make_script(codestring[1])
	oldlines = lines
	file.close()


func make_script(string):
	var script = GDScript.new()
	script.set_source_code("func eval():" + string)
	script.reload()
	var ref = Reference.new()
	ref.set_script(script)
	return ref.eval()

func mainfunc():
	if !loaded: return
	readfile()
	yield(get_tree().create_timer(1,false),"timeout")
	mainfunc()

func _on_LatestLog_timeout():
	loglocation = OS.get_environment("LOCALAPPDATA") + "\\Roblox\\logs"
	loglocation = get_most_recent_file(loglocation)
#	var file = File.new()
#	file.open(loglocation,File.WRITE)
#	file.store_string("")
#	file.close()
	print("RESET, LOG: %s" % loglocation)
