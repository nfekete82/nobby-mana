extends RefCounted
## Total experience is the only persistent hero stat; derive level and balance.
const MAX_LEVEL := 50
const CLASSES := ["monkey","panda"]
var storage_path: String
var profiles: Dictionary = {"monkey":0,"panda":0}
var dirty := false

func _init(path := "user://hero-progress-v1.json") -> void:
	storage_path = path
	if path.is_empty() or not FileAccess.file_exists(path):
		return
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		return
	var data: Variant = json.data
	if not data is Dictionary or data.get("version") != 1 or not data.get("heroes") is Dictionary:
		return
	for id: String in CLASSES:
		var value: Variant = data.heroes.get(id,0)
		if (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value)):
			profiles[id] = clampi(int(value),0,total_for_level(MAX_LEVEL))

func cost(level: int) -> int:
	return 100+50*(level-1)

func total_for_level(level: int) -> int:
	var total := 0
	for step in range(1,clampi(level,1,MAX_LEVEL)):
		total += cost(step)
	return total

func stats(id: String) -> Dictionary:
	var total: int = profiles.get(id,0)
	var level := 1
	var remaining := total
	while level < MAX_LEVEL and remaining >= cost(level):
		remaining -= cost(level)
		level += 1
	return {"level":level,"xp":0 if level == MAX_LEVEL else remaining,"required":cost(level),"total":total}

func award(id: String,amount: int) -> void:
	if id not in CLASSES or amount <= 0:
		return
	var before: int = profiles[id]
	profiles[id] = mini(total_for_level(MAX_LEVEL),before+amount)
	dirty = dirty or profiles[id] != before

func flush() -> Error:
	if not dirty or storage_path.is_empty():
		return OK
	var temporary := storage_path+".tmp"
	var file := FileAccess.open(temporary,FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify({"version":1,"heroes":profiles}))
	file.close()
	var result := DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary),ProjectSettings.globalize_path(storage_path))
	if result == OK:
		dirty = false
	return result
