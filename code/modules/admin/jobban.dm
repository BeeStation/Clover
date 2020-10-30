/proc/jobban_fullban(mob/M, rank)
	if (!M?.ckey) return

	var/query[] = new()
	query["ckey"] = M.ckey
	query["rank"] = rank

	apiHandler.queryAPI("jobbans/add", query, 1)

	return TRUE

/proc/jobban_isbanned(mob/M, rank)
	if (!M || !M.ckey ) return

	//you cant be banned from nothing!!
	if (!rank)
		return FALSE

	var/datum/job/J = find_job_in_controller_by_string(rank)
	if (J?.no_jobban_from_this_job)
		return FALSE

	var/list/banned_roles = apiHandler.queryAPI("jobbans/get/roles", list("ckey" = M.ckey), 1)

	if(!banned_roles || banned_roles.len)
		return FALSE

	if(rank in banned_roles)
		return TRUE
	else
		return FALSE

/proc/jobban_unban(mob/M, rank)
	if (!M?.ckey || rank) return

	var/query[] = new()
	query["ckey"] = M.ckey
	query["rank"] = rank

	apiHandler.queryAPI("jobbans/remove", query, 1)

	return TRUE
