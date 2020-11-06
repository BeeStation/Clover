///// FOR EXPORTING DATA TO A SERVER /////

// Called in world.dm at new()
/proc/round_start_data(var/attempt = 1)
	set background = 1

	var/message[] = new()
	message["token"] = md5(config.goonhub_parser_key)
	message["round_name"] = url_encode(station_name())
	message["round_server"]  = config.server_id
	message["round_server_number"] = "[serverKey]"
	message["round_status"] = "start"

	var/datum/http_request/request = http_create_post("[config.goonhub_parser_url][list2params(message)]")
	request.begin_async()
	AWAIT(request.is_complete())
	var/datum/http_response/response = request.into_response()
	if(response.errored)
		if(attempt >= 5)
			logTheThing( "diary", null, null, "maximum roundstart data upload attempts exceeded" )
			return
		logTheThing( "diary", null, null, "failed to upload roundstart data: [response.errored]" )
		sleep(100)
		round_start_data(attempt + 1)



// Called in gameticker.dm at the end of the round.
/proc/round_end_data(var/reason, var/attempt = 1)
	set background = 1

	var/message[] = new()
	message["token"] = md5(config.goonhub_parser_key)
	message["round_name"] = url_encode(station_name())
	message["round_server"]  = config.server_id
	message["round_server_number"] = "[serverKey]"
	message["round_status"] = "end"
	message["end_reason"] = reason
	message["game_type"] = ticker && ticker.mode ? ticker.mode.name : "pre"

	var/datum/http_request/request = http_create_post("[config.goonhub_parser_url][list2params(message)]")
	request.begin_async()
	AWAIT(request.is_complete())
	var/datum/http_response/response = request.into_response()
	if(response.errored)
		if(attempt >= 5)
			logTheThing( "diary", null, null, "maximum roundend data upload attempts exceeded" )
			return
		logTheThing( "diary", null, null, "failed to upload roundend data: [response.errored]" )
		sleep(100)
		round_end_data(reason, attempt + 1)
