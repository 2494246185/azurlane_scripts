local IslandHeartBeatCommand = class("IslandHeartBeatCommand", pm.SimpleCommand)

function IslandHeartBeatCommand:execute(arg_1_1)
	pg.ConnectionMgr.GetInstance():Send(21215, {
		island_id = arg_1_1:getBody().islandId
	})
end

return IslandHeartBeatCommand
