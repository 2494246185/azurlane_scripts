local IslandHeartBeatMgr = class("IslandHeartBeatMgr")

function IslandHeartBeatMgr:Ctor()
	self.heartBeatTimer = Timer.New(function()
		self:SendHeartBeat()
	end, IslandConst.HEART_BEAT_INTERVAL, -1)
	self.islandId = nil
	self.lastHeartBeatTime = 0
end

function IslandHeartBeatMgr:SendHeartBeat()
	if not self.islandId then
		return
	end

	local var_3_0 = pg.TimeMgr.GetInstance():GetServerTime()

	if self.lastHeartBeatTime ~= 0 and var_3_0 - self.lastHeartBeatTime > IslandConst.HEART_BEAT_WARN_INTERVAL then
		warning("心跳时间间隔异常", self.lastHeartBeatTime, var_3_0)
	end

	self.lastHeartBeatTime = var_3_0

	pg.m02:sendNotification(GAME.ISLAND_HEART_BEAT, {
		islandId = self.islandId
	})
end

function IslandHeartBeatMgr:EnterIsland(arg_4_1)
	self.islandId = arg_4_1
	self.lastHeartBeatTime = 0

	self.heartBeatTimer:Stop()
	self.heartBeatTimer:Start()
end

function IslandHeartBeatMgr:ExitIsland()
	self.heartBeatTimer:Stop()

	self.islandId = nil
end

function IslandHeartBeatMgr:Dispose()
	if self.heartBeatTimer then
		self.heartBeatTimer:Stop()

		self.heartBeatTimer = nil
	end
end

return IslandHeartBeatMgr
