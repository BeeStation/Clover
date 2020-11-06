// Viewing a player's notes
/datum/admins/proc/viewPlayerNotes(var/player)
	if (!player)
		return

	if(src.tempmin)
		logTheThing("admin", usr, player, "tried to access the notes of [constructTarget(player,"admin")]")
		logTheThing("diary", usr, player, "tried to access the notes of [constructTarget(player,"diary")]", "admin")
		alert("You need to be an actual admin to view player notes.")
		return

	if (!config.player_notes_baseurl || !config.player_notes_auth)
		alert("Missing configuration for player notes")
		return

	var/list/data = list(
		"auth" = config.player_notes_auth,
		"action" = "get",
		"ckey" = player
	)

	var/datum/http_request/request = http_create_get("[config.player_notes_baseurl]/?[list2params(data)]")
	request.begin_async()
	AWAIT(request.is_complete())
	var/datum/http_response/response = request.into_response()

	if(response.errored)
		alert("Query Failed: [response.errored].")
		return

	var/content = response.body

	var/deletelinkpre = "<A href='?src=\ref[src];action=notes2;target=[player];type=del;id="
	var/deletelinkpost = "'>(DEL)"

	var/regex/R = new("!!ID(\\d+)", "g")
	content = R.Replace(content, "[deletelinkpre]$1[deletelinkpost]") // What the fuck?

	var/dat = "<h1>Player Notes for <b>[player]</b></h1><HR><br><A href='?src=\ref[src];action=notes2;target=[player];type=add'>Add Note</A><br><HR>"
	dat += replacetext(content, "\n", "<br>")
	usr.Browse(dat, "window=notesp;size=875x400;title=Notes for [player]")


// Adding a player note
/proc/addPlayerNote(player, admin, note)
	if (!player || !admin || !note)
		return

	if (!config.player_notes_baseurl || !config.player_notes_auth)
		alert("Missing configuration for player notes")
		return

	var/list/data = list(
		"auth" = config.player_notes_auth,
		"action" = "add",
		"server" = serverKey,
		"server_id" = config.server_id,
		"ckey" = player,
		"akey" = admin,
		"note" = note
	)

	var/datum/http_request/request = http_create_post("[config.player_notes_baseurl]/?[list2params(data)]")
	request.begin_async()
	AWAIT(request.is_complete())
	var/datum/http_response/response = request.into_response()
	if(response.errored)
		alert("Failed to add note: [response.errored]")

// Deleting a player note
/proc/deletePlayerNote(id)
	if (!id)
		return

	if (!config.player_notes_baseurl || !config.player_notes_auth)
		alert("Missing configuration for player notes")
		return

	var/list/data = list(
		"auth" = config.player_notes_auth,
		"action" = "delete",
		"id" = id
	)

	var/datum/http_request/request = http_create_post("[config.player_notes_baseurl]/?[list2params(data)]")
	request.begin_async()
	AWAIT(request.is_complete())
	var/datum/http_response/response = request.into_response()
	if(response.errored)
		alert("Failed to add note: [response.errored]")
