local GetPublicGuildUserDataCommand = class("GetPublicGuildUserDataCommand", pm.SimpleCommand)

function GetPublicGuildUserDataCommand:execute(arg_1_1)
	local var_1_0 = arg_1_1:getBody()

	seriesAsync({
		function(arg_2_0)
			self:CreatePublicGuild(arg_2_0)
		end,
		function(arg_3_0)
			self:InitPublicGuild(arg_3_0)
		end
	}, function()
		self:sendNotification(GAME.HANDLE_GUILD_AND_PUBLIC_GUILD_TECH)
		self:sendNotification(GAME.GET_PUBLIC_GUILD_USER_DATA_DONE)
	end)
end

function GetPublicGuildUserDataCommand:CreatePublicGuild(arg_5_1)
	pg.ConnectionMgr.GetInstance():Send(62100, {
		type = 0
	}, 62101, function(arg_6_0)
		getProxy(GuildProxy):AddPublicGuild((PublicGuild.New(arg_6_0)))
		arg_5_1()
	end)
end

function GetPublicGuildUserDataCommand:InitPublicGuild(arg_7_1)
	pg.ConnectionMgr.GetInstance():Send(60102, {
		type = 0
	}, 60103, function(arg_8_0)
		getProxy(GuildProxy):GetPublicGuild():InitUser(arg_8_0.user_info)
		arg_7_1()
	end)
end

return GetPublicGuildUserDataCommand
