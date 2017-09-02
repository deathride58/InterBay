#define cycle_pause 15 //min 1
#define viewrange 9 //min 2

/mob/living/carbon/human/monkey/punpun/New()
	..()
	name = "Pun Pun"
	real_name = name
	var/obj/item/clothing/C
	if(prob(50))
		C = new /obj/item/clothing/under/punpun(src)
		equip_to_appropriate_slot(C)
	else
		C = new /obj/item/clothing/under/punpants(src)
		C.attach_accessory(null, new/obj/item/clothing/accessory/toggleable/hawaii/random(src))
		equip_to_appropriate_slot(C)
		if(prob(10))
			C = new/obj/item/clothing/head/collectable/petehat(src)
			equip_to_appropriate_slot(C)

/obj/random_multi/single_item/punitelly
	name = "Multi Point - Warrant Officer Punitelli"
	id = "Punitelli"
	item_path = /mob/living/carbon/human/monkey/punitelli

/mob/living/carbon/human/monkey/punitelli/New()
	..()
	name = "Warrant Officer Punitelli"
	real_name = name
	var/obj/item/clothing/C
	C = new /obj/item/clothing/under/utility/expeditionary/monkey(src)
	equip_to_appropriate_slot(C)
	if(prob(50))
		C = new /obj/item/clothing/head/beret/sol/expedition(src)
	else
		C = new /obj/item/clothing/head/soft/sol/expedition
	equip_to_appropriate_slot(C)
	put_in_hands(new /obj/item/weapon/clipboard)
	equip_to_appropriate_slot(new /obj/item/clothing/mask/smokable/cigarette/jerichos)

/decl/hierarchy/outfit/blank_subject
	name = "Test Subject"
	uniform = /obj/item/clothing/under/color/white
	shoes = /obj/item/clothing/shoes/white
	head = /obj/item/clothing/head/helmet/facecover
	//mask = /obj/item/clothing/mask/muzzle
	//suit = /obj/item/clothing/suit/straight_jacket

/decl/hierarchy/outfit/blank_subject/post_equip(mob/living/carbon/human/H)
	var/obj/item/clothing/under/color/white/C = locate() in H
	if(C)
		C.has_sensor  = SUIT_LOCKED_SENSORS
		C.sensor_mode = SUIT_SENSOR_OFF

/mob/living/carbon/human/blank/New(var/new_loc)
	..(new_loc, "Vat-Grown Human")
	var/number = "[pick(possible_changeling_IDs)]-[rand(1,30)]"
	fully_replace_character_name("Subject [number]")
	zone_sel = new /obj/screen/zone_sel( null )
	zone_sel.selecting = "chest"
	a_intent = I_HURT
	var/decl/hierarchy/outfit/outfit = outfit_by_type(/decl/hierarchy/outfit/blank_subject)
	outfit.equip(src)
	is_npc = 1
	hand = 0
	var/obj/item/clothing/head/helmet/facecover/F = locate() in src
	if(F)
		F.name = "[F.name] ([number])"
	put_in_active_hand(/obj/item/weapon/material/sword)
	combat_mode = 1


/mob/living/carbon/human
	var/list/path = new/list()
	var/frustration = 0
	var/atom/object_target
	var/reach_unable
	var/is_npc = 0
	var/mob/living/carbon/human/target
	var/list/path_target = new/list()
	var/list/path_idle = new/list()
	var/list/objects


	// this is called when the target is within one tile
	// of distance from the zombie
	proc/attack_target()
		if(target.stat != CONSCIOUS && prob(70) || target.is_npc)
			return
		var/direct = get_dir(src, target)
		if ( (direct - 1) & direct)
			var/turf/Step_1
			var/turf/Step_2
			switch(direct)
				if(EAST|NORTH)
					Step_1 = get_step(src, NORTH)
					Step_2 = get_step(src, EAST)

				if(EAST|SOUTH)
					Step_1 = get_step(src, SOUTH)
					Step_2 = get_step(src, EAST)

				if(NORTH|WEST)
					Step_1 = get_step(src, NORTH)
					Step_2 = get_step(src, WEST)

				if(SOUTH|WEST)
					Step_1 = get_step(src, SOUTH)
					Step_2 = get_step(src, WEST)

			if(Step_1 && Step_2)
				var/check_1 = 1
				var/check_2 = 1

				check_1 = Adjacent(get_turf(src), Step_1, target) && Adjacent(Step_1, get_turf(target), target)

				check_2 = Adjacent(get_turf(src), Step_2, target) && Adjacent(Step_2, get_turf(target), target)

				if(check_1 || check_2)
					target.attack_hand(src)
					if(prob(30))
						custom_emote(2, "makes a scary noise!")			//But he will say one of the prepared words, or do an emote from say.dm
						return
					return
				else
					var/obj/structure/window/W = locate() in target.loc
					var/obj/structure/window/WW = locate() in src.loc
					if(W)
						W.attack_hand(src)
						if(prob(30))
							custom_emote(2, "makes a scary noise!")			//But he will say one of the prepared words, or do an emote from say.dm
							return
						return 1
					else if(WW)
						WW.attack_hand(src)
						if(prob(30))
							custom_emote(2, "makes a scary noise!")			//But he will say one of the prepared words, or do an emote from say.dm
							return
						return 1
		else if(Adjacent(src.loc , target.loc,target))
			target.attack_hand(src)
			if(prob(30))
				custom_emote(2, "makes a scary noise!")			//But he will say one of the prepared words, or do an emote from say.dm
				return
			// sometimes push the enemy
			if(prob(30))
				step(src,direct)
			return 1
		else
			var/obj/structure/window/W = locate() in target.loc
			var/obj/structure/window/WW = locate() in src.loc
			if(W)
				W.attack_hand(src)
				if(prob(30))
					custom_emote(2, "makes a scary noise!")			//But he will say one of the prepared words, or do an emote from say.dm
					return
				return 1
			else if(WW)
				WW.attack_hand(src)
				if(prob(30))
					custom_emote(2, "makes a scary noise!")			//But he will say one of the prepared words, or do an emote from say.dm
					return
				return 1

	// main loop
	proc/process()
		set background = 1

		if (stat == 2)
			return 0

		if(weakened || paralysis || handcuffed || !canmove)
			return 1

		//if(resting)
			//rest()

		setStaminaLoss(0)//So they don't wear themselves out.

		if(destroy_on_path())
			return 1

		if (!target)
			// no target, look for a new one

			// look for a target, taking into consideration their health
			// and distance from the zombie
			var/last_health = INFINITY
			var/last_dist = INFINITY

			for (var/mob/living/carbon/human/C in orange(viewrange-2,src.loc))
				var/dist = get_dist(src, C)

				// if the zombie can't directly see the human, they're
				// probably blocked off by a wall, so act as if the
				// human is further away
				if(!(C in view(src, viewrange)))
					dist += 3

				if (C.stat == 2 || !can_see(src,C,viewrange))
					continue
				if(C.stunned || C.paralysis || C.weakened)
					target = C
					break
				if(C.health < last_health && dist <= last_dist) if(!prob(30))
					last_health = C.health
					last_dist = dist
					target = C

		// if we have found a target
		if(target && !target.is_npc)
			// change the target if there is another human that is closer
			for (var/mob/living/carbon/human/C in orange(2,src.loc))
				if (C.stat == 2 || !can_see(src,C,viewrange))
					continue
				if(get_dist(src, target) >= get_dist(src, C) && prob(30))
					target = C
					break

			if(target.stat == 2)
				target = null


			var/distance = get_dist(src, target)

			if(target in orange(viewrange,src))
				if(distance <= 1)
					if(attack_target())
						return 1
				if(step_towards_3d(src,target))
					return 1
			else
				target = null
				return 1

		// if there is no target in range, roam randomly
		else

			frustration--
			frustration = max(frustration, 0)

			if(stat == 2) return 0

			var/prev_loc = loc
			// make sure they don't walk into space
			if(!(locate(/turf/space) in get_step(src,dir)))
				step(src,dir)
			// if we couldn't move, pick a different direction
			// also change the direction at random sometimes
			if(loc == prev_loc || prob(20))
				sleep(5)
				dir = pick(NORTH,SOUTH,EAST,WEST)

			return 1

		// if we couldn't do anything, take a random step
		step_rand(src)
		dir = get_dir(src,target) // still face to the target
		frustration++

		return 1

	// destroy items on the path
	proc/destroy_on_path()
		// if we already have a target, use that
		if(object_target)
			if(!object_target.density)
				object_target = null
				frustration = 0
			else
				// we know the target has attack_hand
				// since we only use such objects as the target
				object_target:attack_hand(src)
				if(prob(30))
					custom_emote(2, "makes a scary noise!")			//But he will say one of the prepared words, or do an emote from say.dm
					return
				return 1

		// first, try to destroy airlocks and walls that are in the way
		if(locate(/obj/machinery/door/airlock) in get_step(src,src.dir))
			var/obj/machinery/door/airlock/D = locate() in get_step(src,src.dir)
			if(D)
				if(D.density && !(locate(/turf/space) in range(1,D)) )
					D.attack_hand(src)
					object_target = D
					if(prob(30))
						custom_emote(2, "makes a scary noise!")			//But he will say one of the prepared words, or do an emote from say.dm
						return
					return 1
		// before clawing through walls, try to find a direct path first
		if(frustration > 8 )
			if(istype(get_step(src,src.dir),/turf/simulated/wall))
				var/turf/simulated/wall/W = get_step(src,src.dir)
				if(W)
					if(W.density && !(locate(/turf/space) in range(1,W)))
						W.attack_hand(src)
						object_target = W
						if(prob(30))
							custom_emote(2, "makes a scary noise!")			//But he will say one of the prepared words, or do an emote from say.dm
							return
						return 1
		return 0

	death()
		..()
		target = null

/mob/living/carbon/human/blank/ssd_check()
	return FALSE