/mob/living/simple_animal/hostile/dalek
	name = "Dalek"
	desc = "A creature that was born to hate, it is heavily armed and extremely dangerous."
	icon = 'DS13/icons/mob/animal.dmi'
	icon_state = "dalek"
	icon_living = "dalek"
	icon_dead = "dalek_dead"
	gender = NEUTER
	mob_biotypes = list(MOB_ROBOTIC)
	health = 200
	maxHealth = 200
	healable = 0
	melee_damage_lower = 2
	melee_damage_upper = 3
	attacktext = "vaporizes"
	attack_sound = 'DS13/sound/effects/bbc/dalek_fire.ogg'
	projectilesound = 'DS13/sound/effects/bbc/dalek_fire.ogg'
	projectiletype = /obj/item/projectile/energy/dalek
	faction = list("dalek")
	check_friendly_fire = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	speak_emote = list("states")
	gold_core_spawnable = HOSTILE_SPAWN
	del_on_death = FALSE
	loot = list(/obj/effect/decal/cleanable/robot_debris)
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5

/mob/living/simple_animal/hostile/dalek/OpenFire(atom/A)
	if(CheckFriendlyFire(A))
		return
	if(prob(30))
		var/chosen_sound = pick('DS13/sound/effects/bbc/exterminate.ogg','DS13/sound/effects/bbc/exterminate2.ogg')
		playsound(loc, chosen_sound, 50, 1, -1)
		say("EXTERMINATE!")
	visible_message("<span class='danger'><b>[src]</b> [ranged_message] at [A]!</span>")
	if(rapid > 1)
		var/datum/callback/cb = CALLBACK(src, .proc/Shoot, A)
		for(var/i in 1 to rapid)
			addtimer(cb, (i - 1)*rapid_fire_delay)
	else
		Shoot(A)
	ranged_cooldown = world.time + ranged_cooldown_time

/mob/living/simple_animal/hostile/dalek/bullet_act(obj/item/projectile/P)
	if(!stat)
		var/obj/effect/temp_visual/at_shield/AT = new /obj/effect/temp_visual/at_shield(loc, src)
		var/random_x = rand(-8, 8)
		AT.pixel_x += random_x

		var/random_y = rand(0, 32)
		AT.pixel_y += random_y
	..()

/obj/item/projectile/energy/dalek
	name = "exterminator blast"
	icon_state = "chronobolt"
	color = "#d9e7ff"
	stutter = 5
	jitter = 20
	hitsound = 'DS13/sound/effects/bbc/dalek_fire2.ogg'
	range = 10
	damage = 50

/obj/item/projectile/energy/dalek/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(!isliving(target)) //Hit a wall or something non human
		do_sparks(1, TRUE, src)
	else if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.electrocute_act(85, src, 1)