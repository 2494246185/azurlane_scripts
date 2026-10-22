local CourtYardScene = class("CourtYardScene", import("..base.BaseUI"))

function CourtYardScene:forceGC()
	return true
end

function CourtYardScene:getUIName()
	return "CourtYardUI"
end

CourtYardScene.AggressivePreloadResList = {
	"ui/BackYardMsgBox",
	"ui/CourtyardUI_atlas",
	"ui/BackyardFeedUI",
	"ui/BackYardFeedShopPanel",
	"ui/BackYardFeedExtendPanel",
	"ui/NewBackYardShipInfoUI",
	"shipframeb",
	"shiptype",
	"ui/proposeShipCard",
	"ui/NewBackYardShopUI",
	"ui/NewBackYardShopUI_atlas",
	"ui/BackYardThemePage",
	"ui/BackYardThemeInfoPage",
	"ui/BackYardFurniturePage",
	"ui/FurnitureMsgboxPage",
	"ui/ThemeMsgboxPage",
	"ui/BackYardIndexUI",
	"BackYardTheme/theme_1",
	"BackYardTheme/1",
	"furnitureicon/default_theme",
	"QIcon/unknown",
	"weaponframes",
	"ui/BackYardInterActionPreview",
	"ui/BackYardDecorationUI",
	"ui/NewBackYardDecorateUI_atlas",
	"ui/BackYardDecorationThemePage",
	"ui/BackYardDecorationFurniturePage",
	"ui/BackYardPutListPage",
	"ui/BackYardDecorationMsgBox",
	"ui/BackYardDecorationDescUI",
	"ui/BackYardStatisticsUI",
	"UI/CourtYardStoreyModule",
	"UI/CourtYardFeastStoreyModule",
	"UI/CourtYardStoreyPreviewModule",
	"ui/CourtYardFurniture",
	"ui/CourtYardGrid",
	"ui/CourtYardShip",
	"ui/CourtYardWallGrid",
	"Effect/Heart"
}

function CourtYardScene:getResource()
	local var_3_0 = CourtYardScene.super.getResource(self)
	local var_3_1 = {}

	for iter_3_0, iter_3_1 in ipairs(var_3_0) do
		var_3_1[iter_3_1] = true
	end

	for iter_3_2, iter_3_3 in ipairs(CourtYardScene.AggressivePreloadResList) do
		if not var_3_1[iter_3_3] then
			var_3_1[iter_3_3] = true

			table.insert(var_3_0, iter_3_3)
		end
	end

	for iter_3_4, iter_3_5 in pairs((getProxy(DormProxy):getData():GetPurchasedFurnitures())) do
		if not var_3_1["furnitureicon/" .. pg.furniture_data_template[iter_3_5.id].icon] then
			var_3_1["furnitureicon/" .. pg.furniture_data_template[iter_3_5.id].icon] = true

			table.insert(var_3_0, "furnitureicon/" .. pg.furniture_data_template[iter_3_5.id].icon)
		end

		if pg.furniture_data_template[iter_3_5.id].type == 1 and pg.furniture_data_template[iter_3_5.id].tag == 3 then
			for iter_3_6 = 1, 4 do
				if not var_3_1[("furnitrues/" .. pg.furniture_data_template[iter_3_5.id].picture) .. iter_3_6] then
					var_3_1[("furnitrues/" .. pg.furniture_data_template[iter_3_5.id].picture) .. iter_3_6] = true

					table.insert(var_3_0, ("furnitrues/" .. pg.furniture_data_template[iter_3_5.id].picture) .. iter_3_6)
				end
			end
		elseif not var_3_1["furnitrues/" .. pg.furniture_data_template[iter_3_5.id].picture] then
			var_3_1["furnitrues/" .. pg.furniture_data_template[iter_3_5.id].picture] = true

			table.insert(var_3_0, "furnitrues/" .. pg.furniture_data_template[iter_3_5.id].picture)
		end
	end

	for iter_3_7 = 1, 4 do
		if not var_3_1["furnitrues/base/road_" .. iter_3_7] then
			var_3_1["furnitrues/base/road_" .. iter_3_7] = true

			table.insert(var_3_0, "furnitrues/base/road_" .. iter_3_7)
		end

		if not var_3_1["furnitrues/base/wall_" .. iter_3_7] then
			var_3_1["furnitrues/base/wall_" .. iter_3_7] = true

			table.insert(var_3_0, "furnitrues/base/wall_" .. iter_3_7)
		end
	end

	return var_3_0
end

function CourtYardScene:PlayBGM()
	pg.BgmMgr.GetInstance():StopPlay()
end

function CourtYardScene:preload(arg_5_1)
	_BackyardMsgBoxMgr = BackyardMsgBoxMgr.New()

	_BackyardMsgBoxMgr:Init(self, arg_5_1)
end

function CourtYardScene:SetDorm(arg_6_1)
	self.dorm = arg_6_1
end

function CourtYardScene:init()
	self.contextData.floor = self.contextData.floor or 1
	self.panels = {
		CourtYardLeftPanel.New(self),
		CourtYardRightPanel.New(self),
		CourtYardTopPanel.New(self),
		CourtYardBottomPanel.New(self)
	}
	self.mainTF = self._tf:Find("main")
	self.mainCG = GetOrAddComponent(self.mainTF, typeof(CanvasGroup))
	self.bg = self._tf:Find("bg000")
	self.animation = self._tf:GetComponent(typeof(Animation))
	self.emptyFoodPage = CourtYardEmptyFoodPage.New(self._tf, self.event)
end

function CourtYardScene:didEnter()
	self:BlockEvents()
	self:SetUpCourtYard()
	self:FlushMainView()

	self.bulinTip = AprilFoolBulinSubView.ShowAprilFoolBulin(self)
end

function CourtYardScene:OnCourtYardLoaded()
	pg.OSSMgr.GetInstance():Init()
	self:AddVisitorShip()

	if self.contextData.mode ~= CourtYardConst.SYSTEM_VISIT then
		BackYardThemeTempalteUtil.CheckSaveDirectory()
		pg.m02:sendNotification(GAME.OPEN_ADD_EXP, 1)
	end

	self:UnBlockEvents()

	if self.contextData.OpenShop then
		triggerButton(self:GetPanel(CourtYardBottomPanel).shopBtn)
	end
end

function CourtYardScene:UpdateDorm(arg_10_1, arg_10_2)
	self:SetDorm(arg_10_1)
	self:FlushMainView(arg_10_2)
end

function CourtYardScene:SetUpCourtYard()
	seriesAsync({
		function(arg_12_0)
			if (self.contextData.mode or CourtYardConst.SYSTEM_VISIT) ~= CourtYardConst.SYSTEM_VISIT then
				arg_12_0()

				return
			end

			self:emit(CourtYardMediator.ON_ADD_VISITOR_SHIP, arg_12_0)
		end
	}, function()
		self:emit(CourtYardMediator.SET_UP, self.contextData.floor)
	end)
end

function CourtYardScene:FlushMainView(arg_14_1)
	local var_14_0 = {}

	for iter_14_0, iter_14_1 in ipairs(self.panels) do
		table.insert(var_14_0, function(arg_15_0)
			iter_14_1:Flush(self.dorm, arg_14_1)
			onNextTick(arg_15_0)
		end)
	end

	seriesAsync(var_14_0)
end

function CourtYardScene:SwitchFloorDone()
	for iter_16_0, iter_16_1 in ipairs(self.panels) do
		iter_16_1:UpdateFloor(self.dorm)
	end
end

function CourtYardScene:ShowAddFoodTip()
	if self.contextData.mode ~= CourtYardConst.SYSTEM_VISIT and self.dorm.food == 0 and not self.contextData.OpenShop then
		if not pg.NewGuideMgr.GetInstance():IsBusy() and self.dorm:GetFloorShipCnt(DormShip.FLOOR_1) > 0 and (not self.contextData.fromMediatorName or self.contextData.fromMediatorName ~= "DockyardMediator" and self.contextData.fromMediatorName ~= "ShipMainMediator") and not self.contextData.skipToCharge then
			self.emptyFoodPage:ExecuteAction("Flush")

			self.contextData.fromMain = nil
		end
	end

	self.contextData.skipToCharge = nil
end

function CourtYardScene:AddVisitorShip()
	if self.contextData.mode == CourtYardConst.SYSTEM_VISIT then
		return
	end

	if self.contextData.floor ~= 1 then
		return
	end

	if not getProxy(PlayerProxy):getRawData():GetCommonFlag(SHOW_FIREND_BACKYARD_SHIP_FLAG) then
		return
	end

	local var_18_0 = getProxy(DormProxy):GetVisitorShip()

	if var_18_0 then
		_courtyard:GetController():AddVisitorShip(var_18_0)
	end
end

function CourtYardScene:FoldPanel(arg_19_1)
	if arg_19_1 then
		self.animation:Play("anim_courtyard_mainui_hide")
	else
		self.animation:Play("anim_courtyard_mainui_in")
	end
end

function CourtYardScene:OnEnterOrExitEdit(arg_20_1)
	for iter_20_0, iter_20_1 in ipairs(self.panels) do
		iter_20_1:OnEnterOrExitEdit(arg_20_1)
	end

	Input.multiTouchEnabled = not arg_20_1
end

function CourtYardScene:BlockEvents()
	self.mainCG.blocksRaycasts = false
end

function CourtYardScene:UnBlockEvents()
	self.mainCG.blocksRaycasts = true
end

function CourtYardScene:OnRemoveLayer(arg_23_1)
	for iter_23_0, iter_23_1 in ipairs(self.panels) do
		iter_23_1:OnRemoveLayer(arg_23_1.context.mediator)
	end
end

function CourtYardScene:OnReconnection()
	pg.m02:sendNotification(GAME.OPEN_ADD_EXP, 1)
end

function CourtYardScene:OnAddFurniture()
	self:GetPanel(CourtYardTopPanel):OnFlush(BackYardConst.DORM_UPDATE_TYPE_LEVEL)
end

function CourtYardScene:GetPanel(arg_26_1)
	for iter_26_0, iter_26_1 in ipairs(self.panels) do
		if isa(iter_26_1, arg_26_1) then
			return iter_26_1
		end
	end
end

function CourtYardScene:onBackPressed()
	for iter_27_0, iter_27_1 in ipairs(self.panels) do
		if iter_27_1:onBackPressed() then
			return
		end
	end

	if _courtyard then
		_courtyard:GetController():OnBackPressed()
	else
		CourtYardScene.super.onBackPressed(self)
	end
end

function CourtYardScene:willExit()
	_BackyardMsgBoxMgr:Destroy()

	_BackyardMsgBoxMgr = nil

	for iter_28_0, iter_28_1 in ipairs(self.panels) do
		iter_28_1:Detach()
	end

	self.emptyFoodPage:Destroy()

	self.emptyFoodPage = nil

	if self.bulinTip then
		self.bulinTip:Destroy()

		self.bulinTip = nil
	end

	if self.contextData.mode ~= CourtYardConst.SYSTEM_VISIT then
		pg.m02:sendNotification(GAME.OPEN_ADD_EXP, 0)
	end

	getProxy(DormProxy):getRawData():ClearNewFlag()
end

return CourtYardScene
