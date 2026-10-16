local SVFloatPanel = class("SVFloatPanel", import("view.base.BaseSubView"))

SVFloatPanel.ShowView = "SVFloatPanel.ShowView"
SVFloatPanel.HideView = "SVFloatPanel.HideView"
SVFloatPanel.ReturnCall = "SVFloatPanel.ReturnCall"
SVFloatPanel.DelegateCall = "SVFloatPanel.DelegateCall"

function SVFloatPanel:getUIName()
	return "SVFloatPanel"
end

function SVFloatPanel:OnLoaded()
	return
end

function SVFloatPanel:OnInit()
	self.rtBasePoint = self._tf:Find("point")
	self.rtInfoPanel = self.rtBasePoint:Find("line/bg")
	self.rtMarking = self.rtInfoPanel:Find("icon/marking")
	self.rtRes = self._tf:Find("res")
	self.awardItemList = UIItemList.New(self.rtInfoPanel:Find("pressing_award"), self.rtInfoPanel:Find("pressing_award/award_tpl"))

	self.awardItemList:make(function(arg_4_0, arg_4_1, arg_4_2)
		if arg_4_0 == UIItemList.EventUpdate then
			local var_4_0 = {
				type = self.awardConfig[arg_4_1 + 1][1],
				id = self.awardConfig[arg_4_1 + 1][2],
				count = self.awardConfig[arg_4_1 + 1][3]
			}

			updateDrop(arg_4_2:Find("IconTpl"), var_4_0)
			onButton(self, arg_4_2:Find("IconTpl"), function()
				self:emit(BaseUI.ON_DROP, var_4_0)
			end, SFX_PANEL)
			setActive(arg_4_2:Find("is_pressing"), self.mapList[self.destIndex].isPressing)
			setActive(arg_4_2:Find("IconTpl"), not self.mapList[self.destIndex].isPressing)
		end
	end)

	self.btnBack = self.rtInfoPanel:Find("back")

	onButton(self, self.btnBack, function()
		self:emit(WorldScene.SceneOp, "OpSetInMap", true)
	end, SFX_CONFIRM)

	self.btnEnter = self.rtInfoPanel:Find("enter")

	onButton(self, self.btnEnter, function()
		local var_7_0 = {}
		local var_7_1 = self.mapList[self.destIndex]

		if WorldConst.HasDangerConfirm(self.mapList[self.destIndex].config.entrance_ui) then
			table.insert(var_7_0, function(arg_8_0)
				self:emit(WorldScene.SceneOp, "OpCall", function(arg_9_0)
					arg_9_0()
					pg.MsgboxMgr.GetInstance():ShowMsgBox({
						content = i18n("world_map_dangerous_confirm"),
						onYes = arg_8_0
					})
				end)
			end)
		end

		seriesAsync(var_7_0, function()
			local var_10_0 = nowWorld().staminaMgr

			if not var_7_1.isCost and var_7_1.config.enter_cost > var_10_0:GetTotalStamina() then
				var_10_0:Show()
			else
				self:emit(WorldScene.SceneOp, "OpTransport", self.entrance, var_7_1)
			end
		end)
	end, SFX_CONFIRM)

	self.btnDelegate = self.btnEnter:Find("delegate")

	onButton(self, self.btnDelegate, function()
		self:emit(SVFloatPanel.DelegateCall, self.mapList[self.destIndex].id)
	end, SFX_PANEL)
	setText(self.btnDelegate:Find("lock/Text"), i18n("world_auto_buy_unlock"))

	self.btnLock = self.rtInfoPanel:Find("lock")
	self.btnReturn = self.rtInfoPanel:Find("return")

	onButton(self, self.btnReturn, function()
		self:emit(SVFloatPanel.ReturnCall, self.entrance)
	end, SFX_CONFIRM)

	self.btnSwitch = self.rtInfoPanel:Find("switch")

	onButton(self, self.btnSwitch, function()
		if self.isTweening then
			return
		end

		self:ShowToggleMask()
	end, SFX_PANEL)

	self.rtSelectMask = self._tf:Find("select_mask")

	onButton(self, self.rtSelectMask:Find("bg"), function()
		if self.isTweening then
			return
		end

		self:HideToggleMask()
	end, SFX_PANEL)

	self.rtMaskMarking = self.rtSelectMask:Find("marking")
	self.rtToggles = self.rtMaskMarking:Find("toggles")
	self.toggleItemList = UIItemList.New(self.rtToggles, self.rtToggles:Find("toggle"))

	self.toggleItemList:make(function(arg_15_0, arg_15_1, arg_15_2)
		arg_15_1 = arg_15_1 + 1

		if arg_15_0 == UIItemList.EventUpdate then
			local var_15_0, var_15_1 = World.ReplacementMapType(self.entrance, self.mapList[arg_15_1])

			setText(arg_15_2:Find("Text"), var_15_1)
			onToggle(self, arg_15_2, function(arg_16_0)
				if arg_16_0 then
					self:HideToggleMask()

					self.destIndex = arg_15_1

					self:UpdatePanel()
				end
			end, SFX_PANEL)
			triggerToggle(arg_15_2, false)
		end
	end)
end

function SVFloatPanel:OnDestroy()
	return
end

function SVFloatPanel:Show()
	setActive(self._tf, true)
end

function SVFloatPanel:Hide()
	setActive(self._tf, false)
end

function SVFloatPanel:Setup(arg_20_1, arg_20_2, arg_20_3, arg_20_4)
	self.entrance = arg_20_1

	setAnchoredPosition(self.rtBasePoint, self._tf:InverseTransformPoint(GameObject.Find("OverlayCamera"):GetComponent(typeof(Camera)):ScreenToWorldPoint((arg_20_4:GetMapScreenPos(Vector2(arg_20_1.config.area_pos[1], arg_20_1.config.area_pos[2]))))))

	self.mapList = nowWorld():EntranceToReplacementMapList(arg_20_1)

	self.toggleItemList:align(#self.mapList)
	triggerToggle(self.rtToggles:GetChild((function()
		if arg_20_2 then
			for iter_21_0, iter_21_1 in ipairs(self.mapList) do
				if iter_21_1.id == arg_20_2 then
					return iter_21_0
				end
			end
		end

		if arg_20_3 then
			for iter_21_2, iter_21_3 in ipairs(arg_20_3) do
				for iter_21_4, iter_21_5 in ipairs(self.mapList) do
					if iter_21_3 == World.ReplacementMapType(arg_20_1, iter_21_5) then
						return iter_21_4
					end
				end
			end
		end

		if arg_20_1.active then
			for iter_21_6, iter_21_7 in ipairs(self.mapList) do
				if iter_21_7.active then
					return iter_21_6
				end
			end
		end

		return 1
	end)() - 1), true)
end

function SVFloatPanel:setColorfulImage(arg_22_1, arg_22_2, arg_22_3)
	arg_22_3 = defaultValue(arg_22_3, true)

	setImageSprite(arg_22_1, getImageSprite(self.rtRes:Find(arg_22_1.name .. "/" .. arg_22_2)), arg_22_3)
end

function SVFloatPanel:UpdatePanel()
	local var_23_0 = nowWorld()
	local var_23_1 = self.mapList[self.destIndex]
	local var_23_2, var_23_3 = World.ReplacementMapType(self.entrance, self.mapList[self.destIndex])
	local var_23_4 = var_23_2 == "complete_chapter" and "safe" or WorldConst.GetMapIconState(var_23_1.config.entrance_ui)
	local var_23_5 = var_23_1:IsMapOpen()

	self:setColorfulImage(self.rtBasePoint, var_23_4)
	self:setColorfulImage(self.rtInfoPanel, var_23_4, false)
	setImageSprite(self.rtInfoPanel:Find("icon"), (GetSpriteFromAtlas("world/mapicon/" .. var_23_1.config.entrance_mapicon, "")))
	self:setColorfulImage(self.btnBack, var_23_4)
	self:setColorfulImage(self.btnEnter, var_23_4)
	self:setColorfulImage(self.rtMarking, var_23_4)
	self:setColorfulImage(self.rtMarking:Find("mark_bg"), var_23_4)
	self:setColorfulImage(self.rtMaskMarking, var_23_4)
	self:setColorfulImage(self.rtMaskMarking:Find("mark_bg"), var_23_4)
	setText(self.rtMarking:Find("Text"), var_23_3)
	setText(self.rtMaskMarking:Find("Text"), var_23_3)
	setActive(self.rtInfoPanel:Find("sairen"), var_23_2 == "sairen_chapter")
	setText(self.rtInfoPanel:Find("sairen/Text"), i18n("area_yaosai_2"))
	setText(self.rtInfoPanel:Find("danger_text"), var_23_5 and var_23_1:GetDanger() or "?")
	changeToScrollText(self.rtInfoPanel:Find("title/name"), var_23_1:GetName(self.entrance))

	local var_23_6, var_23_7, var_23_8 = var_23_0:CountAchievements(self.entrance)

	setText(self.rtInfoPanel:Find("title/achievement/number"), var_23_6 + var_23_7 .. "/" .. var_23_8)

	local var_23_9 = var_23_0:GetPressingAward(var_23_1.id)

	setActive(self.rtInfoPanel:Find("pressing_award"), var_23_9 and var_23_9.flag)

	if var_23_9 and var_23_9.flag then
		self.awardConfig = pg.world_event_complete[var_23_9.id].tips_icon

		self.awardItemList:align(#self.awardConfig)
	end

	self:UpdateCost()
	self:UpdateDelegate()

	local var_23_10 = nowWorld():GetAtlas()
	local var_23_11 = var_23_10:GetActiveMap()
	local var_23_12, var_23_13 = var_23_11:CkeckTransport()
	local var_23_14 = false
	local var_23_15 = getProxy(ChapterAutoProxy):HasTypeCommission(ChapterAutoProxy.TYPE.WORLD)

	setActive(self.btnLock, var_23_15)

	if var_23_15 then
		setText(self.btnLock:Find("Text"), i18n("world_auto_plan_in_progress"))
	end

	var_23_14 = var_23_14 or isActive(self.btnLock)

	setActive(self.btnBack, not var_23_14 and var_23_10:GetActiveEntrance() == self.entrance and var_23_11 == var_23_1)

	var_23_14 = var_23_14 or isActive(self.btnBack)

	setActive(self.btnEnter, not var_23_14 and var_23_12 and var_23_5 and var_23_10.transportDic[self.entrance.id])

	var_23_14 = var_23_14 or isActive(self.btnEnter)

	if not var_23_15 then
		setText(self.btnLock:Find("Text"), var_23_5 and i18n("world_map_locked_border") or i18n("world_map_locked_stage"))
		setActive(self.btnLock, not var_23_14 and var_23_12)
	end

	var_23_14 = var_23_14 or isActive(self.btnLock)

	setActive(self.btnReturn, not var_23_14)

	local var_23_16

	var_23_16 = var_23_14 or isActive(self.btnReturn)
end

function SVFloatPanel:UpdateCost()
	local var_24_0 = self.btnEnter:Find("cost")

	setActive(var_24_0, not self.mapList[self.destIndex].isCost)

	local var_24_1 = nowWorld().staminaMgr:GetTotalStamina()

	setText(var_24_0:Find("Text"), setColorStr(var_24_1, (var_24_1 < self.mapList[self.destIndex].config.enter_cost or nil) and (COLOR_RED or COLOR_GREEN)) .. "/" .. self.mapList[self.destIndex].config.enter_cost)
end

function SVFloatPanel:UpdateDelegate()
	local var_25_0 = nowWorld()

	if not var_25_0:IsSystemOpen(WorldConst.SystemAutoSwitch) then
		setActive(self.btnDelegate, false)

		return
	end

	setActive(self.btnDelegate, pg.world_auto_statistics[self.mapList[self.destIndex].id] and not self.mapList[self.destIndex].isCost)
	setActive(self.btnDelegate:Find("lock"), not var_25_0:GetGobalFlag("treasure_flag"))
end

function SVFloatPanel:ShowToggleMask()
	self.isTweening = true

	setActive(self.rtMarking, false)
	setActive(self.rtSelectMask, true)
	setActive(self.rtToggles, false)

	self.rtMaskMarking.position = self.rtMarking.position

	LeanTween.moveY(self.rtMaskMarking, self.rtMaskMarking.anchoredPosition.y + 150, 0.2):setOnComplete(System.Action(function()
		setActive(self.rtToggles, true)

		self.isTweening = false
	end))
	setActive(self.btnSwitch, false)
end

function SVFloatPanel:HideToggleMask()
	self.isTweening = true

	setActive(self.rtToggles, false)

	self.rtMaskMarking.position = self.rtMarking.position

	setAnchoredPosition(self.rtMaskMarking, {
		y = self.rtMaskMarking.anchoredPosition.y + 150
	})
	LeanTween.moveY(self.rtMaskMarking, self.rtMaskMarking.anchoredPosition.y - 150, 0.2):setOnComplete(System.Action(function()
		setActive(self.rtSelectMask, false)
		setActive(self.rtMarking, true)

		self.isTweening = false

		setActive(self.btnSwitch, #self.mapList > 1)
	end))
end

return SVFloatPanel
