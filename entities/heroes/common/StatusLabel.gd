extends Label3D

func apply_status(state_statuses):
	if state_statuses == {}:
		$Bar.set_scale(Vector3(0, 1, 1))
		set_text("")
		return
	var proportion = 0
	if "Stunned" in state_statuses:
		set_text("Stunned")
		proportion = state_statuses["Stunned"][0] / state_statuses["Stunned"][1]
	elif "Silenced" in state_statuses:
		set_text("Silenced")
		proportion = state_statuses["Silenced"][0] / state_statuses["Silenced"][1]
	elif "Rooted" in state_statuses:
		set_text("Rooted")
		proportion = state_statuses["Rooted"][0] / state_statuses["Rooted"][1]
	elif "Flying" in state_statuses:
		set_text("Flying")
		proportion = state_statuses["Flying"][0] / state_statuses["Flying"][1]
	$Bar.set_scale(Vector3(proportion, 1, 1))
