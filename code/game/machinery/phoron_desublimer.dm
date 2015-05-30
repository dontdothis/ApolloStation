/*
///////////// PHORON DESUBLIMER ////////////////
	~~Created by Kwask, sprites by Founded1992~~
Desc: This is a machine which will take gaseous phoron and turns it into various materials
The process works like this:
	1.) A supermatter seed crystal is place inside of the react

	NEUTRON FURNACE
	5.) Place the supermatter shard inside and set the neutron flow. The neutron flow represents the desired focus point.
		Each of the different materials has a "focus peak" where you produce a maximum output of that material.
		Setting the neutron flow between two peaks creates a smaller amount of both materials.
		Some materials, such as osmium and phoron, produce so little amount that you may get nothing unless the neutron flow matches the peak.
	6.) Activate the machine.
	7.) Congrats, you now have some bars!
*/

/obj/machinery/phoron_desublimer
	icon = 'icons/obj/machines/phoron_compressor.dmi'
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 0
	var/ready = 0
	var/active = 0

	process()
		if( stat & ( BROKEN|NOPOWER ))
			ready = 0

	proc/report_ready()
		if( stat & ( BROKEN|NOPOWER ))
			ready = 0

/*  //////// PHORON REACTANT VESSEL ////////
	Takes in gas and supermatter seed, creates supermatter shard
*/

/obj/machinery/phoron_desublimer/vessel
	name = "Formation Vessel"
	desc = "Grows supermatter shards by seeding them with phoron."
	icon_state = "ProcessorEmpty"
	var/obj/item/weapon/tank/loaded_tank
	var/obj/item/weapon/shard/supermatter/loaded_shard
	var/datum/gas_mixture/air_contents

	active_power_usage = 10000

	New()
		..()

		air_contents = new

		component_parts = list()
		component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
		component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
		component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
		component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
		component_parts += new /obj/item/weapon/stock_parts/capacitor(src)

	attackby(var/obj/item/weapon/B as obj, var/mob/user as mob)
		if(isrobot(user))
			return
		if(istype(B, /obj/item/weapon/tongs))
			if( !loaded_shard )
				var/obj/item/weapon/tongs/T = B
				if( T.held )
					if( istype( T.held, /obj/item/weapon/shard/supermatter ))
						T.held.loc = src
						loaded_shard = T.held
						T.held = null
						T.update_icon()
						user << "You put [loaded_shard] into the machine."
			else
				user << "There is already a shard in the machine."
		else if(istype(B, /obj/item/weapon/shard/supermatter))
			if( !loaded_shard )
				user.drop_item()
				B.loc = src
				loaded_shard = B
				user << "You put [B] into the machine."
			else
				user << "There is already a shard in the machine."
		else if( istype( B, /obj/item/weapon/tank ))
			if( !loaded_tank )
				user.drop_item()
				B.loc = src
				loaded_tank = B
				user << "You put [B] into the machine."
			else
				user << "There is already a tank in the machine."
		else
			user << "/red That's not a valid item!"

		update_icon()
		return

	proc/filled()
		if( air_contents.total_moles < 1 )
			return 0
		else
			return 1

	proc/fill()
		if( !loaded_tank )
			src.visible_message("\icon[src] <b>[src]</b> buzzes, \"No tank loaded!\"")
			return
		if( loaded_tank.air_contents.total_moles < 1 )
			src.visible_message("\icon[src] <b>[src]</b> buzzes, \"Loaded tank is empty!\"")
			return

		air_contents.merge( loaded_tank.air_contents.remove( loaded_tank.air_contents.total_moles ))

		if( !filled() )
			flick("ProcessorFill", src)
		icon_state = "ProcessorFull"


	proc/crystalize()
		if( !loaded_shard )
			src.visible_message("\icon[src] <b>[src]</b> buzzes, \"No gas present in system!\"")
			return
		if( !filled() )
			src.visible_message("\icon[src] <b>[src]</b> buzzes, \"Need a supermatter shard to feed!\"")
			return
		if( !report_ready() )
			return

		active = 1

		loaded_shard.feed( air_contents.remove( loaded_tank.air_contents.total_moles ))

		flick("ProcessorCrystalize", src)
		icon_state = "ProcessorEmpty"

		src.visible_message("\icon[src] <b>[src]</b> buzzes, \"Crystal successfully fed.\"")

		active = 0

	proc/eject_shard()
		testing( "eject_shard()" )
		if( !loaded_shard )
			testing( "return failed" )
			return

		loaded_shard.loc = get_turf( src )
		loaded_shard = null
		testing( "return success" )

	proc/eject_tank()
		testing( "eject_shard()" )
		if( !loaded_tank )
			testing( "return failed" )
			return

		loaded_tank.loc = get_turf( src )
		loaded_tank = null
		testing( "return success" )

	report_ready()
		ready = 1

		..()

		return ready


/*  //////// NEUTRON FURNACE /////////
	Put a supermatter shard inside of it, set neutron flow to specific level, get materials out
*/
/obj/machinery/phoron_desublimer/furnace
	name = "Neutron Furnace"
	desc = "A modern day alchemist's best friend."
	icon_state = "Open"

	var/neutron_flow = 25
	var/max_neutron_flow = 300
	var/obj/item/weapon/shard/supermatter/shard = null

	var/list/mat = list( "Osmium", "Phoron", "Diamonds", "Platinum", "Gold", "Uranium",  "Silver", "Steel",  )
	var/list/mat_mod = list(    "Steel" = 3.5,
								"Silver" = 2.5,
								"Uranium" = 2.5,
								"Gold" = 1.5,
								"Platinum" = 1.5,
								"Diamonds" = 1.5,
								"Phoron" = 1.5,
								"Osmium" = 1.3 ) // modifier for output amount

	var/list/mat_peak = list(   "Steel" = 30,
								"Silver" = 70,
								"Uranium" = 110,
								"Gold" = 150,
								"Platinum" = 190,
								"Diamonds" = 230,
								"Phoron" = 270,
								"Osmium" = 300 ) // Standard peak locations

	var/list/obj/item/stack/sheet/mat_obj = list( 	"Diamonds" = /obj/item/stack/sheet/mineral/diamond,
													"Steel" = /obj/item/stack/sheet/metal,
													"Silver" = /obj/item/stack/sheet/mineral/silver,
													"Platinum" = /obj/item/stack/sheet/mineral/platinum,
													"Osmium" = /obj/item/stack/sheet/mineral/osmium,
													"Gold" = /obj/item/stack/sheet/mineral/gold,
													"Uranium" = /obj/item/stack/sheet/mineral/uranium,
													"Phoron" = /obj/item/stack/sheet/mineral/phoron ) // cost per each mod # of bars

	New()
		..()
		component_parts = list()
		component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
		component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
		component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
		component_parts += new /obj/item/weapon/stock_parts/capacitor(src)


		/*
		for( var/i = 1, i <= output_peak.len, i++ )
			var/peak = output_peak[i]
			peak += -rand(0,1)*rand(1,3) // adding a bit of randomness to the process
			output_peak[i] = peak

		*/

	process()
		..()

	proc/modify_flow(var/change)
		neutron_flow += change
		if( neutron_flow > max_neutron_flow )
			neutron_flow = max_neutron_flow

		if( neutron_flow < 0 )
			neutron_flow = 0

	// Produces the resultant material
	proc/produce()
		if( !shard )
			src.visible_message("\icon[src] <b>[src]</b> buzzes, \"Needs a supermatter shard to transmutate.\"")
			return
		var/list/peak_distances = list()
		peak_distances = get_peak_distances( neutron_flow )
		var/max_distance = 50.0 // Max peak distance from neutron flow which will still produce materials

		active = 1
		flick( "Active", src )

		var/amount = 0
		for( var/cur_mat in mat )
			var/distance = peak_distances[cur_mat]
			if( distance <= max_distance )
				amount = round((( max_distance-distance )/max_distance )*mat_mod[cur_mat] ) // Produces amount based on distance from flow and modifier

				if( amount > 0 ) // Will only do anything if any amount was actually created
					var/obj/item/stack/sheet/T = mat_obj[cur_mat]
					var/obj/item/stack/sheet/I = new T
					I.amount = amount
					I.loc = src.loc

		eat_shard()
		src.visible_message("\icon[src] <b>[src]</b> beeps, \"Supermatter transmutation complete.\"")
		active = 0

	// This sorts a list of peaks within max_distance units of the given flow and returns a sorted list of the nearest ones
	proc/get_peak_distances( var/flow )
		var/list/peak_distances = new/list()

		for( var/cur_mat in mat_peak )
			var/peak = mat_peak[cur_mat]
			var/peak_distance = abs( peak-flow )
			peak_distances[cur_mat] = peak_distance
		return peak_distances

	// Eats the shard, duh
	proc/eat_shard()
		if( !shard )
			return 0

		del(shard)

		update_icon()
		return 1

	// Returns true if the machine is ready to perform
	report_ready()
		ready = 1

		..()

		return ready


	attackby(var/obj/item/weapon/B as obj, var/mob/user as mob)
		if(isrobot(user))
			return
		if(istype(B, /obj/item/weapon/tongs))
			if( !shard )
				var/obj/item/weapon/tongs/T = B
				if( T.held )
					if( istype( T.held, /obj/item/weapon/shard/supermatter ))
						T.held.loc = src
						shard = T.held.loc
						T.held = null
						T.update_icon()
						user << "You put [shard] into the machine."
			else
				user << "There is already a shard in the machine."
		else if(istype(B, /obj/item/weapon/shard/supermatter))
			if( !shard )
				user.drop_item()
				B.loc = src
				shard = B
				user << "You put [B] into the machine."
			else
				user << "There is already a shard in the machine."
		else
			user << "<span class='notice'>This machine only accepts supermatter shards</span>"

		update_icon()
		return


	update_icon()
		..()

		if( shard )
			icon_state = "OpenCrystal"
		else
			icon_state = "Open"

/obj/machinery/computer/phoron_desublimer_control
	name = "Phoron Desublimation Control"
	desc = "Controls the phoron desublimation process."
	icon = 'icons/obj/machines/phoron_compressor.dmi'
	icon_state = "Ready"
	var/ui_title = "Phoron Desublimation Control"

	idle_power_usage = 500
	active_power_usage = 70000 //70 kW per unit of strength
	var/active = 0
	var/assembled = 0
	var/state = null

	var/obj/machinery/phoron_desublimer/vessel/vessel
	var/obj/machinery/phoron_desublimer/furnace/furnace

/obj/machinery/computer/phoron_desublimer_control/New()
	..()

	src.check_parts()

/obj/machinery/computer/phoron_desublimer_control/proc/find_parts()
	vessel = null
	furnace = null

	var/area/main_area = get_area(src)
	testing( "Area [main_area] found" )

	for(var/area/related_area in main_area.related)
		testing( "Area [related_area] found" )
		for( var/obj/machinery/phoron_desublimer/PD in related_area )
			if( istype( PD, /obj/machinery/phoron_desublimer/vessel ))
				testing( "v: [PD] found" )
				vessel = PD
			if( istype( PD, /obj/machinery/phoron_desublimer/furnace ))
				testing( "f: [PD] found" )
				furnace = PD

	return

/obj/machinery/computer/phoron_desublimer_control/proc/check_parts()
	find_parts()

	if( !vessel )
		return 0
	if( !furnace )
		return 0

	return 1

/obj/machinery/computer/phoron_desublimer_control/attack_hand(mob/user as mob)
	ui_interact(user)

/obj/machinery/computer/phoron_desublimer_control/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	if(stat & (BROKEN|NOPOWER)) return
	if(user.stat || user.restrained()) return

	src.check_parts()

	// this is the data which will be sent to the ui
	var/data[0]
	data["run_scan"] = 0
	data["state"] = state
	if( vessel )
		testing( "vessel found" )
		data["vessel"] = vessel
		data["shard"] = vessel.loaded_shard
		data["max_shard_size"] = 100
		data["vessel_pressure"] = vessel.air_contents.return_pressure()

		if( vessel.loaded_shard )
			data["shard_size"] = vessel.loaded_shard.size_percent()
		else
			data["shard_size"] = 0

		if( vessel.loaded_tank )
			data["tank_pressure"] = round(vessel.loaded_tank.air_contents.return_pressure() ? vessel.loaded_tank.air_contents.return_pressure() : 0)
		else
			data["tank_pressure"] = 0
	else
		testing( "vessel not found" )
		data["vessel"] = null
		data["shard"] = null
		data["max_shard_size"] = null
		data["shard_size"] = null

		// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "phoron_desublimation.tmpl", ui_title, 390, 655)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()

/obj/machinery/computer/phoron_desublimer_control/Topic(href, href_list)
	if(..())
		return

	if(stat & (NOPOWER|BROKEN))
		return 0 // don't update UIs attached to this object

	if(href_list["state"])
		state = href_list["state"]
	else if(href_list["run_scan"])
		src.check_parts()
	else if(href_list["vessel_eject_shard"])
		testing( "Ejecting shard from [vessel]" )
		vessel.eject_shard()
	else if(href_list["vessel_eject_tank"])
		testing( "Ejecting tank from [vessel]" )
		vessel.eject_tank()
	else if(href_list["vessel_fill"])
		testing( "Filling vessel [vessel]" )
		vessel.fill()
	else if(href_list["vessel_feed"])
		testing( "Feeding crystal from [vessel]" )
		vessel.crystalize()

	nanomanager.update_uis(src)
	add_fingerprint(usr)

/*
/obj/machinery/computer/phoron_desublimer_control/interact(mob/user)
	if((get_dist(src, user) > 1) || (stat & (BROKEN|NOPOWER)))
		if(!istype(user, /mob/living/silicon))
			user.unset_machine()
			user << browse(null, "window=pacontrol")
			return
	user.set_machine(src)

	var/dat = ""
	dat += "<h3><b>Phoron Desublimer Controller</b></h3><BR>"
	dat += "<A href='?src=\ref[src];close=1'>Close</A><BR>"
	dat += "<A href='?src=\ref[src];scan=1'>Run Scan</A><BR><BR>"

	dat += "<b>Status:</b><BR>"
	for( var/M in machine_ref )
		if( machine_ref[M] )
			var/list/obj/machinery/phoron_desublimer/type = machine_ref[M]
			dat += "<h4><center>[type.name]</center></h4>"
			if( type && type.report_ready() )
				dat += "<BR>"
				if( istype( type, /obj/machinery/phoron_desublimer/furnace ))
					var/obj/machinery/phoron_desublimer/furnace/furnace = type
					dat += "<b>Neutron Flow:</b><BR>"
					dat += "<A href='?src=\ref[src];furnace_n10=1'>---</A> "
					dat += "<A href='?src=\ref[src];furnace_n1=1'>--</A> "
					dat += "<A href='?src=\ref[src];furnace_n01=1'>-</A> "
					dat += "   [furnace.neutron_flow]   "
					dat += "<A href='?src=\ref[src];furnace_01=1'>+</A> "
					dat += "<A href='?src=\ref[src];furnace_1=1'>++</A> "
					dat += "<A href='?src=\ref[src];furnace_10=1'>+++</A> <BR><BR>"
					if( furnace.shard )
						dat += "<b>Supermatter Shard Inserted</b> <BR>"
						if( furnace.active )
							dat += "<b>Active</b>"
						else
							dat += "<A href='?src=\ref[src];furnace_activate=1'>Activate</A><BR>"
					else
						dat += "<b>Supermatter Shard Needed</b> <BR>"
				else if( istype( type, /obj/machinery/phoron_desublimer/vessel ))
					var/obj/machinery/phoron_desublimer/vessel/vessel = type
					dat += "<b>Tank: </b>"
					if( vessel.loaded_tank )
						dat += "<b>Loaded</b>"
						dat += " <A href='?src=\ref[src];vessel_eject_tank'>Eject</A>"
					else
						dat += "Not Loaded"
					dat += "<br>"

					dat += "<b>Supermatter Shard: </b>"
					if( vessel.loaded_shard )
						dat += "<b>Loaded</b>"
						dat += " <A href='?src=\ref[src];vessel_eject_shard'>Eject</A><br>"
						dat += "Shard Size: [vessel.loaded_shard.size_percent()]<br>"
					else
						dat += "Not Loaded<br>"

					dat += "<A href='?src=\ref[src];vessel_fill'>Fill Chamber</A><br>"
					dat += "<A href='?src=\ref[src];vessel_feed'>Feed Crystal</A><br>"
			else
				dat += "ERROR: Incrreoctly set up!<BR>"
			dat += "<BR><HR>"

	user << browse(dat, "window=pdcontrol;size=420x500")
	onclose(user, "pdcontrol")
	return


/obj/machinery/computer/phoron_desublimer_control/Topic(href, href_list)
	..()
	//Ignore input if we are broken, !silicon guy cant touch us, or nonai controlling from super far away
	if(stat & (BROKEN|NOPOWER) || (get_dist(src, usr) > 1 && !istype(usr, /mob/living/silicon)) || (get_dist(src, usr) > 8 && !istype(usr, /mob/living/silicon/ai)))
		usr << browse(null, "window=pdcontrol")
		usr.unset_machine()
		return

	if( href_list["close"] )
		usr << browse(null, "window=pdcontrol")
		usr.unset_machine()
		return
	else if(href_list["scan"])
		src.check_parts()
	else if(href_list["furnace_10"])
		var/obj/machinery/phoron_desublimer/furnace/furnace = machine_ref["furnace"]
		furnace.modify_flow( 10 )
	else if(href_list["furnace_1"])
		var/obj/machinery/phoron_desublimer/furnace/furnace = machine_ref["furnace"]
		furnace.modify_flow( 1 )
	else if(href_list["furnace_01"])
		var/obj/machinery/phoron_desublimer/furnace/furnace = machine_ref["furnace"]
		furnace.modify_flow( 0.1 )
	else if(href_list["furnace_n01"])
		var/obj/machinery/phoron_desublimer/furnace/furnace = machine_ref["furnace"]
		furnace.modify_flow( -0.1 )
	else if(href_list["furnace_n1"])
		var/obj/machinery/phoron_desublimer/furnace/furnace = machine_ref["furnace"]
		furnace.modify_flow( -1 )
	else if(href_list["furnace_n10"])
		var/obj/machinery/phoron_desublimer/furnace/furnace = machine_ref["furnace"]
		furnace.modify_flow( -10 )
	else if(href_list["furnace_activate"])
		var/obj/machinery/phoron_desublimer/furnace/furnace = machine_ref["furnace"]
		if( furnace.ready & !furnace.active )
			furnace.produce()
	else if(href_list["vessel_fill"])
		var/obj/machinery/phoron_desublimer/vessel/vessel = machine_ref["vessel"]
		testing( "Filling vessel [vessel]" )
		vessel.fill()
	else if(href_list["vessel_feed"])
		var/obj/machinery/phoron_desublimer/vessel/vessel = machine_ref["vessel"]
		testing( "Feeding crystal from [vessel]" )
		vessel.crystalize()
	else if(href_list["vessel_eject_shard"])
		var/obj/machinery/phoron_desublimer/vessel/vessel = machine_ref["vessel"]
		testing( "Ejecting crystal from [vessel]" )
		vessel.eject_shard()
	else if(href_list["vessel_eject_tank"])
		var/obj/machinery/phoron_desublimer/vessel/vessel = machine_ref["vessel"]
		testing( "Ejecting tank from [vessel]" )
		vessel.eject_tank()

	src.updateDialog()
	src.update_icon()
	return
*/