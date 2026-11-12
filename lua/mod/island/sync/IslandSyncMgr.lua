local IslandSyncMgr = class("IslandSyncMgr")

IslandSyncMgr.ISLAND_SYNC_DATA_UPDATE = "IslandSyncMgr.ISLAND_SYNC_DATA_UPDATE"

function IslandSyncMgr:Ctor(arg_1_1)
	self.controlResultDic = {}
	self.controller = arg_1_1
	self.island = arg_1_1.island
	self.agency = arg_1_1.island:GetInteractSyncAgency()
	self.playerId = getProxy(PlayerProxy):getPlayerId()
	self.presented = {}
	self.readyVisitors = {}
	self.editSuspended = false
	self.syncDataDelayedProcessor = DelayedDataProcessor.New(IslandConst.SYNC_TIME_DELAY, IslandConst.SYNC_TIME_INTERVAL * 1000, function(arg_2_0)
		self:UpdateVisitorSyncData(arg_2_0)
	end)
	self.collectClientStateTimer = Timer.New(function()
		self:UpdateLocalPlayer()
	end, IslandConst.SYNC_TIME_INTERVAL, -1)
end

function IslandSyncMgr:Op(arg_4_1, ...)
	self.controller:Receive(arg_4_1, ...)
end

function IslandSyncMgr:Init(arg_5_1)
	self.presented = {}
	self.readyVisitors = {}
	self.editSuspended = false

	self.syncDataDelayedProcessor:Dispose()
	self:InitPlayer(arg_5_1)
	self:StartReconcile()
	self.collectClientStateTimer:Start()
end

function IslandSyncMgr:StartReconcile()
	self:ClearLocalResidualOccupy()

	for iter_6_0, iter_6_1 in ipairs(self.agency:GetAllUnitIds()) do
		if self.agency:AnySlotUsing(iter_6_1) then
			self:ReconcileUnit(iter_6_1)
		else
			local var_6_0 = self.agency:GetStatus(iter_6_1)

			if var_6_0 and var_6_0 > 0 then
				self:OpInitStatus(self.agency:GetSyncType(iter_6_1), iter_6_1, var_6_0)
			end
		end
	end
end

function IslandSyncMgr:ClearLocalResidualOccupy()
	for iter_7_0, iter_7_1 in ipairs((self.agency:GetUnitsByOwner(self.playerId))) do
		self:EndControlUnit(self.agency:GetSyncType(iter_7_1), iter_7_1, function(arg_8_0)
			return
		end)
	end
end

function IslandSyncMgr:Update()
	self.syncDataDelayedProcessor:Update()
end

function IslandSyncMgr:IsPlayerInTimeline()
	return self.agency:IsLocalInteracting()
end

function IslandSyncMgr:InitPlayer(arg_11_1)
	self.player = SyncLocalPlayer.New(self.playerId, arg_11_1)
end

function IslandSyncMgr:OnVisitorUnitReady(arg_12_1)
	self.readyVisitors[arg_12_1] = true

	for iter_12_0, iter_12_1 in ipairs((self.agency:GetUnitsByOwner(arg_12_1))) do
		self:ReconcileUnit(iter_12_1)
	end
end

function IslandSyncMgr:IsVisitorReady(arg_13_1)
	return self.readyVisitors[arg_13_1] == true
end

function IslandSyncMgr:OnVisitorExit(arg_14_1)
	self.readyVisitors[arg_14_1] = nil

	if self.agency:OnVisitorExit(arg_14_1) then
		for iter_14_0, iter_14_1 in ipairs((self.agency:RemoveOwner(arg_14_1))) do
			self:ReconcileUnit(iter_14_1.unitId)
		end
	end

	self.syncDataDelayedProcessor:RemoveDataById(arg_14_1)
end

function IslandSyncMgr:UpdateLocalPlayer()
	if table.getCount(self.island:GetVisitorAgency():GetMapVisitorList()) <= 1 then
		return
	end

	local var_15_0 = {}

	if self.player:IsLoaded() and not self.agency:IsLocalInteracting() then
		table.insert(var_15_0, (self.player:CreateSyncData()))
	end

	if #var_15_0 > 0 then
		pg.m02:sendNotification(GAME.ISLAND_SYNC_DATA, {
			data = var_15_0,
			islandId = self.island.id
		})
	end
end

function IslandSyncMgr:HandleSyncData(arg_16_1)
	_.each(arg_16_1, function(arg_17_0)
		self.syncDataDelayedProcessor:Add(arg_17_0.id, arg_17_0)
	end)
end

function IslandSyncMgr:UpdateVisitorSyncData(arg_18_1)
	if not self.island:GetVisitorAgency():GetMapVisitorList()[arg_18_1.id] then
		Debugger.LogWarning(string.format("访客不存在 id=%d", arg_18_1.id))

		return
	end

	self:Op("SetVisitorSyncData", arg_18_1.id, arg_18_1)
end

function IslandSyncMgr:ReconcileUnit(arg_19_1, arg_19_2)
	local var_19_0 = self.agency:GetSyncType(arg_19_1)

	if not var_19_0 then
		return
	end

	if self.editSuspended and var_19_0 == IslandConst.SYNC_TYPE_AGORA then
		return
	end

	local var_19_1 = self.agency:GetOccupiedSlots(arg_19_1) or {}
	local var_19_2 = self.presented[arg_19_1] or {}
	local var_19_3 = self.agency:GetStatus(arg_19_1)

	for iter_19_0, iter_19_1 in pairs(var_19_2) do
		if var_19_1[iter_19_0] ~= iter_19_1 then
			self.presented[arg_19_1][iter_19_0] = nil

			self:OpInteractEnd(var_19_0, arg_19_1, iter_19_1, iter_19_0)
		end
	end

	for iter_19_2, iter_19_3 in pairs(var_19_1) do
		if var_19_2[iter_19_2] ~= iter_19_3 then
			if iter_19_2 == 0 then
				if iter_19_3 == self.playerId and arg_19_2 == "local" then
					self:MarkPresentedAndStart(arg_19_1, iter_19_2, iter_19_3, arg_19_2, var_19_3)
				end
			elseif iter_19_3 == self.playerId then
				if arg_19_2 == "local" then
					self:MarkPresentedAndStart(arg_19_1, iter_19_2, iter_19_3, arg_19_2, var_19_3)
				end
			elseif self:IsVisitorReady(iter_19_3) then
				self:MarkPresentedAndStart(arg_19_1, iter_19_2, iter_19_3, arg_19_2, var_19_3)
			end
		end
	end
end

function IslandSyncMgr:OnOccupancyChanged(arg_20_1)
	self:ReconcileUnit(arg_20_1)
end

function IslandSyncMgr:MarkPresentedAndStart(arg_21_1, arg_21_2, arg_21_3, arg_21_4, arg_21_5)
	self.presented[arg_21_1] = self.presented[arg_21_1] or {}
	self.presented[arg_21_1][arg_21_2] = arg_21_3

	self:OpInteractStart(self.agency:GetSyncType(arg_21_1), arg_21_1, arg_21_3, arg_21_5, arg_21_2)
end

function IslandSyncMgr:OpInteractStart(arg_22_1, arg_22_2, arg_22_3, arg_22_4, arg_22_5)
	if arg_22_5 == 0 then
		self:Op("AgoraVirtualShipInterActionSync", arg_22_2, arg_22_3, arg_22_4, arg_22_5)

		return
	end

	if arg_22_1 == IslandConst.SYNC_TYPE_AGORA then
		self:Op("AgoraVirtualInterActionSync", arg_22_2, arg_22_3, arg_22_4, arg_22_5)
	elseif arg_22_1 == IslandConst.SYNC_TYPE_UNIT_STATIC then
		self:Op("WorldObjectInterActionSync", arg_22_2, arg_22_3, arg_22_4, arg_22_5)
	else
		return
	end

	self.syncDataDelayedProcessor:RemoveDataById(arg_22_3)
end

function IslandSyncMgr:OpInteractEnd(arg_23_1, arg_23_2, arg_23_3, arg_23_4)
	if arg_23_4 == 0 then
		self:Op("AgoraVirtualShipInterActionEndSync", arg_23_2, arg_23_3, arg_23_4)

		return
	end

	if arg_23_1 == IslandConst.SYNC_TYPE_AGORA then
		self:Op("AgoraVirtualInterActionEndSync", arg_23_2, arg_23_3, arg_23_4)
	elseif arg_23_1 == IslandConst.SYNC_TYPE_UNIT_STATIC then
		self:Op("WorldObjectInterActionEndSync", arg_23_2, arg_23_3, arg_23_4)
	end
end

function IslandSyncMgr:OpInitStatus(arg_24_1, arg_24_2, arg_24_3)
	if arg_24_1 == IslandConst.SYNC_TYPE_UNIT_STATIC then
		self:Op("WorldObjectInitStatus", arg_24_2, arg_24_3)
	elseif arg_24_1 == IslandConst.SYNC_TYPE_AGORA then
		self:Op("AgoraVirtualInitStatus", arg_24_2, arg_24_3)
	end
end

function IslandSyncMgr:TryControlUnit(arg_25_1, arg_25_2, arg_25_3, arg_25_4, arg_25_5)
	if self.agency:IsLocalInteracting() then
		arg_25_5(false)

		return
	end

	if self.agency:GetSyncType(arg_25_2) ~= arg_25_1 then
		arg_25_5(false)

		return
	end

	self:ControlUnit(arg_25_2, arg_25_3, 1, arg_25_4, arg_25_1, function(arg_26_0)
		if arg_26_0 then
			self.agency:ApplyLocalOccupy(arg_25_2, arg_25_3, self.playerId, arg_25_4)
			self:ReconcileUnit(arg_25_2, "local")
		end

		arg_25_5(arg_26_0)
	end)
end

function IslandSyncMgr:EndControlUnit(arg_27_1, arg_27_2, arg_27_3)
	local var_27_0 = self.agency:GetSlotByOwner(arg_27_2, self.playerId)

	if not var_27_0 then
		arg_27_3(false)

		return
	end

	self:ControlUnit(arg_27_2, var_27_0, 0, self.agency:GetStatus(arg_27_2), arg_27_1, function(arg_28_0)
		if arg_28_0 then
			self.agency:ApplyLocalRelease(arg_27_2, var_27_0, self.playerId)
			self:ReconcileUnit(arg_27_2, "local")
		end

		arg_27_3(arg_28_0)
	end)
end

function IslandSyncMgr:ControlUnit(arg_29_1, arg_29_2, arg_29_3, arg_29_4, arg_29_5, arg_29_6)
	if self.controlResultDic[arg_29_1] then
		arg_29_6(false)

		return
	end

	self.controlResultDic[arg_29_1] = arg_29_6

	pg.m02:sendNotification(GAME.ISLAND_SYNC_CONTROL, {
		islandId = self.island.id,
		objId = arg_29_1,
		slotId = arg_29_2,
		op = arg_29_3,
		status = arg_29_4,
		type = arg_29_5,
		onResult = function(arg_30_0)
			existCall(self.controlResultDic[arg_29_1], arg_30_0 == 0)

			self.controlResultDic[arg_29_1] = nil
		end
	})
end

function IslandSyncMgr:StopAgoraPresentation()
	for iter_31_0, iter_31_1 in pairs(self.presented) do
		if self.agency:GetSyncType(iter_31_0) == IslandConst.SYNC_TYPE_AGORA then
			for iter_31_2, iter_31_3 in pairs(iter_31_1) do
				self:OpInteractEnd(IslandConst.SYNC_TYPE_AGORA, iter_31_0, iter_31_3, iter_31_2)
			end

			self.presented[iter_31_0] = nil
		end
	end
end

function IslandSyncMgr:SuspendAgoraInteract()
	self:StopAgoraPresentation()

	self.editSuspended = true
end

function IslandSyncMgr:ResumeAgoraPresentation()
	if not self.editSuspended then
		return
	end

	self.editSuspended = false

	for iter_33_0, iter_33_1 in ipairs(self.agency:GetUnitIdsByType(IslandConst.SYNC_TYPE_AGORA)) do
		self:ReconcileUnit(iter_33_1)
	end
end

function IslandSyncMgr:StopAgoraInteraction()
	self:StopAgoraPresentation()
	self.agency:ClearByType(IslandConst.SYNC_TYPE_AGORA, true)
end

function IslandSyncMgr:ClearAgoraInteractData()
	self.agency:ClearByType(IslandConst.SYNC_TYPE_AGORA, true)

	for iter_35_0 in pairs(self.presented) do
		if self.agency:GetSyncType(iter_35_0) == nil then
			self.presented[iter_35_0] = nil
		end
	end
end

function IslandSyncMgr:Dispose()
	self.collectClientStateTimer:Stop()
	self.syncDataDelayedProcessor:Dispose()
end

return IslandSyncMgr
