local GetGuildInfoCommand = class("GetGuildInfoCommand", pm.SimpleCommand)

function GetGuildInfoCommand:execute(arg_1_1)
	local var_1_0 = arg_1_1:getBody()

	if not getProxy(GuildProxy):getRawData() and not getProxy(GuildProxy).isFetchMainInfo then
		pg.ConnectionMgr.GetInstance():Send(60037, {
			type = 0
		}, 60000, function(arg_2_0)
			getProxy(GuildProxy).isFetchMainInfo = true

			self:sendNotification(GAME.GET_GUILD_INFO_DONE)
		end)
	else
		self:sendNotification(GAME.GET_GUILD_INFO_DONE)
	end
end

return GetGuildInfoCommand
