local IslandProxy = class("IslandProxy", import("model.proxy.NetProxy"))

IslandProxy.STORY_START = "IslandProxy:STORY_START"
IslandProxy.STORY_END = "IslandProxy:STORY_END"
IslandProxy.PERFORMANCE_START = "IslandProxy:PERFORMANCE_START"
IslandProxy.PERFORMANCE_END = "IslandProxy:PERFORMANCE_END"
IslandProxy.START_PATHFINDER = "IslandProxy:START_PATHFINDER"
IslandProxy.END_PATHFINDER = "IslandProxy:END_PATHFINDER"
IslandProxy.ACTIVE_OR_DISABLE_UNIT = "IslandProxy:ACTIVE_OR_DISABLE_UNIT"
IslandProxy.LINK_CORE = "IslandProxy:LINK_CORE"
IslandProxy.GEN_RECYCLEITEM = "IslandProxy:GEN_RECYCLEITEM"
IslandProxy.LOCK_NPC_REFRESH = "IslandProxy:LOCK_NPC_REFRESH"
IslandProxy.RELEASE_NPC_REFRESH = "IslandProxy:RELEASE_NPC_REFRESH"
IslandProxy.RESET_SP = "IslandProxy:RESET_SP"
IslandProxy.PRESS_BACK = "IslandProxy:PRESS_BACK"
IslandProxy.CHAT_MSG_UPDATE = "IslandProxy:CHAT_MSG_UPDATE"

function IslandProxy:register()
	self.cahce = {}
	self.giftCache = {}
	self.chatMsgs = {}
	self.islandHeartBeatMgr = IslandHeartBeatMgr.New()

	self:on(21216, function(arg_2_0)
		local var_2_0 = self:GetIsland()

		if not var_2_0 then
			return
		end

		for iter_2_0, iter_2_1 in ipairs(arg_2_0.visitor_list) do
			local var_2_1 = IslandVisitorLog.New(iter_2_1)

			if not var_2_1:IsSelf() then
				var_2_0:GetAccessAgency():AddVisitorLog(var_2_1)
				pg.IslandVisitorNotificationMgr.GetInstance():Enqueue(var_2_1)
			end
		end
	end)
end

function IslandProxy:AddChatMsg(arg_3_1, arg_3_2)
	self.chatMsgs[arg_3_1] = self.chatMsgs[arg_3_1] or {}

	table.insert(self.chatMsgs[arg_3_1], arg_3_2)
	self:sendNotification(IslandProxy.CHAT_MSG_UPDATE, {
		islandId = arg_3_1,
		msg = arg_3_2
	})
end

function IslandProxy:GetChatMsgList(arg_4_1)
	return self.chatMsgs[arg_4_1] or {}
end

function IslandProxy:SetIsland(arg_5_1)
	self.island = arg_5_1
end

function IslandProxy:GetIsland()
	return self.island
end

function IslandProxy:ShouldTip()
	return (function()
		local var_8_0 = self:GetIsland()

		return var_8_0 and var_8_0:CanLevelUp()
	end)() or (function()
		local var_9_0 = self:GetIsland()

		return var_9_0 and var_9_0:AnyProsperityAwardCanGet()
	end)()
end

function IslandProxy:AddPlayerDataCache(arg_10_1)
	self.cahce[arg_10_1.id] = arg_10_1
end

function IslandProxy:GetPlayerDataCache(arg_11_1)
	return self.cahce[arg_11_1]
end

function IslandProxy:ClearAllPlayerDataCache()
	self.cahce = {}
end

function IslandProxy:AddGiftTagInfoCache(arg_13_1)
	self.giftCache[arg_13_1.playerId] = arg_13_1
end

function IslandProxy:GetGiftTagInfoCache(arg_14_1)
	return self.giftCache[arg_14_1]
end

function IslandProxy:UpdateGiftTagCache(arg_15_1, arg_15_2, arg_15_3)
	local var_15_0 = self:GetGiftTagInfoCache(arg_15_1)

	if var_15_0 then
		var_15_0:Flush(arg_15_2, arg_15_3)
	else
		self:AddGiftTagInfoCache((IslandGiftTagInfo.New({
			key = arg_15_1,
			value1 = arg_15_3,
			value2 = arg_15_2
		})))
	end
end

function IslandProxy:ClearAllGiftTagInfo()
	self.giftCache = {}
end

function IslandProxy:SetSharedIsland(arg_17_1)
	self.sharedIsland = arg_17_1
end

function IslandProxy:GetSharedIsland()
	return self.sharedIsland
end

function IslandProxy:timeCall()
	return {
		[ProxyRegister.SecondCall] = function(arg_20_0)
			if not self.island then
				return
			end

			self.island:UpdatePerSecond()

			if not self.sharedIsland then
				return
			end

			self.sharedIsland:UpdatePerSecond()
		end,
		[ProxyRegister.HourCall] = function(arg_21_0)
			if not self.island then
				return
			end

			self.island:UpdatePerHour(arg_21_0)

			if not self.sharedIsland then
				return
			end

			self.sharedIsland:UpdatePerHour(arg_21_0)
		end,
		[ProxyRegister.DayCall] = function(arg_22_0)
			if not self.island then
				return
			end

			self.island:UpdatePerDay()
		end
	}
end

function IslandProxy:RecordEnterTime()
	self.enterTimeStamp = pg.TimeMgr.GetInstance():GetServerTime()
end

function IslandProxy:GetEnterTime()
	return self.enterTimeStamp
end

function IslandProxy:RecordTempPlayerPosition(arg_25_1, arg_25_2, arg_25_3)
	self.tempPlayerPosition = {
		arg_25_1,
		arg_25_2,
		arg_25_3
	}
end

function IslandProxy:GetTempPlayerPosition()
	return self.tempPlayerPosition
end

function IslandProxy:EnterIsland(arg_27_1)
	self.islandHeartBeatMgr:EnterIsland(arg_27_1)
end

function IslandProxy:ExitIsland()
	self.islandHeartBeatMgr:ExitIsland()
end

function IslandProxy:remove()
	self.island = nil

	self.islandHeartBeatMgr:Dispose()

	self.islandHeartBeatMgr = nil
end

return IslandProxy
