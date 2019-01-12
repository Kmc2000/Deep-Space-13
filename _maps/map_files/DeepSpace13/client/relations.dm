/datum/preferences
	var/list/relations = list()
	var/list/relations_info = list()

/datum/preferences/proc/sanity_check_relations()
	. = ..()
	if(!relations)
		relations = list()
	if(!relations_info)
		relations_info = list()

/datum/preferences/proc/set_relations(mob/user)
	sanity_check_relations()
	var/dat
	dat += "Characters with enabled relations are paired up randomly after spawn. You can terminate relations when you first open relations info window, but after that it's final."
	dat += "<hr>"
	for(var/T in typecacheof(/datum/relation))
		var/datum/relation/R = T
		dat += "<b>[initial(R.name)]</b>\t"
		if(initial(R.name) in relations)
			dat += "<span class='linkOn'>On</span>"
			dat += "<a href='?_src_=prefs;preference=relations;task=togglerelation';relationtochange=[initial(R.name)]'>Off</a>"
		else
			dat += "<a href='?_src_=prefs;preference=relations;task=togglerelation';relationtochange=[initial(R.name)]'>On</a>"
			dat += "<span class='linkOn'>Off</span>"
		dat += "<br><i>[initial(R.desc)]</i>"
	//dat += "<br><b>What do they know about you?</b><a href='?_src_=prefs;preference=relations;task=setrelationdesc';relation_info=[initial(R.name)]>Edit</a>"
		dat += "<br><b>What do they know about you?</b><a href='?src=\ref[src];preference=relations;task=setrelationdesc';relation_info=\ref[R]'>Edit</a>"
		dat += "<br><i>[relations_info[initial(R.name)] ? relations_info[initial(R.name)] : "Nothing specific."]</i>"
		dat += "<hr>"
	var/datum/browser/popup = new(user, "preferences", "relations") // Set up the popup browser window
	popup.set_title_image(user.browse_rsc_icon(null, null))
	popup.set_content(dat)
	popup.open()

///datum/preferences/process_link(mob/user,href_list)
//	. = ..()
//relation_info=["general"]