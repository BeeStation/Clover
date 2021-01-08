/**
 * Allows sending a message to a specified chat, given a custom tag.
 *
 * @param message The text for the message we're sending
 * @param channel_tag The tag (set in the TGS control panel) to send the message to. This is optional, and sends to all channels if not specified. Setting to -1 will send to admins only (yes this is jank)
 * @return nothing
 */
/proc/discord_send(message, channel_tag = null)
	if(!world.TgsAvailable())
		return

	// send everywhere
	if(channel_tag == null)
		world.TgsTargetedChatBroadcast(message, FALSE)
	else if(channel_tag == -1)
		world.TgsTargetedChatBroadcast(message, TRUE)
	else
		var/datum/tgs_version/V = world.TgsApiVersion()
		if(V.suite < 4)
			// Running TGS 3
			world.TgsTargetedChatBroadcast(message, FALSE)
		else
			var/list/datum/tgs_chat_channel/channels = list()
			// API version 4 or later
			for(var/datum/tgs_chat_channel/C in world.TgsChatChannelInfo())
				if(C.custom_tag == channel_tag)
					channels += C
			world.TgsChatBroadcast(message, channels)
