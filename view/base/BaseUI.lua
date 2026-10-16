local BaseUI = class("BaseUI", import("view.base.BaseEventLogic"))

BaseUI.LOADED = "BaseUI:LOADED"
BaseUI.DID_ENTER = "BaseUI:DID_ENTER"
BaseUI.AVALIBLE = "BaseUI:AVALIBLE"
BaseUI.DID_EXIT = "BaseUI:DID_EXIT"
BaseUI.ON_BACK = "BaseUI:ON_BACK"
BaseUI.ON_RETURN = "BaseUI:ON_RETURN"
BaseUI.ON_HOME = "BaseUI:ON_HOME"
BaseUI.ON_CLOSE = "BaseUI:ON_CLOSE"
BaseUI.ON_DROP = "BaseUI.ON_DROP"
BaseUI.ON_DROP_LIST = "BaseUI.ON_DROP_LIST"
BaseUI.ON_DROP_LIST_OWN = "BaseUI.ON_DROP_LIST_OWN"
BaseUI.ON_NEW_DROP = "BaseUI.ON_NEW_DROP"
BaseUI.ON_NEW_STYLE_DROP = "BaseUI.ON_NEW_STYLE_DROP"
BaseUI.ON_NEW_STYLE_ITEMS = "BaseUI.ON_NEW_STYLE_ITEMS"
BaseUI.ON_ITEM = "BaseUI:ON_ITEM"
BaseUI.ON_ITEM_EXTRA = "BaseUI.ON_ITEM_EXTRA"
BaseUI.ON_SHIP = "BaseUI:ON_SHIP"
BaseUI.ON_AWARD = "BaseUI:ON_AWARD"
BaseUI.ON_ACHIEVE = "BaseUI:ON_ACHIEVE"
BaseUI.ON_ACHIEVE_AUTO = "BaseUI:ON_ACHIEVE_AUTO"
BaseUI.ON_WORLD_ACHIEVE = "BaseUI:ON_WORLD_ACHIEVE"
BaseUI.ON_EQUIPMENT = "BaseUI:ON_EQUIPMENT"
BaseUI.ON_SPWEAPON = "BaseUI:ON_SPWEAPON"
BaseUI.ON_SHIP_EXP = "BaseUI.ON_SHIP_EXP"
BaseUI.ON_BACK_PRESSED = "BaseUI:ON_BACK_PRESS"
BaseUI.ON_ADD_SUBLAYER = "BaseUI:ON_ADD_SUBLAYER"
BaseUI.ON_GO_SCENE = "BaseUI:ON_GO_SCENE"

function BaseUI:Ctor()
	BaseUI.super.Ctor(self)

	self._isLoaded = false
	self._go = nil
	self._tf = nil
	self._isCachedView = false
end

function BaseUI:setContextData(arg_2_1)
	self.contextData = arg_2_1
end

function BaseUI:getUIName()
	return nil
end

function BaseUI:getGroupName()
	return self.contextData.groupName or self.__cname
end

function BaseUI:getDefaultUI()
	return self._tf
end

function BaseUI:preloadUIList()
	return {
		self:getUIName()
	}
end

function BaseUI:getResource()
	local var_7_0 = {}

	_.each({
		self:getBGM()
	}, function(arg_8_0)
		if noEmptyStr(arg_8_0) then
			_.each(ResPathSupport.GetSoundResList(arg_8_0), function(arg_9_0)
				table.insert(var_7_0, arg_9_0)
			end)
		end
	end)
	_.each(self:preloadUIList(), function(arg_10_0)
		if noEmptyStr(arg_10_0) then
			table.insert(var_7_0, (ResPathSupport.CombinePath(ResPathSupport.ConstPath.UI.Base, arg_10_0)))
		end
	end)

	return var_7_0
end

function BaseUI:needCache()
	return false
end

function BaseUI:tempCache()
	return false
end

function BaseUI:forceGC()
	return false
end

function BaseUI:DontGC()
	return false
end

function BaseUI:forceRatio()
	return nil
end

function BaseUI:loadingQueue()
	return false
end

function BaseUI:setLayerMgrRegister(arg_17_1)
	if not self.contextData then
		return
	end

	local var_17_0 = self:getGroupName()

	if arg_17_1 then
		pg.LayerWeightMgr.GetInstance():RegisterGroupWeight(var_17_0)
	else
		pg.LayerWeightMgr.GetInstance():RemoveGroupWeight(var_17_0)
	end
end

function BaseUI:preload(arg_18_1)
	arg_18_1()
end

function BaseUI:loadUISync(arg_19_1)
	local var_19_0 = LoadAndInstantiateSync("UI", arg_19_1, true, false)

	var_19_0.transform:SetParent(pg.UIMgr.GetInstance().UIMain.transform, false)

	return var_19_0
end

function BaseUI:GCWhenAwake()
	return tobool(self:loadingQueue())
end

function BaseUI:load()
	self:setLayerMgrRegister(true)

	local var_21_0
	local var_21_1 = Time.realtimeSinceStartup
	local var_21_2 = self:getUIName()

	seriesAsync({
		function(arg_22_0)
			if self:GCWhenAwake() then
				gcAll(true)
			end

			self:preload(arg_22_0)
		end,
		function(arg_23_0)
			self:LoadUIFromPool(var_21_2, function(arg_24_0)
				print("Loaded " .. var_21_2)

				var_21_0 = arg_24_0

				arg_23_0()
			end)
		end
	}, function()
		originalPrint("load " .. var_21_0.name .. " time cost: " .. Time.realtimeSinceStartup - var_21_1)
		self:SetUIParent(var_21_0)

		if self:CheckTempCache() then
			PoolMgr.GetInstance():KeepUICache(var_21_2, true)
		end

		self:onUILoaded(var_21_0)
	end)
end

function BaseUI:SetUIParent(arg_26_1)
	arg_26_1.transform:SetParent(pg.UIMgr.GetInstance().UIMain.transform, false)
end

function BaseUI:LoadUIFromPool(arg_27_1, arg_27_2)
	PoolMgr.GetInstance():GetUI(arg_27_1, true, arg_27_2)
end

function BaseUI:getBGM(arg_28_1)
	return getBgm(arg_28_1 or self.__cname)
end

function BaseUI:PlayBGM()
	local var_29_0 = self:getBGM()

	if var_29_0 then
		pg.BgmMgr.GetInstance():Push(self.__cname, var_29_0)
	end
end

function BaseUI:StopBgm()
	if not self.contextData then
		return
	end

	if self.contextData.isLayer then
		pg.BgmMgr.GetInstance():Pop(self.__cname)
	else
		pg.BgmMgr.GetInstance():Clear()
	end
end

function BaseUI:isLoaded()
	return self._isLoaded
end

function BaseUI:CheckTempCache()
	return self:tempCache() and self:isLayer()
end

function BaseUI:isLayer()
	return self.contextData ~= nil and self.contextData.isLayer
end

function BaseUI:Add2Overlay(arg_34_1, arg_34_2)
	if not self.contextData then
		return
	end

	arg_34_2 = arg_34_2 or {}
	arg_34_2.groupName = self:getGroupName()

	pg.LayerWeightMgr.GetInstance():Add2Overlay(arg_34_1, arg_34_2)
end

function BaseUI:DelFromOverlay(arg_35_1, ...)
	if not self.contextData then
		return
	end

	pg.LayerWeightMgr.GetInstance():DelFromOverlay(arg_35_1, ...)
end

function BaseUI:OverlayPanel(arg_36_1, arg_36_2)
	arg_36_2 = arg_36_2 or {}
	arg_36_2.type = LayerWeightConst.UI_TYPE_SUB

	self:Add2Overlay(arg_36_1, arg_36_2)
end

function BaseUI:BlurPanel(arg_37_1, arg_37_2)
	arg_37_2 = arg_37_2 or {}
	arg_37_2.type = LayerWeightConst.UI_TYPE_SUB
	arg_37_2.globalBlur = true

	self:Add2Overlay(arg_37_1, arg_37_2)
end

function BaseUI:UnOverlayPanel(arg_38_1, arg_38_2)
	self:DelFromOverlay(arg_38_1, arg_38_2 or self.UIMain)
end

function BaseUI:TempOverlayPanelPB(arg_39_1, arg_39_2)
	if not self.contextData then
		return
	end

	arg_39_2 = arg_39_2 or {}
	arg_39_2.groupName = self:getGroupName()

	pg.UIMgr.GetInstance():TempOverlayPanelPB(arg_39_1, arg_39_2)
end

function BaseUI:TempUnOverlayPanelPB(arg_40_1, arg_40_2)
	if not self.contextData then
		return
	end

	pg.UIMgr.GetInstance():TempUnOverlayPanelPB(arg_40_1, arg_40_2)
end

BaseUI.optionsPath = {
	"option",
	"top/option",
	"top/left_top/option",
	"blur_container/top/title/option",
	"blur_container/top/option",
	"top/top/option",
	"common/top/option",
	"blur_panel/top/option",
	"blurPanel/top/option",
	"blur_container/top/option",
	"top/title/option",
	"blur_panel/adapt/top/option",
	"mainPanel/top/option",
	"bg/top/option",
	"blur_container/adapt/top/title/option",
	"blur_container/adapt/top/option",
	"ForNorth/top/option",
	"top/top_chapter/option",
	"Main/blur_panel/adapt/top/option",
	"adapt/blur_panel/adapt/top/option"
}

function BaseUI:onUILoaded(arg_41_1)
	self._go = arg_41_1
	self._tf = arg_41_1 and arg_41_1.transform

	self:Add2Overlay(self:getDefaultUI(), {
		type = LayerWeightConst.UI_TYPE_SYSTEM
	})
	pg.SeriesGuideMgr.GetInstance():dispatch({
		view = self.__cname
	})
	pg.NewStoryMgr.GetInstance():OnSceneEnter({
		view = self.__cname
	})

	self._isLoaded = true

	pg.DelegateInfo.New(self)

	self.optionBtns = {}

	for iter_41_0, iter_41_1 in ipairs(self.optionsPath) do
		table.insert(self.optionBtns, self._tf:Find(iter_41_1))
	end

	setActiveViaLayer(self._tf, true)
	bindComponent(self, self._go)
	self:init()
	self:emit(BaseUI.LOADED)
end

function BaseUI:ResUISettings()
	return nil
end

function BaseUI:ShowOrHideResUI(arg_43_1)
	local var_43_0 = self:ResUISettings()

	if not var_43_0 then
		return
	end

	if var_43_0 == true then
		var_43_0 = {
			anim = true,
			showType = PlayerResUI.TYPE_ALL
		}
	end

	local var_43_1 = self:getGroupName()

	if arg_43_1 then
		pg.playerResUI:SetSettings(var_43_1, setmetatable({
			groupName = var_43_1
		}, {
			__index = var_43_0
		}))
	else
		pg.playerResUI:RemoveSettings(var_43_1)
	end
end

function BaseUI:onUIAnimEnd(arg_44_1)
	arg_44_1()
end

function BaseUI:init()
	return
end

function BaseUI:quickExitFunc()
	self:emit(BaseUI.ON_HOME)
end

function BaseUI:quickExit()
	for iter_47_0, iter_47_1 in ipairs(self.optionBtns) do
		onButton(self, iter_47_1, function()
			self:quickExitFunc()
		end, SFX_PANEL)
	end
end

function BaseUI:enter()
	self:quickExit()
	self:PlayBGM()
	self:emit(BaseUI.DID_ENTER)

	if self:forceRatio() then
		pg.CameraFixMgr.GetInstance():SetForceRatio(self:forceRatio())
	end

	if not self._isCachedView then
		self:didEnter()
		self:ShowOrHideResUI(true)
	end

	if tobool(self:loadingQueue()) and self.contextData.resumeCallback then
		self.contextData.resumeCallback = nil

		self.contextData.resumeCallback()
	end

	self:emit(BaseUI.AVALIBLE)
	self:onUIAnimEnd(function()
		pg.SeriesGuideMgr.GetInstance():start({
			view = self.__cname,
			code = {
				pg.SeriesGuideMgr.CODES.MAINUI
			}
		})
		pg.NewGuideMgr.GetInstance():OnSceneEnter({
			view = self.__cname
		})
	end)
end

function BaseUI:closeView()
	if self.contextData.isLayer then
		self:emit(BaseUI.ON_CLOSE)
	else
		self:emit(BaseUI.ON_BACK)
	end
end

function BaseUI:didEnter()
	return
end

function BaseUI:willExit()
	return
end

function BaseUI:exit()
	self.exited = true

	self:StopBgm()
	pg.DelegateInfo.Dispose(self)
	self:willExit()
	bindComponent(self, self._go, true)
	self:ShowOrHideResUI(false)
	self:DelFromOverlay(self:getDefaultUI())
	self:setLayerMgrRegister(false)
	self:detach()

	if self:forceRatio() then
		pg.CameraFixMgr.GetInstance():SetForceRatio(nil)
	end

	pg.NewGuideMgr.GetInstance():OnSceneExit({
		view = self.__cname
	})
	pg.NewStoryMgr.GetInstance():OnSceneExit({
		view = self.__cname
	})
	self:emit(BaseUI.DID_EXIT)
end

function BaseUI:PlayUIAnimation(arg_55_1, arg_55_2, arg_55_3)
	local var_55_0 = arg_55_1:GetComponent(typeof(UIEventTrigger))

	var_55_0.didExit:RemoveAllListeners()
	var_55_0.didExit:AddListener(function()
		var_55_0.didExit:RemoveAllListeners()
		arg_55_3()
	end)
	arg_55_1:GetComponent(typeof(Animation)):Play(arg_55_2)
end

function BaseUI:attach(arg_57_1)
	return
end

function BaseUI:ClearTweens(arg_58_1)
	self:cleanManagedTween(arg_58_1)
end

function BaseUI:detach(arg_59_1)
	self._isLoaded = false

	pg.DynamicBgMgr.GetInstance():ClearBg(self:getUIName())
	self:disposeEvent()
	self:ClearTweens(false)

	self._tf = nil

	local var_59_0 = self:getUIName()

	if self._go ~= nil and var_59_0 then
		PoolMgr.GetInstance():ReturnUI(var_59_0, self._go)

		self._go = nil
	end
end

function BaseUI:getTpl(arg_60_1, arg_60_2)
	local var_60_0 = (arg_60_2 or self._tf):Find(arg_60_1)

	var_60_0:SetParent(self._tf, false)
	SetActive(var_60_0, false)

	return var_60_0
end

function BaseUI:setSpriteTo(arg_61_1, arg_61_2, arg_61_3)
	local var_61_0 = arg_61_2:GetComponent(typeof(Image))

	var_61_0.sprite = self._tf:Find(arg_61_1):GetComponent(typeof(Image)).sprite

	if arg_61_3 then
		var_61_0:SetNativeSize()
	end
end

function BaseUI:setImageAmount(arg_62_1, arg_62_2)
	arg_62_1:GetComponent(typeof(Image)).fillAmount = arg_62_2
end

function BaseUI:setVisible(arg_63_1)
	self:ShowOrHideResUI(arg_63_1)

	if arg_63_1 then
		self:OnVisible()
	else
		self:OnDisVisible()
	end

	setActiveViaLayer(self._tf, arg_63_1)
end

function BaseUI:OnVisible()
	return
end

function BaseUI:OnDisVisible()
	return
end

function BaseUI:onBackPressed()
	self:emit(BaseUI.ON_BACK_PRESSED)
end

return BaseUI
