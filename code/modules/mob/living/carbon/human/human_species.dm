/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH

/mob/living/carbon/human/dummy/New(var/new_loc)
	..( new_loc )
	spawn( 10 )
		if( character )
			character.name = name

/mob/living/carbon/human/skrell/New(var/new_loc)
	character.hair_style = "Skrell Male Tentacles"
	..(new_loc, "Skrell")

/mob/living/carbon/human/tajaran/New(var/new_loc)
	character.hair_style = "Tajaran Ears"
	..(new_loc, "Tajara")

/mob/living/carbon/human/unathi/New(var/new_loc)
	character.hair_style = "Unathi Horns"
	..(new_loc, "Unathi")

/mob/living/carbon/human/vox/New(var/new_loc)
	character.hair_style = "Short Vox Quills"
	..(new_loc, "Vox")

/mob/living/carbon/human/voxarmalis/New(var/new_loc)
	character.hair_style = "Bald"
	..(new_loc, "Vox Armalis")

/mob/living/carbon/human/diona/New(var/new_loc)
	..(new_loc, "Diona")

/mob/living/carbon/human/machine/New(var/new_loc)
	character.hair_style = "blue IPC screen"
	..(new_loc, "Machine")

/mob/living/carbon/human/wryn/New(var/new_loc)
	character.hair_style = "wryn_antennae"
	..(new_loc, "Wryn")

/mob/living/carbon/human/nucleation/New(var/new_loc)
	character.hair_style = "Bald"
	..(new_loc, "Nucleation")

/mob/living/carbon/human/monkey/New(var/new_loc)
	..(new_loc, "Monkey")
	spawn( 10 )
		if( character )
			character.name = name

/mob/living/carbon/human/farwa/New(var/new_loc)
	..(new_loc, "Farwa")
	spawn( 10 )
		if( character )
			character.name = name

/mob/living/carbon/human/neara/New(var/new_loc)
	..(new_loc, "Neara")
	spawn( 10 )
		if( character )
			character.name = name

/mob/living/carbon/human/stok/New(var/new_loc)
	..(new_loc, "Stok")
	spawn( 10 )
		if( character )
			character.name = name
