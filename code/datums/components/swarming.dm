/datum/component/swarming
	var/offset_x = 0
	var/offset_y = 0
	var/is_swarming = FALSE
	var/list/swarm_members = list()
	///given to connect_loc to listen for something moving onto or off of parent
	var/static/list/crossed_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(join_swarm),
		COMSIG_ATOM_EXITED = PROC_REF(leave_swarm),
	)

/datum/component/swarming/Initialize(max_x = 24, max_y = 24)
	offset_x = rand(-max_x, max_x)
	offset_y = rand(-max_y, max_y)

	AddComponent(/datum/component/connect_loc_behalf, parent, crossed_connections)

/datum/component/swarming/Destroy()
	if(is_swarming)
		for(var/A in swarm_members)
			var/datum/component/swarming/other_swarm = A
			other_swarm.swarm_members -= src
			swarm_members -= other_swarm
			if(!length(other_swarm.swarm_members))
				other_swarm.unswarm()
		unswarm()
	return ..()

/datum/component/swarming/proc/join_swarm(datum/source, atom/movable/AM)
	var/datum/component/swarming/other_swarm = AM.GetComponent(/datum/component/swarming)
	if(!other_swarm)
		return
	swarm()
	swarm_members |= other_swarm
	other_swarm.swarm()
	other_swarm.swarm_members |= src

/datum/component/swarming/proc/leave_swarm(datum/source, atom/movable/AM)
	var/datum/component/swarming/other_swarm = AM.GetComponent(/datum/component/swarming)
	if(!other_swarm || !(other_swarm in swarm_members))
		return
	swarm_members -= other_swarm
	if(!swarm_members.len)
		unswarm()
	other_swarm.swarm_members -= src
	if(!other_swarm.swarm_members.len)
		other_swarm.unswarm()

/datum/component/swarming/proc/swarm()
	var/atom/movable/owner = parent
	if(!is_swarming)
		is_swarming = TRUE
		animate(owner, pixel_x = owner.pixel_x + offset_x, pixel_y = owner.pixel_y + offset_y, time = 2)

/datum/component/swarming/proc/unswarm()
	var/atom/movable/owner = parent
	if(is_swarming)
		animate(owner, pixel_x = owner.pixel_x - offset_x, pixel_y = owner.pixel_y - offset_y, time = 2)
		is_swarming = FALSE
