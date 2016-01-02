/atom/movable/cell/explosion
	name = "explosion"
	desc = ""
	icon = 'icons/effects/fire.dmi'
	icon_state = "3"

	age_max = 3

	light_range = 3
	light_color = FIRE_COLOR
	light_power = 3

	master_type = /datum/cell_auto_master/explosion

	var/age_process_max = 2
	var/age_damage_max  = 2 // will do damage until this age

/atom/movable/cell/explosion/New()
	..()

/atom/movable/cell/explosion/proc/update_icon()
	..()

/atom/movable/cell/explosion/process()
	if( shouldDie() )
		qdel(src)

	age++

	if( !master )
		return

	if( shouldProcess() && master.shouldProcess() ) // If we have not aged at all
		if( !loc.Enter( src ))
			damage()
		else
			damage()
			spread()

/atom/movable/cell/explosion/spread()
	for( var/direction in cardinal ) // Only gets NWSE
		var/turf/T = get_step( src,direction )
		if( checkTurf( T ))
			PoolOrNew( /atom/movable/cell/explosion, list( T, master ))

/atom/movable/cell/explosion/proc/damage()
	damageTurf( get_turf( src ))

/atom/movable/cell/explosion/proc/damageTurf( var/turf/T )
	var/datum/cell_auto_master/explosion/M = master
	var/severity = M.getSeverity()

	T.ex_act( severity )
	if( T )
		for( var/atom_movable in T.contents )	//bypass type checking since only atom/movable can be contained by turfs anyway
			var/atom/movable/AM = atom_movable
			if( AM && AM.simulated )
				AM.ex_act( severity )

/atom/movable/cell/explosion/shouldProcess()
	if( age > age_process_max )
		return 0

	return 1

/atom/movable/cell/explosion/proc/checkTurf( var/turf/T )
	if( !T )
		return 0

	if( T.containsCell( type ))
		return 0

	return 1

/datum/cell_auto_master/explosion
	cell_type = /atom/movable/cell/explosion

	group_age_max = 0

	var/devastation_range
	var/heavy_impact_range
	var/light_impact_range

	var/start
	var/turf/start_loc

	var/powernet_rebuild_deferred

/datum/cell_auto_master/explosion/shouldProcess()
	if( group_age <= devastation_range || group_age <= heavy_impact_range || group_age <= light_impact_range )
		return 1
	else
		return 0

/datum/cell_auto_master/explosion/New( var/loc as turf, var/devastation, var/heavy_impact, var/light_impact )
	..()

	start_loc = loc

	devastation_range = devastation
	heavy_impact_range = heavy_impact
	light_impact_range = light_impact

	explosion_handler.masters += src

	start = world.timeofday

	var/approximate_intensity = (devastation_range * 3) + (heavy_impact_range * 2) + light_impact_range
	powernet_rebuild_deferred = defer_powernet_rebuild
	// Large enough explosion. For performance reasons, powernets will be rebuilt manually
	if(!defer_powernet_rebuild && (approximate_intensity > 25))
		defer_powernet_rebuild = 1

/datum/cell_auto_master/explosion/Destroy()
	explosion_handler.masters -= src

	if(!powernet_rebuild_deferred && defer_powernet_rebuild)
		makepowernets()
		defer_powernet_rebuild = 0

	var/took = (world.timeofday-start)/10
	//You need to press the DebugGame verb to see these now....they were getting annoying and we've collected a fair bit of data. Just -test- changes  to explosion code using this please so we can compare
	//if(Debug2)
	world.log << "## DEBUG: Explosion([start_loc.x],[start_loc.y],[start_loc.z])(d[devastation_range],h[heavy_impact_range],l[light_impact_range]): Took [took] seconds."

	..()

/datum/cell_auto_master/explosion/proc/getSeverity()
	if( group_age < devastation_range )
		return 1.0
	else if( group_age < heavy_impact_range )
		return 2.0
	else if( group_age < light_impact_range )
		return 3.0
	else
		return 0