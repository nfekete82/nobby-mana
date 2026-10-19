extends RefCounted
## Test worlds never read/write the user's real exploration save.
static func isolate_exploration(root: Window) -> Node:
	var session := root.get_node_or_null("Session")
	if session == null:
		session = load("res://scripts/session.gd").new()
		session.name = "Session"
		root.add_child(session)
	session.exploration = load("res://scripts/exploration.gd").new("")
	return session
