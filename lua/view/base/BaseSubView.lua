local BaseSubView = class("BaseSubView", import("view.base.BaseEventLogic"))

BaseSubView.STATES = {
	LOADED = 3,
	DESTROY = 5,
	LOADING = 2,
	INITED = 4,
	NONE = 1
}

function BaseSubView:Ctor(arg_1_1, arg_1_2, arg_1_3)
	BaseSubView.super.Ctor(self, arg_1_2)

	self.contextData = arg_1_3
	self._parentTf = arg_1_1
	self.event = arg_1_2
	self._go = nil
	self._tf = nil
	self._state = BaseSubView.STATES.NONE
	self._funcQueue = {}
end

BaseSubView.InheritFuncs = {
	"getGroupName",
	"Add2Overlay",
	"DelFromOverlay",
	"OverlayPanel",
	"UnOverlayPanel",
	"BlurPanel",
	"TempOverlayPanelPB",
	"TempUnOverlayPanelPB"
}

local function var_0_1(arg_2_0)
	local var_2_0

	if arg_2_0 and arg_2_0.getUIName then
		local var_2_1, var_2_2 = pcall(function()
			return arg_2_0:getUIName()
		end)

		if var_2_1 then
			var_2_0 = var_2_2
		end
	end

	if not noEmptyStr(var_2_0) and arg_2_0 then
		var_2_0 = arg_2_0.__cname
	end

	return tostring(var_2_0 or "Unknown")
end

local function var_0_2(arg_4_0)
	local var_4_0 = string.format("进入界面: BaseSubView - %s", var_0_1(arg_4_0))

	print(var_4_0)

	local var_4_1, var_4_2 = pcall(function()
		ReflectionHelp.RefCallMethod(typeof(ResourceMgr), "WriteMarkedShortPathLog", ResourceMgr.Inst, {
			typeof("System.String")
		}, {
			var_4_0
		})
	end)

	if not var_4_1 then
		warning(string.format("Write base sub view load log failed: %s", tostring(var_4_2)))
	end
end

function BaseSubView:RegisterView(arg_6_1)
	self.viewComponent = arg_6_1

	for iter_6_0, iter_6_1 in ipairs(BaseSubView.InheritFuncs) do
		self[iter_6_1] = self[iter_6_1] or function(arg_7_0, ...)
			return arg_7_0.viewComponent[iter_6_1](arg_7_0.viewComponent, ...)
		end
	end
end

function BaseSubView:Load(arg_8_1)
	if self._state ~= BaseSubView.STATES.NONE then
		return
	end

	if EDITOR_TOOL then
		var_0_2(self)
	end

	self._state = BaseSubView.STATES.LOADING

	pg.UIMgr.GetInstance():LoadingOn()

	local var_8_0 = PoolMgr.GetInstance()

	seriesAsync({
		function(arg_9_0)
			SplitPackConst.DownloadByLuaArr(self:getResource(self.contextData), arg_9_0)
		end,
		function(arg_10_0)
			if arg_8_1 then
				self.noReturnPrefab = true

				arg_10_0(arg_8_1)
			else
				var_8_0:GetUI(self:getUIName(), true, arg_10_0)
			end
		end
	}, function(arg_11_0)
		if self._state == BaseSubView.STATES.DESTROY and not self.noReturnPrefab then
			pg.UIMgr.GetInstance():LoadingOff()
			var_8_0:ReturnUI(self:getUIName(), arg_11_0)
		else
			self:Loaded(arg_11_0)
			self:Init()
		end
	end)
end

function BaseSubView:Loaded(arg_12_1)
	pg.UIMgr.GetInstance():LoadingOff()

	if self._state ~= BaseSubView.STATES.LOADING then
		return
	end

	self._state = BaseSubView.STATES.LOADED
	self._go = arg_12_1
	self._tf = tf(arg_12_1)

	setActiveViaLayer(self._tf, true)
	pg.DelegateInfo.New(self)

	if self._tf.parent ~= self._parentTf then
		SetParent(self._tf, self._parentTf, false)
	end

	bindComponent(self, self._go)
	self:OnLoaded()
end

function BaseSubView:Init()
	if self._state ~= BaseSubView.STATES.LOADED then
		return
	end

	self._state = BaseSubView.STATES.INITED

	self:OnInit()
	self:HandleFuncQueue()
end

function BaseSubView:Destroy()
	if self._state == BaseSubView.STATES.DESTROY then
		return
	end

	if not self:GetLoaded() then
		self._state = BaseSubView.STATES.DESTROY

		return
	end

	self._state = BaseSubView.STATES.DESTROY

	pg.DelegateInfo.Dispose(self)
	self:OnDestroy()
	bindComponent(self, self._go, true)
	self:disposeEvent()
	self:cleanManagedTween()

	self._tf = nil

	if self._go ~= nil and not self.noReturnPrefab then
		PoolMgr.GetInstance():ReturnUI(self:getUIName(), self._go)

		self._go = nil
	end

	self.noReturnPrefab = nil
end

function BaseSubView:HandleFuncQueue()
	if self._state == BaseSubView.STATES.INITED then
		while #self._funcQueue > 0 do
			local var_15_0 = table.remove(self._funcQueue, 1)

			var_15_0.func(unpackEx(var_15_0.params))
		end
	end
end

function BaseSubView:Reset()
	self._state = BaseSubView.STATES.NONE
end

function BaseSubView:ActionInvoke(arg_17_1, ...)
	assert(self[arg_17_1], "func not exist >>>" .. arg_17_1)

	self._funcQueue[#self._funcQueue + 1] = {
		funcName = arg_17_1,
		func = self[arg_17_1],
		params = packEx(self, ...)
	}

	self:HandleFuncQueue()
end

function BaseSubView:ActionInvokeExclusive(arg_18_1, ...)
	while #self._funcQueue > 0 do
		if self._funcQueue[#self._funcQueue].funcName == arg_18_1 then
			table.remove(self._funcQueue, #self._funcQueue)
		end
	end

	self:ActionInvoke(arg_18_1, ...)
end

function BaseSubView:CallbackInvoke(arg_19_1, ...)
	self._funcQueue[#self._funcQueue + 1] = {
		func = arg_19_1,
		params = packEx(...)
	}

	self:HandleFuncQueue()
end

function BaseSubView:ExecuteAction(arg_20_1, ...)
	self:Load()
	self:ActionInvoke(arg_20_1, ...)
end

function BaseSubView:GetLoaded()
	return self._state >= BaseSubView.STATES.LOADED
end

function BaseSubView:CheckState(arg_22_1)
	return self._state == arg_22_1
end

function BaseSubView:Show()
	setActive(self._tf, true)
	self:ShowOrHideResUI(true)
	self:PlayBGM()
end

function BaseSubView:Hide()
	setActive(self._tf, false)
	self:ShowOrHideResUI(false)
	self:StopBgm()
end

function BaseSubView:isShowing()
	return self._tf and isActive(self._tf) or false
end

function BaseSubView:getBGM(arg_26_1)
	return getBgm(arg_26_1 or self.__cname)
end

function BaseSubView:PlayBGM()
	local var_27_0 = self:getBGM()

	if var_27_0 then
		pg.BgmMgr.GetInstance():Push(self.__cname, var_27_0)
	end
end

function BaseSubView:StopBgm()
	pg.BgmMgr.GetInstance():Pop(self.__cname)
end

function BaseSubView:getTpl(arg_29_1, arg_29_2)
	local var_29_0 = (arg_29_2 or self._tf):Find(arg_29_1)

	var_29_0:SetParent(self._tf, false)
	SetActive(var_29_0, false)

	return var_29_0
end

function BaseSubView:getUIName()
	return nil
end

function BaseSubView:getResource()
	return {
		"ui/" .. self:getUIName()
	}
end

function BaseSubView:OnLoaded()
	return
end

function BaseSubView:OnInit()
	return
end

function BaseSubView:OnDestroy()
	return
end

function BaseSubView:ResUISettings()
	return nil
end

function BaseSubView:ShowOrHideResUI(arg_36_1)
	local var_36_0 = self:ResUISettings()

	if not var_36_0 then
		return
	end

	if var_36_0 == true then
		var_36_0 = {
			anim = true,
			showType = PlayerResUI.TYPE_ALL
		}
	end

	local var_36_1 = self:getGroupName()

	if arg_36_1 then
		pg.playerResUI:SetSettings(var_36_1, setmetatable({
			groupName = var_36_1
		}, {
			__index = var_36_0
		}))
	else
		pg.playerResUI:RemoveSettings(var_36_1)
	end
end

function BaseSubView:getGroupName()
	return self.contextData.groupName or self.__cname
end

return BaseSubView
