local mod_storage = minetest.get_mod_storage()
local default_color = '#ffd700' -- gold
local priv_name = 'msg_color'


local function get_color(name)

	-- get the player's color from the db
	local color = mod_storage:get_string(name .. '_color')

	-- get the default color, in case the player has not set their desired color
	color = color ~= "" and color or default_color

	return color
end


minetest.register_privilege("msg_color", {
	description = "Can use colored chat messages",
	give_to_singleplayer = false,
	give_to_admin = false
})


minetest.register_chatcommand(priv_name, {
	description = "Get or set the player's chat message color",
	params = "[<color>]",
	privs = {msg_color = true},
	func = function(name, param)

		local color

		-- case 1, no params received. we display the configured color
		if param == '' then
			color = get_color(name)

		-- case 2, a param received. we attempt to store in db
		else
			color = param
			mod_storage:set_string(name .. '_color', color)
		end

		return true, "Your chat color is set to " .. minetest.colorize(color, color)
	end
})


minetest.register_on_chat_message(
	function(name, msg)

		-- if the chatting player does not have correct privs, do nothing
		-- we immediately return false to mark this message as NOT handled,
		-- which means another mod will handle the message.
		if not minetest.check_player_privs(name, priv_name) then
			return false


		-- the player does have correct privs, means we go ahead and handle the message
		else
			local color = get_color(name)
			minetest.chat_send_all(minetest.colorize(color, '<' .. name .. '> ' .. msg))

			if yl_matterbridge then
		                yl_matterbridge.send_to_bridge(name, msg)
			end
			return true -- we return true to mark this chat message as handled
		end






	end
)

