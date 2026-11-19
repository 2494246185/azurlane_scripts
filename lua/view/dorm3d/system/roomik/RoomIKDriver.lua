local RoomIKDriver = class("RoomIKDriver")

function RoomIKDriver:Ctor()
	self.session = nil
	self.generation = nil
	self.callbacks = nil
	self.attached = false
	self.envRegistered = false
end

function RoomIKDriver:IsCurrent()
	return self.attached and self.session and self.session:IsCurrent(self.generation)
end

function RoomIKDriver:Forward(arg_3_1, ...)
	if not self:IsCurrent() then
		return
	end

	existCall(self.callbacks and self.callbacks[arg_3_1], ...)
end

function RoomIKDriver:Attach(arg_4_1, arg_4_2)
	assert(arg_4_1, "Missing RoomIK session")
	assert(arg_4_1.controllers, "Missing RoomIK controllers")

	if #arg_4_1.controllers == 0 then
		self:Detach()

		return
	end

	assert(arg_4_1.ikRoot, "Missing RoomIK IK root")
	assert(arg_4_1.boneMaps, "Missing RoomIK bone maps")
	self:Detach()

	self.session = arg_4_1
	self.generation = arg_4_1.generation
	self.callbacks = arg_4_2 or {}

	local var_4_0 = pg.IKMgr.GetInstance()

	var_4_0:RegisterEnv(arg_4_1.ikRoot, arg_4_1.boneMaps)

	self.envRegistered = true
	self.attached = true

	var_4_0:RegisterOnIKLayerActive(function(arg_5_0)
		self:Forward("active", arg_5_0)
	end)
	var_4_0:RegisterOnIKLayerDrag(function(arg_6_0)
		self:Forward("drag", arg_6_0)
	end)
	var_4_0:RegisterOnIKLayerDeactive(function(arg_7_0, arg_7_1)
		self:Forward("deactive", arg_7_0, arg_7_1)
	end)
	var_4_0:RegisterOnIKLayerAction(function(arg_8_0)
		self:Forward("action", arg_8_0)
	end)
	var_4_0:SetIKStatus(arg_4_1.controllers)
end

function RoomIKDriver:Detach()
	self.attached = false
	self.envRegistered = false
	self.callbacks = nil
	self.session = nil
	self.generation = nil

	if not self.envRegistered then
		return
	end

	local var_9_0 = pg.IKMgr.GetInstance()

	var_9_0:ReleaseDrag()
	var_9_0:UnregisterEnv()
end

function RoomIKDriver:BeginDrag(arg_10_1, arg_10_2)
	if not self:IsCurrent() then
		return
	end

	pg.IKMgr.GetInstance():OnDragBegin(arg_10_1, arg_10_2)
end

function RoomIKDriver:Drag(arg_11_1)
	if not self:IsCurrent() then
		return
	end

	pg.IKMgr.GetInstance():HandleBodyDrag(arg_11_1)
end

function RoomIKDriver:Release()
	if not self.attached then
		return
	end

	pg.IKMgr.GetInstance():ReleaseDrag()
end

function RoomIKDriver:Reset(arg_13_1)
	if not self:IsCurrent() then
		return
	end

	pg.IKMgr.GetInstance():ResetIK(arg_13_1)
end

function RoomIKDriver:ResetActiveLayers()
	if not self:IsCurrent() then
		return
	end

	pg.IKMgr.GetInstance():ResetActiveIKs()
end

function RoomIKDriver:PlayMove(arg_15_1, arg_15_2, arg_15_3, arg_15_4, arg_15_5, arg_15_6)
	if not self:IsCurrent() then
		return
	end

	pg.IKMgr.GetInstance():PlayIKMove(arg_15_1, arg_15_2, arg_15_3, arg_15_4, arg_15_5, arg_15_6)
end

return RoomIKDriver
