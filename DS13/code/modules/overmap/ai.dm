
/obj/structure/overmap //AI vars
	var/AI_enabled = FALSE //Do you want this ship to be computer controlled?
	var/faction = "starfleet" //Change this if you want to make teams of AIs
	var/obj/structure/overmap/target = null //Used for AIs, lets us track a target.
	var/behaviour = "retaliate" //By default. Ais will only shoot back.
	var/list/possible_behaviours = list("aggressive", "retaliate", "peaceful") //This will be admin selectable when I add an overmap panel
	var/range = 15 //Firing range.

/obj/structure/overmap/ai
	name = "Romulan warbird class light cruiser"
	desc = "A dangerous ship which resembles a bird. It has a modest armament and is highly maneuverable."
	icon = 'DS13/icons/overmap/warbird.dmi'
	icon_state = "warbird"
	main_overmap = FALSE
	class = "enemy-romulan" //Feel free to add overmap controls for AIs later, future me.
	damage_states = FALSE //Damage FX
	damage = 10 //Will turn into 20 assuming weapons powered
	AI_enabled = TRUE //Start with an AI by default
	faction = "romulan" //Placeholder
	var/datum/overmap_event/linked_event
	turnspeed = 1.2
	max_health = 130
	max_speed = 2 //Slower than every ship.

/obj/structure/overmap/ai/dderidex //AI version can't cloak.
	name = "Dderidex class heavy cruiser"
	desc = "Vicious, huge, fast. The Dderidex class is the Romulan navy's most popular warship for a reason. It has an impressive armament and cloaking technology."
	icon = 'DS13/icons/overmap/dderidex.dmi'
	icon_state = "dderidex"
	main_overmap = FALSE
	class = "dderidex"
	damage_states = TRUE //Damage FX
	damage = 10 //Will turn into 20 assuming weapons powered
	faction = "romulan"
	max_shield_health = 200
	max_health = 200 //Extremely fucking tanky
	pixel_z = -128
	pixel_w = -120

/obj/structure/overmap/ai/aggressive
	behaviour = "aggressive"

/obj/structure/overmap/ai/aggressive/miranda
	name = "Miranda Class Light Cruiser"
	desc = "An all purpose, reliable starship. It's a tried and tested design that has served the federation for hundreds of years. Despite its aging design, it has a modest armament."
	icon = 'DS13/icons/overmap/miranda.dmi'
	icon_state = "miranda"
	main_overmap = FALSE
	class = "starfleet-miranda" //Feel free to add overmap controls for AIs later, future me.
	damage_states = TRUE
	damage = 10
	faction = "starfleet"
	behaviour = "aggressive"

/obj/structure/overmap/ai/explode()
	if(linked_event)
		linked_event.check_completion(src)
	. = ..()

/obj/structure/overmap/ai/freighter
	name = "Federation Frigate"
	desc = "A minimally armoured tug with strong shields. It has next to no offensive power."
	icon = 'DS13/icons/overmap/freighter.dmi'
	icon_state = "freighter"
	main_overmap = FALSE
	class = "starfleet-freighter" //Feel free to add overmap controls for AIs later, future me.
	damage_states = FALSE
	damage = 10
	faction = "starfleet"
	max_shield_health = 300
	max_health = 300

/obj/structure/overmap/ai/miranda
	name = "Miranda Class Light Cruiser"
	desc = "An all purpose, reliable starship. It's a tried and tested design that has served the federation for hundreds of years. Despite its aging design, it has a modest armament."
	icon = 'DS13/icons/overmap/miranda.dmi'
	icon_state = "miranda"
	main_overmap = FALSE
	class = "starfleet-miranda" //Feel free to add overmap controls for AIs later, future me.
	damage_states = TRUE
	damage = 10
	faction = "starfleet"
	max_shield_health = 0
	max_health = 400

/obj/structure/overmap/ai/assimilated
	name = "Unimatrix"
	desc = "Her crew must have suffered a terrible fate..."
	icon = 'DS13/icons/overmap/miranda_assimilated.dmi'
	icon_state = "assimilated2"
	max_health = 250
	class = "borg-miranda"
	damage_states = FALSE

/obj/structure/overmap/ai/miranda/take_control()
	. = ..()
	engine_power = 0
	angle = rand(0,360)
	EditAngle() //Set a random spin so it looks damaged
	check_power()


/obj/structure/overmap/proc/take_control() //Take control of our ship, make it into an AI
	START_PROCESSING(SSobj, src) //Need to process to check for targets and so on.
	name = "[name] ([rand(0,1000)])"
	shield_power = 2 //So theyre not ultra squishy
	weapon_power = 1
	engine_power = 4
	max_shield_power = 4
	max_weapon_power = 4
	max_engine_power = 4
	power_slots -= 4
	AI_enabled = TRUE //Let the computer take the wheel
	check_power()

/obj/structure/overmap/proc/remove_control() //Stop the AI from controlling the ship
	AI_enabled = FALSE
	STOP_PROCESSING(SSobj,src)
	name = initial(name)
	nav_target = null
	target = null

/obj/structure/overmap/process()
	if(!AI_enabled) //Process is ONLY called for ai ships. We don't want a non ai ship doing this or consequences
		return
	if(vel < max_speed)
		vel += acceleration
	if(!process) //Start process allows the ship to move. It is called at init but if for some reason it stops, we need to reboot it.
		process = TRUE
		start_process()
	if(target) //We have a target locked in
		if(get_dist(src, target) > range || target.cloaked) //Target ran away. Move on.
			if(force_target)
				if(QDELETED(force_target) || !force_target)
					force_target = null
					return
				target = force_target
				nav_target = force_target //If we have a force target, we're an actor in a mission and NEED to return to hunt down our quarray after shooting at the players.
				return
			nav_target = target
			target = null //Don't shoot them, but keep chasing them UNLESS we're being forced to chase another.
			pick_target()
			return
		if(behaviour == "peaceful") //Peaceful means never retaliate, so return
			return
		if(get_dist(src, target) >= 7) //if theyre far away, head towards them again
			nav_target = target
			orbit = FALSE
		else //Go for an orbit.
			nav_target = null
			orbit = TRUE
		if(cloaked) //No firing while cloaked, please!
			return
		special_fire(target, damage)//Shoot the target. This can either be us shooting on aggressive mode, or us being hit by the attacker.
		return //No need to pick another target if we have one and theyre in range
	else
		pick_target()

/obj/structure/overmap/proc/special_fire(var/obj/structure/overmap/target, var/damage) //Allows us to randomly pick photon torps or phasers
	if(prob(70))
		fire(target, damage)
	else
		target.send_sound_crew('DS13/sound/effects/weapons/torpedo.ogg')
		var/obj/item/projectile/beam/laser/photon_torpedo/A = new /obj/item/projectile/beam/laser/photon_torpedo(loc)
		A.starting = loc
		A.preparePixelProjectile(target,src)
		A.pixel_x = rand(0, 5)
		A.fire()
		target.take_damage(src, damage)

/obj/structure/overmap/proc/pick_target()
	for(var/obj/structure/overmap/OM in GLOB.overmap_ships)
		if(get_dist(src, OM) > range || OM.cloaked)
			continue
		if(istype(OM, /obj/structure/overmap))
			if(OM in attackers)
				target = OM
				nav_target = OM
				return
			if(behaviour == "aggressive" && OM.faction != faction)
				target = OM
				nav_target = OM
				return
	return

/obj/structure/overmap/take_damage(var/atom/source, var/amount = 10)
	. = ..()
	if(AI_enabled)
		if(istype(source, /obj/structure/overmap) && behaviour == "retaliate")
			if(source == target)
				return //Already our target. Ignore
			target = source
			attackers += target
			process() //Instant retaliate. Don't delay!


/obj/structure/overmap/Destroy()
	if(AI_enabled)
		STOP_PROCESSING(SSobj,src)
	. = ..()