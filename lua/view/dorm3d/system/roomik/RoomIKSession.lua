local RoomIKSession = class("RoomIKSession")

function RoomIKSession:Ctor()
	self.generation = 0
	self.active = false
	self.mode = nil
	self.currentIkStatus = nil
	self.currentIkConfig = nil
	self.currentIkTimelineStatus = nil
	self.stockingCachedIkStatus = nil
	self.aimIKCachedIkStatus = nil
	self.ikSpecialCall = nil
	self.ikActionDict = nil
	self.readyIKLayers = nil
	self.ikTouchDatas = nil
	self.ikSettings = nil
	self.ladyEnv = nil
	self.ikRoot = nil
	self.boneMaps = nil
	self.controllers = nil
	self.ikHandler = nil
	self.ikTimelineColliderStates = nil
	self.ikNextCheckStamp = nil
	self.nextTipIKTime = nil
	self.enableIKTip = false
	self.blockIK = nil
	self.uiBlockHeld = false
	self.blockReasons = {}
	self.ikSwitchSkinId = nil
	self.spec = nil
end

function RoomIKSession:Start(arg_2_1)
	self.generation = self.generation + 1
	self.active = true
	self.mode = arg_2_1
	self.blockReasons = {}
	self.blockIK = nil

	return self.generation
end

function RoomIKSession:IsCurrent(arg_3_1)
	return self.active and self.generation == arg_3_1
end

function RoomIKSession:ApplySpec(arg_4_1)
	assert(arg_4_1, "Missing RoomIK session spec")

	self.spec = arg_4_1
	self.mode = arg_4_1.mode

	if arg_4_1.mode == "normal" then
		self.currentIkStatus = arg_4_1.statusId or nil
	end

	if arg_4_1.mode == "normal" then
		self.currentIkConfig = arg_4_1.config or nil
	end

	if arg_4_1.mode == "timeline" then
		self.currentIkTimelineStatus = arg_4_1.statusId or nil
	end

	self.ladyEnv = arg_4_1.ladyEnv
	self.ikActionDict = arg_4_1.actionDict
	self.readyIKLayers = arg_4_1.layers
	self.ikTouchDatas = arg_4_1.touchDatas
	self.ikRoot = arg_4_1.ikRoot
	self.boneMaps = arg_4_1.boneMaps
	self.controllers = arg_4_1.controllers
	self.ikSettings = {
		Colliders = arg_4_1.colliders,
		CameraRaycaster = arg_4_1.raycaster
	}
end

function RoomIKSession:IsBlocked()
	return next(self.blockReasons) ~= nil
end

function RoomIKSession:RefreshBlockState()
	self.blockIK = self:IsBlocked() or nil
end

function RoomIKSession:AcquireBlock(arg_7_1)
	self.blockReasons[arg_7_1 or "legacy"] = true

	self:RefreshBlockState()
end

function RoomIKSession:ReleaseBlock(arg_8_1)
	self.blockReasons[arg_8_1 or "legacy"] = nil

	self:RefreshBlockState()
end

function RoomIKSession:SetLegacyBlock(arg_9_1)
	if arg_9_1 then
		self:AcquireBlock("legacy")
	else
		self:ReleaseBlock("legacy")
	end
end

function RoomIKSession:ClearBlocks()
	self.blockReasons = {}

	self:RefreshBlockState()
end

function RoomIKSession:ClearRuntime()
	self.generation = self.generation + 1
	self.active = false
	self.mode = nil
	self.currentIkStatus = nil
	self.currentIkConfig = nil
	self.currentIkTimelineStatus = nil
	self.spec = nil
	self.ikActionDict = nil
	self.readyIKLayers = nil
	self.ikTouchDatas = nil
	self.ikSettings = nil
	self.ladyEnv = nil
	self.ikRoot = nil
	self.boneMaps = nil
	self.controllers = nil
	self.ikHandler = nil
	self.ikNextCheckStamp = nil
	self.nextTipIKTime = nil
	self.enableIKTip = false
	self.blockIK = nil
	self.blockReasons = {}
end

function RoomIKSession:Invalidate()
	self:ClearRuntime()

	self.stockingCachedIkStatus = nil
	self.aimIKCachedIkStatus = nil
	self.ikSpecialCall = nil
	self.ikTimelineColliderStates = nil
	self.ikSwitchSkinId = nil
	self.uiBlockHeld = false
end

return RoomIKSession
