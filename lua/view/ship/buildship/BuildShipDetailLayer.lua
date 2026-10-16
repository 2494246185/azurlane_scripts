local BuildShipDetailLayer = class("BuildShipDetailLayer", import("...base.BaseUI"))
local var_0_2 = 2
local var_0_3 = 1
local var_0_5 = {
	"resources/1",
	"resources/2",
	"resources/3",
	"resources/1"
}

function BuildShipDetailLayer:getResource()
	local var_1_0 = {
		"ui/building"
	}

	for iter_1_0, iter_1_1 in ipairs(pg.ship_data_create_material.all) do
		if pg.ship_data_create_material[iter_1_1] then
			if noEmptyStr(pg.ship_data_create_material[iter_1_1].ship_icon) then
				table.insert(var_1_0, ResPathSupport.ConstPath.UI.ShipModelBuliding .. pg.ship_data_create_material[iter_1_1].ship_icon)
			end

			if noEmptyStr(pg.ship_data_create_material[iter_1_1].build_anim) then
				table.insert(var_1_0, ResPathSupport.CombinePath(ResPathSupport.ConstPath.UI.Base, pg.ship_data_create_material[iter_1_1].build_anim))
			end
		end
	end

	return table.insertto(var_1_0, BuildShipDetailLayer.super.getResource(self))
end

function BuildShipDetailLayer:getUIName()
	return "BuildShipDetailUI1"
end

function BuildShipDetailLayer:setItems(arg_3_1)
	self.itemVO = arg_3_1[ITEM_ID_EQUIP_QUICK_FINISH] or {
		count = 0,
		id = ITEM_ID_EQUIP_QUICK_FINISH
	}
end

function BuildShipDetailLayer:setWorkCount(arg_4_1)
	self.workCount = arg_4_1
end

function BuildShipDetailLayer:setBuildSpeedUpRemind(arg_5_1)
	self.isStopSpeedUpRemind = arg_5_1
end

BuildShipDetailLayer.MODEL_INDEX = 2

function BuildShipDetailLayer:setProjectList(arg_6_1)
	self.projectList = arg_6_1

	if #self.projectList > BuildShipDetailLayer.MODEL_INDEX then
		self.MODEL = var_0_2 or var_0_3
	end
end

function BuildShipDetailLayer:init()
	self.multLineTF = self._tf:Find("list_mult_line")
	self.multLineContain = self._tf:Find("list_mult_line/content")
	self.multLineTpl = self.multLineContain:Find("project_tpl")
	self.multList = UIItemList.New(self.multLineContain, self.multLineTpl)
	self.singleLineTF = self._tf:Find("list_single_line")
	self.singleLineContain = self._tf:Find("list_single_line/content")
	self.singleLineTpl = self.singleLineContain:Find("project_tpl")
	self.singleList = UIItemList.New(self.singleLineContain, self.singleLineTpl)
	self.listCountTF = self._tf:Find("title/value")
	self.quickCount = self._tf:Find("adapt/quick_count")
	self.quickCountTF = self._tf:Find("adapt/quick_count/value")
	self.noneBg = self._tf:Find("none_bg")
	self.allLaunch = self._tf:Find("adapt/all_launch")
	self.aniBgTF = self._tf:Find("aniBg")
	self.autoLockShipToggle = self._tf:Find("adapt/autolockship/Toggle"):GetComponent(typeof(Toggle))
	self.canvasgroup = GetOrAddComponent(self._tf, typeof(CanvasGroup))

	setText(self._tf:Find("title/text"), i18n("build_detail_intro"))
	setText(self._tf:Find("adapt/autolockship/Text"), i18n("lock_new_ship"))
end

function BuildShipDetailLayer:updatePlayer(arg_8_1)
	self._player = arg_8_1
end

function BuildShipDetailLayer:didEnter()
	self.projectTFs = {}

	self.multList:make(function(arg_10_0, arg_10_1, arg_10_2)
		if arg_10_0 == UIItemList.EventUpdate then
			arg_10_2.gameObject.name = "project_" .. arg_10_1 + 1
			self.projectTFs[arg_10_1 + 1] = arg_10_2

			self:updateProject(arg_10_1 + 1, self.projectList[arg_10_1 + 1])
		end
	end)
	self.singleList:make(function(arg_11_0, arg_11_1, arg_11_2)
		if arg_11_0 == UIItemList.EventUpdate then
			arg_11_2.gameObject.name = "project_" .. arg_11_1 + 1
			self.projectTFs[arg_11_1 + 1] = arg_11_2

			self:updateProject(arg_11_1 + 1, self.projectList[arg_11_1 + 1])
		end
	end)
	self:initProjectList()
	self:updateItem()
	self:updateListCount()
	self.aniBgTF.transform:SetParent(GameObject.Find("Overlay/UIOverlay").transform, false)
	onButton(self, self.allLaunch, function()
		local var_12_0 = self:getNeedCount()

		if var_12_0 > 0 and not self.isStopSpeedUpRemind then
			local var_12_1 = pg.MsgboxMgr.GetInstance()
			local var_12_2 = {
				showStopRemind = true
			}

			var_12_2.content = i18n("ship_buildShipScene_quest_quickFinish", var_12_0, (self.itemVO.count == 0 or nil) and (COLOR_RED or COLOR_GREEN), self.itemVO.count)
			var_12_2.stopRamindContent = i18n("common_dont_remind_dur_login")

			function var_12_2.onYes()
				self:emit(BuildShipDetailMediator.LAUNCH_ALL, var_12_1.stopRemindToggle.isOn)
			end

			var_12_1:ShowMsgBox(var_12_2)
		elseif #self.projectList > 0 then
			self:emit(BuildShipDetailMediator.LAUNCH_ALL)
		else
			pg.TipsMgr.GetInstance():ShowTips(i18n("ship_getShip_error_noShip"))
		end
	end, SFX_UI_BUILDING_FASTBUILDING)
	onButton(self, self.quickCount, function()
		shoppingBatch(61009, {
			id = ShopConst.GetShopConfig(61009).effect_args[1]
		}, 9, "build_ship_quickly_buy_tool")
	end)

	local var_9_0 = pg.settings_other_template[22]
	local var_9_1 = getProxy(PlayerProxy):getRawData():GetCommonFlag(_G[pg.settings_other_template[22].name])

	if pg.settings_other_template[22].default == 1 then
		var_9_1 = not var_9_1
	end

	self.autoLockShipToggle.isOn = var_9_1 or false

	onToggle(self, go(self.autoLockShipToggle), function(arg_15_0)
		self:ChangeAutoLockShip(var_9_0, arg_15_0)
	end, SFX_PANEL)
end

function BuildShipDetailLayer:onBackPressed()
	if self.isPlayAnim then
		return
	end

	self:emit(BuildShipDetailLayer.ON_BACK_PRESSED, true)
end

function BuildShipDetailLayer:getNeedCount()
	local var_17_0 = 0

	for iter_17_0, iter_17_1 in ipairs(self.projectList) do
		if iter_17_1.state ~= BuildShip.FINISH then
			var_17_0 = var_17_0 + 1
		end
	end

	return var_17_0
end

function BuildShipDetailLayer:updateListCount()
	setText(self.listCountTF, self.workCount)
end

function BuildShipDetailLayer:updateItem()
	setText(self.quickCountTF, self.itemVO.count)
end

function BuildShipDetailLayer:initProjectList()
	for iter_20_0, iter_20_1 in pairs(self.buildTimers or {}) do
		pg.TimeMgr.GetInstance():RemoveTimer(iter_20_1)
	end

	self.buildTimers = {}

	local var_20_1

	if self.MODEL == var_0_2 then
		var_20_1 = #self.projectList or 0

		local var_20_2

		if self.MODEL == var_0_3 then
			var_20_2 = #self.projectList or 0
		end
	end

	setActive(self.multLineTF, var_20_1 > 0)
	setActive(self.singleLineTF, var_20_2 > 0)
	self.multList:align(var_20_1)
	self.singleList:align(var_20_2)
	setActive(self.noneBg, #self.projectList <= 0)
end

function BuildShipDetailLayer:initMultLine()
	self.multList:align(#self.projectList)
end

function BuildShipDetailLayer:initSingleLine()
	self.singleList:align(#self.projectList)
end

function BuildShipDetailLayer:updateProject(arg_23_1, arg_23_2)
	assert(isa(arg_23_2, BuildShip), "必须是实例BuildShip")

	local var_23_0 = self.projectTFs[arg_23_1]

	if IsNil(self.projectTFs[arg_23_1]) then
		return
	end

	local var_23_1 = var_23_0:Find("frame/buiding")
	local var_23_2 = var_23_0:Find("frame/finished")
	local var_23_3 = var_23_0:Find("frame/waiting")

	setActive(var_23_3, false)
	setActive(var_23_1, arg_23_2.state == BuildShip.ACTIVE)
	setActive(var_23_2, arg_23_2.state == BuildShip.FINISH)

	var_23_0:GetComponent("CanvasGroup").alpha = arg_23_2.state == BuildShip.INACTIVE and 0.6 or 1

	local var_23_4 = tonumber(pg.ship_data_create_material[arg_23_2.type].ship_icon)
	local var_23_5 = var_23_1:Find("ship_modal")

	for iter_23_0 = 0, var_23_5.childCount - 1 do
		setActive(var_23_5:GetChild(iter_23_0), false)
	end

	if arg_23_2.state == BuildShip.ACTIVE then
		local var_23_6 = GetComponent(var_23_1, typeof(CanvasGroup))

		if var_23_6 then
			var_23_6.alpha = 1
		end

		local var_23_7 = var_23_5:Find("shipModelBuliding" .. var_23_4)

		if not var_23_7 then
			PoolMgr.GetInstance():GetUI("shipModelBuliding" .. var_23_4, true, function(arg_24_0)
				arg_24_0.transform:SetParent(var_23_5, false)

				arg_24_0.transform.localPosition = Vector3(1, 1, 1)
				arg_24_0.transform.localScale = Vector3(1, 1, 1)

				arg_24_0.transform:SetAsFirstSibling()
				setActive(arg_24_0, true)
			end)
		else
			setActive(var_23_7, true)
		end

		local var_23_8 = var_23_1:Find("timer/Text")

		onButton(self, var_23_1:Find("quick_btn"), function()
			local var_25_0, var_25_1, var_25_2 = BuildShip.canQuickBuildShip(arg_23_1)

			if not var_25_0 then
				if var_25_2 then
					GoShoppingMsgBox(i18n("switch_to_shop_tip_1"), ChargeScene.TYPE_ITEM, var_25_2)
				else
					pg.TipsMgr.GetInstance():ShowTips(var_25_1)
				end

				return
			end

			if self.isStopSpeedUpRemind then
				self:emit(BuildShipDetailMediator.ON_QUICK, arg_23_1)
			else
				local var_25_3 = pg.MsgboxMgr.GetInstance()
				local var_25_4 = {
					showStopRemind = true
				}

				var_25_4.content = i18n("ship_buildShipScene_quest_quickFinish", 1, (self.itemVO.count == 0 or nil) and (COLOR_RED or COLOR_GREEN), self.itemVO.count)
				var_25_4.stopRamindContent = i18n("dont_remind_session")

				function var_25_4.onYes()
					self:emit(BuildShipDetailMediator.ON_QUICK, arg_23_1, var_25_3.stopRemindToggle.isOn)
				end

				var_25_3:ShowMsgBox(var_25_4)
			end
		end, SFX_UI_BUILDING_FASTBUILDING)

		local function var_23_9()
			pg.TimeMgr.GetInstance():RemoveTimer(self.buildTimers[arg_23_1])

			self.buildTimers[arg_23_1] = nil

			setActive(var_23_1, false)
			setActive(var_23_2, true)
		end

		local function var_23_10(arg_28_0)
			setText(var_23_8, (pg.TimeMgr.GetInstance():DescCDTime(arg_28_0)))
		end

		if self.buildTimers[arg_23_1] then
			pg.TimeMgr.GetInstance():RemoveTimer(self.buildTimers[arg_23_1])

			self.buildTimers[arg_23_1] = nil
		end

		self.buildTimers[arg_23_1] = pg.TimeMgr.GetInstance():AddTimer("timer" .. arg_23_1, 0, 1, function()
			local var_29_0 = arg_23_2:getLeftTime()

			if var_29_0 <= 0 then
				var_23_9()
			else
				var_23_10(var_29_0)
			end
		end)
	elseif arg_23_2.state == BuildShip.FINISH then
		GetOrAddComponent(var_23_1, typeof(CanvasGroup)).alpha = 0

		setActive(var_23_1, true)

		local var_23_11 = var_23_5:Find("shipModelBuliding" .. var_23_4)

		if var_23_11 then
			setActive(var_23_11, true)
		end

		self:setSpriteTo(var_0_5[tonumber(pg.ship_data_create_material[arg_23_2.type].ship_icon)], var_23_2:Find("ship_modal"), false)

		local var_23_12 = findTF(var_23_2, "launched_btn")

		onButton(self, var_23_12, function()
			self:emit(BuildShipDetailMediator.ON_LAUNCHED, arg_23_1)
		end, SFX_PANEL)
		onButton(self, var_23_0, function()
			triggerButton(var_23_12)
		end, SFX_PANEL)
	elseif arg_23_2.state == BuildShip.INACTIVE then
		setActive(var_23_3, true)
		setActive(var_23_1, false)
		setActive(var_23_2, false)
	end
end

function BuildShipDetailLayer:playGetShipAnimate(arg_32_1, arg_32_2)
	self.canvasgroup.blocksRaycasts = false

	local var_32_0 = pg.ship_data_create_material[arg_32_2]

	self.isPlayAnim = true
	self.onLoading = true

	pg.CpkPlayMgr.GetInstance():PlayCpkMovie(function()
		self.onLoading = false

		if var_32_0 and var_32_0.build_voice ~= "" then
			self:playCV(var_32_0.build_voice)
		end

		warning("BuildingCPK PlayCallBack", pg.CpkPlayMgr.GetInstance()._ratioFitter.enabled)
	end, function()
		self.isPlayAnim = false
		self.canvasgroup.blocksRaycasts = true

		arg_32_1()
	end, "ui", pg.ship_data_create_material[arg_32_2].build_anim or "Building", true, false, 4.5, true)
end

function BuildShipDetailLayer:willExit()
	pg.CpkPlayMgr.GetInstance():DisposeCpkMovie()

	for iter_35_0, iter_35_1 in pairs(self.buildTimers) do
		pg.TimeMgr.GetInstance():RemoveTimer(iter_35_1)
	end

	if self.aniBgTF then
		SetParent(self.aniBgTF, self._tf)
	end

	self.buildTimers = nil

	self:stopCV()

	self.onLoading = false

	self.multList:each(function(arg_36_0, arg_36_1)
		eachChild(arg_36_1:Find("frame/buiding/ship_modal"), function(arg_37_0)
			PoolMgr.GetInstance():ReturnUI(arg_37_0.name, arg_37_0)
		end)
	end)
	self.singleList:each(function(arg_38_0, arg_38_1)
		eachChild(arg_38_1:Find("frame/buiding/ship_modal"), function(arg_39_0)
			PoolMgr.GetInstance():ReturnUI(arg_39_0.name, arg_39_0)
		end)
	end)
end

function BuildShipDetailLayer:playCV(arg_40_1)
	self:stopCV()
	pg.CriMgr.GetInstance():PlaySoundEffect_V3("event:/cv/build/" .. arg_40_1)

	self.voiceContent = "event:/cv/build/" .. arg_40_1
end

function BuildShipDetailLayer:stopCV()
	if self.voiceContent then
		pg.CriMgr.GetInstance():UnloadSoundEffect_V3(self.voiceContent)
	end

	self.voiceContent = nil
end

function BuildShipDetailLayer:ChangeAutoLockShip(arg_42_1, arg_42_2)
	local var_42_0 = getProxy(PlayerProxy):getRawData():GetCommonFlag(_G[arg_42_1.name])

	if (arg_42_1.default == 1 or nil) and arg_42_2 then
		pg.m02:sendNotification(GAME.CANCEL_COMMON_FLAG, {
			flagID = _G[arg_42_1.name]
		})
	else
		pg.m02:sendNotification(GAME.COMMON_FLAG, {
			flagID = _G[arg_42_1.name]
		})
	end
end

return BuildShipDetailLayer
