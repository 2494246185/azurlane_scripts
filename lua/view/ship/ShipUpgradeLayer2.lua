local ShipUpgradeLayer2 = class("ShipUpgradeLayer2", import("..base.BaseUI"))
local var_0_1 = 3

function ShipUpgradeLayer2:getUIName()
	return "ShipBreakOutUI"
end

function ShipUpgradeLayer2:getGroupName()
	return "ShipMainScene"
end

function ShipUpgradeLayer2:getResource()
	local var_3_0 = getProxy(BayProxy)
	local var_3_1 = var_3_0:getShipById(self.contextData.shipId)
	local var_3_2 = ys.Battle.BattleResourceManager.GetInstance()
	local var_3_3 = var_3_2.GetMapResource(40000)

	table.insertto(var_3_0, var_3_2.GetDisplayCommonResource())
	table.insertto(var_3_3, var_3_2.GetShipResource(var_3_1.configId, var_3_1.skinId))

	local var_3_4 = {}
	local var_3_5 = math.floor(var_3_1.configId / 10)

	for iter_3_0 = 1, 4 do
		table.insert(var_3_4, tonumber(var_3_5 .. iter_3_0))
	end

	for iter_3_1, iter_3_2 in ipairs(var_3_4) do
		for iter_3_3, iter_3_4 in ipairs(pg.ship_data_breakout[iter_3_2].weapon_ids) do
			if iter_3_4 ~= 0 then
				for iter_3_5, iter_3_6 in ipairs(ys.Battle.BattleDataFunction.GetWeaponDataFromID(iter_3_4).weapon_id) do
					table.insertto(var_3_3, var_3_2.GetWeaponResource(iter_3_6))
				end
			end
		end
	end

	return table.insertto(var_3_3, ShipUpgradeLayer2.super.getResource(self))
end

function ShipUpgradeLayer2:setItems(arg_4_1)
	self.items = arg_4_1
end

function ShipUpgradeLayer2:setPlayer(arg_5_1)
	self.player = arg_5_1
end

function ShipUpgradeLayer2:init()
	self.leftPanel = self._tf:Find("blur_panel/left_panel")
	self.stages = self.leftPanel:Find("stageScrollRect/stages")

	setText(self.leftPanel:Find("bg/title/Image"), i18n("word_preview"))

	self.stagesSnap = self.leftPanel:Find("stageScrollRect"):GetComponent("HorizontalScrollSnap")
	self.breakView = self.leftPanel:Find("content/Text")
	self.rightPanel = self._tf:Find("blur_panel/right_panel")
	self.attrs = self.rightPanel:Find("top/attrs")
	self.starTpl = self.rightPanel:Find("top/rare/startpl")

	setActive(self.starTpl, false)

	self.starsFrom = self.rightPanel:Find("top/rare/stars_from")
	self.starsTo = self.rightPanel:Find("top/rare/stars_to")
	self.starOpera = self.rightPanel:Find("top/rare/opera")
	self.materials = self.rightPanel:Find("bottom/materials")
	self.breakOutBtn = self.rightPanel:Find("bottom/break_btn/tip_active/image")
	self.appendStarTips = self.rightPanel:Find("bottom/panel_title/tip")
	self.tipActive = self.rightPanel:Find("bottom/break_btn/tip_active")
	self.tipDeactive = self.rightPanel:Find("bottom/break_btn/tip_deactive")

	setText(self.rightPanel:Find("bottom/panel_title/tip"), i18n("breakout_tip"))
	setText(self.rightPanel:Find("bottom/break_btn/tip_deactive/values/ok"), i18n("text_confirm"))
	setText(self.rightPanel:Find("bottom/break_btn/tip_active/image/ok"), i18n("text_confirm"))

	self.recommandBtn = self.rightPanel:Find("bottom/auto_btn")
	self.isEnoughItems = true
	self.sea = self.leftPanel:Find("sea")
	self.rawImage = self.sea:GetComponent("RawImage")

	setActive(self.rawImage, false)

	self.healTF = self._tf:Find("resources/heal")
	self.healTF.transform.localPosition = Vector3(-360, 50, 40)

	setActive(self.healTF, false)

	self.qCharaContain = self.rightPanel:Find("top/panel_bg/q_chara")
	self.seaLoading = self.leftPanel:Find("bg/loading")

	self:playLoadingAni()

	self.destroyConfirmWindow = ShipDestoryConfirmWindow.New(self._tf, self.event)
end

function ShipUpgradeLayer2:loadChar()
	if not self.shipPrefab then
		local var_7_0 = self.shipVO:getPrefab()

		pg.UIMgr.GetInstance():LoadingOn()

		local var_7_1 = SpineAnimChar.New()

		var_7_1:SetPaint(var_7_0)
		var_7_1:Load(true, function(arg_8_0)
			pg.UIMgr.GetInstance():LoadingOff()

			self.shipPrefab = var_7_0
			self.shipModel = arg_8_0

			arg_8_0:SetLocalScale(Vector3(0.8, 0.8, 1))
			arg_8_0:SetParent(self.qCharaContain)
			arg_8_0:SetAction("stand", 0)
		end)
	end
end

function ShipUpgradeLayer2:recycleSpineChar()
	if self.shipPrefab and self.shipModel then
		self.shipModel:Dispose()

		self.shipPrefab = nil
		self.shipModel = nil
	end
end

function ShipUpgradeLayer2:enabledToggles(arg_10_1)
	eachChild(self.toggles, function(arg_11_0)
		arg_11_0:GetComponent("Toggle").enabled = arg_10_1
	end)
end

function ShipUpgradeLayer2:addDragListenter()
	local var_12_0 = GetOrAddComponent(self._tf, "EventTriggerListener")

	self.dragTrigger = var_12_0

	local var_12_1
	local var_12_2 = 0

	var_12_0:AddBeginDragFunc(function()
		var_12_1 = nil
		var_12_2 = 0
	end)
	var_12_0:AddDragFunc(function(arg_14_0, arg_14_1)
		var_12_1 = var_12_1 or arg_14_1.position
		var_12_2 = arg_14_1.position.x - var_12_1.x
	end)
	var_12_0:AddDragEndFunc(function(arg_15_0, arg_15_1)
		if var_12_2 < -50 then
			self:emit(ShipUpgradeMediator2.NEXTSHIP, -1)
		elseif var_12_2 > 50 then
			self:emit(ShipUpgradeMediator2.NEXTSHIP)
		end
	end)
end

function ShipUpgradeLayer2:didEnter()
	self:BlurPanel(self._tf, {
		groupDelta = -1
	})
	self:addDragListenter()
	onButton(self, self.seaLoading, function()
		if not self.previewer then
			self:showBarrage()
		end
	end)
	onButton(self, self.breakOutBtn, function()
		local var_18_0 = {}

		if self.shipVO:isActivityNpc() then
			table.insert(var_18_0, function(arg_19_0)
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					content = i18n("npc_breakout_tip"),
					onYes = arg_19_0
				})
			end)
		end

		seriesAsync(var_18_0, function()
			local var_20_0, var_20_1 = ShipStatus.ShipStatusCheck("onModify", self.shipVO)

			if not var_20_0 then
				pg.TipsMgr.GetInstance():ShowTips(var_20_1)

				return
			end

			if self.breakCfg.breakout_id == 0 then
				pg.TipsMgr.GetInstance():ShowTips(i18n("ship_upgradeStar_maxLevel"))

				return
			end

			if self.shipVO.level < self.breakCfg.level then
				pg.TipsMgr.GetInstance():ShowTips(i18n("ship_upgradeStar_error_lvLimit"))

				return
			end

			if not self.isEnoughItems then
				pg.TipsMgr.GetInstance():ShowTips(i18n("ship_upgradeStar_error_noEnoughMatrail"))

				return
			end

			if self.player.gold < self.breakCfg.use_gold then
				GoShoppingMsgBox(i18n("switch_to_shop_tip_2", i18n("word_gold")), ChargeScene.TYPE_ITEM, {
					{
						59001,
						self.breakCfg.use_gold - self.player.gold,
						self.breakCfg.use_gold
					}
				})

				return
			end

			if not self.contextData.materialShipIds or #self.contextData.materialShipIds < self.breakCfg.use_char_num then
				pg.TipsMgr.GetInstance():ShowTips(i18n("ship_upgradeStar_select_material_tip"))

				return
			end

			self:emit(ShipUpgradeMediator2.UPGRADE_SHIP, self.contextData.materialShipIds)
		end)
	end, SFX_CONFIRM)
	onButton(self, self.recommandBtn, function()
		local var_21_0 = getProxy(BayProxy)

		if self.contextData.materialShipIds and #self.contextData.materialShipIds == self.breakCfg.use_char_num then
			return
		end

		local var_21_1 = var_21_0:getUpgradeRecommendShip(self.shipVO, self.contextData.materialShipIds or {}, self.breakCfg.use_char_num)

		if #var_21_1 > 0 then
			local var_21_2 = {}

			table.insert(var_21_2, function(arg_22_0)
				local var_22_0, var_22_1 = ShipCalcHelper.GetEliteAndHightLevelShips(underscore.map(var_21_1, function(arg_23_0)
					return var_21_0:getShipById(arg_23_0)
				end))

				if #var_22_0 > 0 or #var_22_1 > 0 then
					self.destroyConfirmWindow:ExecuteAction("Show", var_22_0, var_22_1, false, arg_22_0)
				else
					arg_22_0()
				end
			end)
			seriesAsync(var_21_2, function()
				self.contextData.materialShipIds = var_21_1

				self:updateBreakOutView(self.shipVO)
			end)
		else
			pg.TipsMgr.GetInstance():ShowTips(i18n("without_selected_ship"))
		end
	end, SFX_CONFIRM)
	self:initMaterialShips()
end

function ShipUpgradeLayer2:getMaterialShip(arg_25_1)
	local var_25_0

	for iter_25_0 = #arg_25_1, 1, -1 do
		if not arg_25_1[iter_25_0]:isTestShip() then
			var_25_0 = iter_25_0

			break
		end
	end

	var_25_0 = var_25_0 or #arg_25_1

	return var_25_0
end

function ShipUpgradeLayer2:setShip(arg_26_1)
	self.shipVO = arg_26_1
	self.shipTempCfg = pg.ship_data_template
	self.shipBreakOutCfg = pg.ship_data_breakout
	self.breakIds = self:getStages()
	self.itemTFs = {}

	for iter_26_0 = 1, 3 do
		self.itemTFs[iter_26_0] = self.materials:Find("item_" .. iter_26_0)
	end

	self:updateBattleView()
	self:updateBreakOutView(self.shipVO)

	local var_26_0 = self.shipVO.level < self.breakCfg.level or self.breakCfg.breakout_id == 0

	setActive(self.tipActive, not (self.shipVO.level < self.breakCfg.level or self.breakCfg.breakout_id == 0))
	setActive(self.tipDeactive, var_26_0)
	setButtonEnabled(self.breakOutBtn, not var_26_0)
	setActive(self.recommandBtn, self.breakCfg.breakout_id ~= 0)
	self:loadChar()
end

function ShipUpgradeLayer2:getStages()
	local var_27_0 = {}
	local var_27_1 = math.floor(self.shipVO.configId / 10)

	for iter_27_0 = 1, 4 do
		local var_27_2 = tonumber(var_27_1 .. iter_27_0)

		assert(self.shipBreakOutCfg[var_27_2], "必须存在配置" .. var_27_2)
		table.insert(var_27_0, var_27_2)
	end

	return var_27_0
end

function ShipUpgradeLayer2:updateStagesScrollView()
	local var_28_0 = table.indexof(self.breakIds, self.shipVO.configId)

	if var_28_0 and var_28_0 >= 1 and var_28_0 <= var_0_1 then
		self.stages:Find("stage" .. var_28_0):GetComponent(typeof(Toggle)).isOn = true
	end
end

function ShipUpgradeLayer2:updateBattleView()
	if #self.breakIds < var_0_1 then
		return
	end

	for iter_29_0 = 1, var_0_1 do
		local var_29_0 = self.breakIds[iter_29_0]
		local var_29_1 = self.shipBreakOutCfg[self.breakIds[iter_29_0]]

		assert(self.shipBreakOutCfg[self.breakIds[iter_29_0]], "不存在配置" .. self.breakIds[iter_29_0])
		onToggle(self, self.stages:Find("stage" .. iter_29_0), function(arg_30_0)
			if arg_30_0 then
				local var_30_0 = var_29_1.breakout_view

				for iter_30_0, iter_30_1 in ipairs(checkExist(pg.ship_data_template[var_29_1.breakout_id], {
					"specific_type"
				}) or {}) do
					var_30_0 = var_30_0 .. "/" .. i18n(ShipType.SpecificTableTips[iter_30_1])
				end

				changeToScrollText(self.breakView, var_30_0)
				self:switchStage(var_29_0)
			end
		end, SFX_PANEL)
	end

	self.stages:Find("stage1"):GetComponent(typeof(Toggle)).group:SetAllTogglesOff()

	local var_29_2 = math.clamp(table.indexof(self.breakIds, self.shipVO.configId), 1, var_0_1)

	if var_29_2 and var_29_2 >= 1 and var_29_2 <= var_0_1 then
		triggerToggle(self.stages:Find("stage" .. var_29_2), true)
	end
end

local var_0_2 = {
	"durability",
	"cannon",
	"torpedo",
	"antiaircraft",
	"air",
	"antisub"
}

function ShipUpgradeLayer2:showBarrage()
	self.previewer = WeaponPreviewer.New(self.rawImage)

	self.previewer:configUI(self.healTF)
	self.previewer:setDisplayWeapon(self:getWaponIdsById(self.breakOutId))
	self.previewer:load(40000, self.shipVO, self:getAllWeaponIds(), function()
		self:stopLoadingAni()
	end)
end

function ShipUpgradeLayer2:getWaponIdsById(arg_33_1)
	return self.shipBreakOutCfg[arg_33_1].weapon_ids
end

function ShipUpgradeLayer2:switchStage(arg_34_1)
	if self.breakOutId == arg_34_1 then
		return
	end

	self.breakOutId = arg_34_1

	if self.previewer then
		self.previewer:setDisplayWeapon(self:getWaponIdsById(self.breakOutId))
	end
end

function ShipUpgradeLayer2:getAllWeaponIds()
	local var_35_0 = {}

	for iter_35_0, iter_35_1 in ipairs(self.breakIds) do
		local var_35_1 = Clone(self.shipBreakOutCfg[iter_35_1].weapon_ids)

		setmetatable(var_35_0, {
			__add = function(arg_36_0, arg_36_1)
				for iter_36_0, iter_36_1 in ipairs(arg_36_0) do
					if not table.contains(arg_36_1, iter_36_1) then
						table.insert(arg_36_1, iter_36_1)
					end
				end

				return arg_36_1
			end
		})

		var_35_0 = var_35_0 + var_35_1
	end

	return var_35_0
end

function ShipUpgradeLayer2:updateBreakOutView(arg_37_1)
	self.breakCfg = self.shipBreakOutCfg[arg_37_1.configId]

	for iter_37_0, iter_37_1 in ipairs(self.itemTFs) do
		setActive(iter_37_1, false)
	end

	local var_37_0 = arg_37_1:getShipProperties()
	local var_37_1 = Clone(arg_37_1)

	var_37_1.configId = self.breakCfg.breakout_id

	local var_37_2 = {}
	local var_37_3 = self.breakCfg.breakout_id == 0
	local var_37_4 = arg_37_1:getBattleTotalExpend()
	local var_37_5
	local var_37_6
	local var_37_7 = self.tipDeactive:Find("values/label")
	local var_37_8 = self.tipDeactive:Find("values/value")

	setText(var_37_7, "")
	setText(var_37_8, "")

	if var_37_3 then
		var_37_2 = var_37_0
		var_37_5 = var_37_4

		setText(var_37_7, i18n("word_level_upperLimit"))
	else
		var_37_6 = self.shipTempCfg[self.breakCfg.breakout_id].max_level
		var_37_2 = var_37_1:getShipProperties()
		var_37_2.level = self.shipTempCfg[self.breakCfg.breakout_id].max_level >= arg_37_1:getMaxLevel() and var_37_6 or arg_37_1:getMaxLevel()
		var_37_5 = var_37_1:getBattleTotalExpend()

		setColorCount(var_37_8, self.shipVO.level, self.breakCfg.level)
		setText(var_37_7, i18n("word_level_require"))
	end

	local function var_37_9(arg_38_0, arg_38_1)
		setText(arg_38_0:Find("name"), arg_38_1.name)
		setText(arg_38_0:Find("value"), arg_38_1.preAttr)

		local var_38_0 = arg_38_0:Find("value1")
		local var_38_1 = arg_38_0:Find("addition")

		setText(var_38_0, arg_38_1.afterAttr == 0 and setColorStr(arg_38_1.afterAttr, "#FFFFFFFF") or setColorStr(arg_38_1.afterAttr, COLOR_GREEN))
		setActive(var_38_1, arg_38_1.afterAttr - arg_38_1.preAttr ~= 0)
		setText(var_38_1, "(+" .. arg_38_1.afterAttr - arg_38_1.preAttr .. ")")
	end

	local var_37_10 = 0

	if var_37_6 and var_37_6 ~= self.shipTempCfg[arg_37_1.configId].max_level then
		var_37_9(self.attrs:Find("attr_1"), {
			preAttr = self.shipTempCfg[arg_37_1.configId].max_level,
			afterAttr = var_37_6,
			name = i18n("word_level_upperLimit")
		})

		var_37_10 = 1
	end

	for iter_37_2 = 1, #var_0_2 do
		local var_37_11 = self.attrs:Find("attr_" .. var_37_10 + iter_37_2)

		setActive(var_37_11, true)
		var_37_9(var_37_11, {
			preAttr = math.floor(var_37_0[var_0_2[iter_37_2]]),
			afterAttr = math.floor(var_37_2[var_0_2[iter_37_2]]),
			name = i18n("word_attr_" .. var_0_2[iter_37_2])
		})
	end

	local var_37_12 = self.attrs:Find("attr_" .. var_37_10 + #var_0_2 + 1)

	setActive(var_37_12, true)
	var_37_9(var_37_12, {
		preAttr = var_37_4,
		afterAttr = var_37_5,
		name = i18n("word_attr_luck")
	})

	for iter_37_3 = var_37_10 + #var_0_2 + 1 + 1, 8 do
		setActive(self.attrs:Find("attr_" .. iter_37_3), false)
	end

	removeAllChildren(self.starsFrom)

	for iter_37_4 = 1, arg_37_1:getStar() do
		cloneTplTo(self.starTpl, self.starsFrom)
	end

	if var_37_3 then
		return
	end

	removeAllChildren(self.starsTo)

	if var_37_1:getStar() > arg_37_1:getStar() and not var_37_3 then
		for iter_37_5 = 1, var_37_1:getStar() do
			cloneTplTo(self.starTpl, self.starsTo)
		end
	end

	setActive(self.appendStarTips, var_37_1:getStar() ~= arg_37_1:getStar())
	setActive(self.starOpera, var_37_1:getStar() ~= arg_37_1:getStar())

	local var_37_13 = self.breakCfg.use_gold

	if self.breakCfg.use_gold > self.player.gold then
		var_37_13 = "<color=#FB4A2C>" .. var_37_13 .. "</color>"
	end

	setText(self.tipActive:Find("text"), var_37_13)
	self:initMaterialShips()
end

function ShipUpgradeLayer2:initMaterialShips()
	local var_39_0 = self.breakCfg.use_char_num
	local var_39_1 = getProxy(BayProxy)

	for iter_39_0 = 1, 3 do
		SetActive(self.itemTFs[iter_39_0], iter_39_0 <= var_39_0)

		local var_39_2 = self.itemTFs[iter_39_0]:Find("IconTpl")

		if iter_39_0 <= var_39_0 and self.contextData.materialShipIds and self.contextData.materialShipIds[iter_39_0] then
			updateShip(var_39_2, var_39_1:getShipById(self.contextData.materialShipIds[iter_39_0]), {
				initStar = true
			})
			SetActive(var_39_2, true)
		else
			SetActive(var_39_2, false)
		end

		onButton(self, self.itemTFs[iter_39_0], function()
			self:emit(ShipUpgradeMediator2.ON_SELECT_SHIP, self.shipVO, var_39_0)
		end)
	end
end

function ShipUpgradeLayer2:willExit()
	self:UnOverlayPanel(self._tf)
	self:recycleSpineChar()

	if self.previewer then
		self.previewer:clear()

		self.previewer = nil
	end

	if self.dragTrigger then
		ClearEventTrigger(self.dragTrigger)

		self.dragTrigger = nil
	end

	self.destroyConfirmWindow:Destroy()
end

function ShipUpgradeLayer2:playLoadingAni()
	setActive(self.seaLoading, true)
end

function ShipUpgradeLayer2:stopLoadingAni()
	setActive(self.seaLoading, false)
end

function ShipUpgradeLayer2:onBackPressed()
	if self.destroyConfirmWindow:isShowing() then
		self.destroyConfirmWindow:ActionInvoke("Hide")

		return
	end

	self:emit(BaseUI.ON_BACK_PRESSED, true)
end

return ShipUpgradeLayer2
