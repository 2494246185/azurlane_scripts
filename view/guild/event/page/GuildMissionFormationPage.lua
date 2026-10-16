local GuildMissionFormationPage = class("GuildMissionFormationPage", import(".GuildEventBasePage"))

function GuildMissionFormationPage:getUIName()
	return "GuildMissionFormationPage"
end

function GuildMissionFormationPage:OnRefreshMission(arg_2_1)
	if not self.mission or self.mission.id ~= arg_2_1.id then
		return
	end

	self:Flush(arg_2_1)
end

function GuildMissionFormationPage:OnFormationDone()
	local var_3_0 = {}

	self.loading = true

	for iter_3_0, iter_3_1 in pairs(self.shipGos) do
		table.insert(var_3_0, function(arg_4_0)
			iter_3_1:SetAction("victory", 0)
			iter_3_1:SetActionCallBack(function(arg_5_0)
				if arg_5_0 == "finish" then
					iter_3_1:SetActionCallBack(nil)
					iter_3_1:SetAction("stand", 0)
					arg_4_0()
				end
			end)
		end)
	end

	parallelAsync(var_3_0, function()
		self:Hide()

		self.loading = false
	end)

	local var_3_1 = self.canFormationIndex or 1

	for iter_3_2, iter_3_3 in ipairs(self.pageFooter) do
		setActive(iter_3_3, iter_3_2 <= var_3_1)
	end

	setActive(self.pageFooterAdd, false)
end

function GuildMissionFormationPage:OnLoaded()
	self.closeBtn = self._tf:Find("frame/close")
	self.titleTxt = self._tf:Find("frame/title"):GetComponent(typeof(Text))
	self.recomBtn = self._tf:Find("frame/recom")
	self.clearBtn = self._tf:Find("frame/clear")
	self.goBtn = self._tf:Find("frame/bottom/go")
	self.inProgressBtn = self._tf:Find("frame/bottom/doingBtn")
	self.battleAreaTxt = self._tf:Find("frame/bottom/desc/area/Text"):GetComponent(typeof(Text))
	self.battleTypeTxt = self._tf:Find("frame/bottom/desc/type/Text"):GetComponent(typeof(Text))
	self.awardList = UIItemList.New(self._tf:Find("frame/bottom/award/list"), self._tf:Find("frame/bottom/award/list/item"))
	self.target1Text = self._tf:Find("frame/bottom/desc/target/content/Text"):GetComponent(typeof(Text))
	self.target2Text = self._tf:Find("frame/bottom/desc/target/content/Text2"):GetComponent(typeof(Text))
	self.target1Text4Effect = self._tf:Find("frame/bottom/desc/target/content1/Text"):GetComponent(typeof(Text))
	self.target2Text4Effect = self._tf:Find("frame/bottom/desc/target/content1/Text2"):GetComponent(typeof(Text))
	self.scoreAdditionTxt = self._tf:Find("frame/bottom/score_addition/Text"):GetComponent(typeof(Text))
	self.effectAdditionTxt = self._tf:Find("frame/bottom/effect_addition/Text"):GetComponent(typeof(Text))
	self.effectTxt = self._tf:Find("frame/bottom/effect/Text"):GetComponent(typeof(Text))
	self.bg = self._tf:Find("frame/bottom/bg"):GetComponent(typeof(Image))
	self.pageFooter = {
		self._tf:Find("frame/single/dot/1"),
		self._tf:Find("frame/single/dot/2"),
		self._tf:Find("frame/single/dot/3"),
		self._tf:Find("frame/single/dot/4")
	}
	self.pageFooterAdd = self._tf:Find("frame/single/dot/add")
	self.nextBtn = self._tf:Find("frame/single/next")
	self.prevBtn = self._tf:Find("frame/single/prev")

	setText(self._tf:Find("frame/bottom/desc/area"), i18n("guild_word_battle_area"))
	setText(self._tf:Find("frame/bottom/desc/type"), i18n("guild_word_battle_type"))
end

function GuildMissionFormationPage:OnInit()
	local function var_8_0()
		if self.contextData.index > 1 then
			triggerToggle(self.pageFooter[self.contextData.index - 1], true)
		end
	end

	local function var_8_1()
		if self.contextData.index < self.mission:GetMaxFleet() then
			if self.contextData.index + 1 > self.mission:GetFleetCnt() then
				triggerToggle(self.pageFooterAdd, true)
			else
				triggerToggle(self.pageFooter[self.contextData.index + 1], true)
			end
		end
	end

	addSlip(SLIP_TYPE_HRZ, self._tf:Find("frame"), var_8_0, var_8_1)
	onButton(self, self.nextBtn, var_8_1, SFX_PANEL)
	onButton(self, self.prevBtn, var_8_0, SFX_PANEL)
	onButton(self, self.closeBtn, function()
		self.contextData.missionShips = nil

		self:Hide()
	end, SFX_PANEL)
	onButton(self, self.recomBtn, function()
		if not self:CheckFormation() then
			return
		end

		self:emit(GuildEventMediator.ON_GET_FORMATION, function()
			local var_13_0 = getProxy(GuildProxy):GetRecommendShipsForMission(self.mission)

			if #var_13_0 == 0 then
				pg.TipsMgr.GetInstance():ShowTips(i18n("guild_event_recomm_ship_failed"))

				return
			end

			self.contextData.missionShips = var_13_0

			local var_13_1 = {}

			for iter_13_0, iter_13_1 in ipairs(var_13_0) do
				local var_13_2 = getProxy(BayProxy):getShipById(iter_13_1)

				if var_13_2 then
					table.insert(var_13_1, "char/" .. var_13_2:getPrefab())
				end
			end

			SplitPackConst.DownloadByLuaArr(var_13_1, function()
				self:UpdateFleet(self.contextData.index)
			end)
		end)
	end, SFX_PANEL)
	onButton(self, self.clearBtn, function()
		if not self:CheckFormation() then
			return
		end

		self.contextData.missionShips = {}

		self:UpdateFleet(self.contextData.index)
	end, SFX_PANEL)
	onButton(self, self.goBtn, function()
		if self.mission:IsFinish() then
			pg.TipsMgr.GetInstance():ShowTips(i18n("guild_event_is_finish"))

			return
		end

		if not self:CheckFormation() then
			return
		end

		if not self.contextData.missionShips or #self.contextData.missionShips == 0 then
			return
		end

		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			content = i18n("guild_event_start_event_tip"),
			onYes = function()
				self:emit(GuildEventMediator.JOIN_MISSION, self.mission.id, self.contextData.missionShips)
			end
		})
	end, SFX_PANEL)

	self.shipGos = {}
end

function GuildMissionFormationPage:OnShow()
	self.loading = nil
	self.maxShipCnt = self.extraData.shipCnt

	self:UpdateLayout()
	self:Flush(self.extraData.mission)
	self:UpdatePageFooter()
	self:AddNextFormationTimer()
end

function GuildMissionFormationPage:UpdatePageFooter()
	local var_19_0 = self.mission:GetFleetCnt()

	for iter_19_0, iter_19_1 in ipairs(self.pageFooter) do
		setActive(iter_19_1, iter_19_0 <= var_19_0)
		onToggle(self, iter_19_1, function(arg_20_0)
			if arg_20_0 then
				self:UpdateFleet(iter_19_0)
				self:UpdateSwitchBtns()
			end
		end, SFX_PANEL)
	end

	setActive(self.pageFooterAdd, (self.mission:CanFormation()))
	onToggle(self, self.pageFooterAdd, function(arg_21_0)
		if arg_21_0 then
			self:UpdateFleet(var_19_0 + 1)
		end
	end, SFX_PANEL)

	local var_19_1 = self.contextData.index or 1

	if var_19_0 < var_19_1 then
		triggerToggle(self.pageFooterAdd, true)
	else
		triggerToggle(self.pageFooter[var_19_1], true)
	end
end

function GuildMissionFormationPage:UpdateSwitchBtns()
	local var_22_0 = self.mission:GetMaxFleet()
	local var_22_1 = self.contextData.index

	setActive(self.prevBtn, self.contextData.index ~= 1)
	setActive(self.nextBtn, var_22_1 < var_22_0)
end

function GuildMissionFormationPage:AddNextFormationTimer()
	local var_23_0 = self.mission

	if self.mission:IsMaxFleetCnt() then
		return
	end

	local function var_23_1(arg_24_0)
		self.canFormationIndex = var_23_0:GetCanFormationIndex()

		setActive(self.pageFooterAdd, true)

		if arg_24_0 then
			triggerToggle(self.pageFooterAdd, false)
		end

		var_23_0:RecordFormationTip()
		setActive(self.pageFooterAdd:Find("tip"), var_23_0:ShouldShowFormationTip())
		self:UpdateSwitchBtns()
	end

	if not self.mission:CanFormation() then
		self.timer = Timer.New(function()
			self.timer:Stop()

			self.timer = nil

			var_23_1(true)
		end, self.mission:GetNextFormationTime() - pg.TimeMgr.GetInstance():GetServerTime(), 1)

		self.timer:Start()
	else
		var_23_1()
	end
end

function GuildMissionFormationPage:Flush(arg_26_1)
	self.mission = arg_26_1
	self.canFormationIndex = arg_26_1:GetCanFormationIndex()

	self:InitView()
end

function GuildMissionFormationPage:UpdateLayout()
	self.bg.sprite = GetSpriteFromAtlas("ui/GuildFormationUI_atlas", "bg3")

	local var_27_0 = self._tf:Find("frame/single")

	self.shipContainer = var_27_0
	self.bg.gameObject.transform.sizeDelta = Vector2(self.bg.gameObject.transform.sizeDelta.x, 212)

	setActive(var_27_0, true)
end

function GuildMissionFormationPage:InitView()
	if self.initId ~= self.mission.id then
		local var_28_0 = self.mission:GetAwards()

		self.awardList:make(function(arg_29_0, arg_29_1, arg_29_2)
			if arg_29_0 == UIItemList.EventUpdate then
				local var_29_0 = {
					type = var_28_0[arg_29_1 + 1][1],
					id = var_28_0[arg_29_1 + 1][2],
					count = var_28_0[arg_29_1 + 1][3]
				}

				updateDrop(arg_29_2, var_29_0)
				onButton(self, arg_29_2, function()
					self:send(BaseUI.ON_DROP, var_29_0)
				end, SFX_PANEL)
			end
		end)
		self.awardList:align(#var_28_0)

		self.battleAreaTxt.text = self.mission:getConfig("ship_camp_display")
		self.battleTypeTxt.text = self.mission:getConfig("ship_type_display")
		self.titleTxt.text = self.mission:GetName()
		self.initId = self.mission.id
	end
end

function GuildMissionFormationPage:UpdateFleet(arg_31_1)
	self:ClearSlots()

	local var_31_0 = self.mission
	local var_31_1 = self.maxShipCnt
	local var_31_2 = arg_31_1 == self.canFormationIndex and (self.contextData.missionShips or var_31_0:GetFleetByIndex(arg_31_1)) or var_31_0:GetFleetByIndex(arg_31_1)
	local var_31_3 = {}

	var_31_2 = var_31_2 or {}

	for iter_31_0 = 1, var_31_1 do
		local var_31_4 = self.shipContainer:GetChild(iter_31_0 - 1)

		table.insert(var_31_3, function(arg_32_0)
			self:UpdateShipSlot(iter_31_0, var_31_4, var_31_2, arg_32_0)
		end)
	end

	pg.UIMgr.GetInstance():LoadingOn(false)
	parallelAsync(var_31_3, function()
		pg.UIMgr.GetInstance():LoadingOff()
	end)

	if var_31_0:IsEliteType() then
		local var_31_5 = self:GetTagShipCnt(var_31_2)
		local var_31_6 = var_31_0:GetSquadronTargetCnt()
		local var_31_7 = string.format("%s : (<color=%s>%d/%d</color>)", var_31_0:GetSquadronDisplay(), (var_31_6 <= var_31_5 or nil) and (COLOR_GREEN or COLOR_RED), var_31_5, var_31_6)

		self.target2Text.text = HXSet.hxLan(var_31_7)
		self.target2Text4Effect.text = HXSet.hxLan(var_31_7)
	else
		self.target2Text.text = ""
		self.target2Text4Effect.text = ""
	end

	self.effectTxt.text = GuildMission.CalcMyEffect(var_31_2)

	local var_31_8, var_31_9, var_31_10 = self:CalcScoreAddition(var_31_2)

	self.scoreAdditionTxt.text = i18n("guild_word_score_addition") .. var_31_8
	self.effectAdditionTxt.text = i18n("guild_word_effect_addition") .. self:CalcEffectAddition(var_31_2)
	self.target1Text.text = table.concat(self:GetBattleTarget(var_31_9, var_31_10), " 、")
	self.target1Text4Effect.text = self.target1Text.text

	setButtonEnabled(self.goBtn, #var_31_2 > 0)

	local var_31_11 = not var_31_0:CanFormation() or arg_31_1 <= var_31_0:GetFleetCnt()

	setActive(self.inProgressBtn, var_31_11)
	setActive(self.goBtn, not var_31_11)

	self.contextData.index = arg_31_1

	if self.target2Text.text ~= "" and self.target1Text.text ~= "" then
		setText(self._tf:Find("frame/bottom/desc/target/content/title"), i18n("guild_wrod_battle_target"))
	else
		setText(self._tf:Find("frame/bottom/desc/target/content/title"), "")
	end
end

function GuildMissionFormationPage:UpdateShipSlot(arg_34_1, arg_34_2, arg_34_3, arg_34_4)
	local var_34_0 = self.mission
	local var_34_1 = arg_34_3[arg_34_1]
	local var_34_2 = arg_34_2:Find("Image")
	local var_34_3 = arg_34_2:Find("effect")
	local var_34_4 = arg_34_2:Find("score")

	if arg_34_3[arg_34_1] then
		local var_34_5 = getProxy(BayProxy):getShipById(var_34_1)

		if var_34_5 then
			local var_34_6 = var_34_5:getPrefab()

			self.spineChar = SpineAnimChar.New()

			self.spineChar:SetPaint(var_34_6)
			self.spineChar:Load(true, function(arg_35_0)
				arg_35_0:SetName(var_34_6)
				arg_35_0:SetPivot(Vector2(0.5, 0))
				arg_35_0:SetSizeDelta(Vector2(200, 300))
				arg_35_0:SetParent(arg_34_2)
				arg_35_0:SetLocalPosition(Vector3(0, 0, 0))
				arg_35_0:SetLocalScale(Vector3(0.6, 0.6, 0.6))
				arg_35_0:SetAction("stand")
				GetOrAddComponent(arg_35_0:GetModel(), "EventTriggerListener"):AddPointClickFunc(function(arg_36_0, arg_36_1)
					self:emit(GuildEventMediator.ON_SELECT_MISSION_SHIP, var_34_0.id, arg_34_1, arg_34_3)
				end)

				self.shipGos[var_34_1] = arg_35_0

				if arg_34_4 then
					arg_34_4()
				end
			end)
			setActive(var_34_3, self:HasEffectAddition(var_34_5))
			setActive(var_34_4, self:HasScoreAddition(var_34_5))
		elseif arg_34_4 then
			arg_34_4()
		end
	else
		onButton(self, var_34_2, function()
			self:emit(GuildEventMediator.ON_SELECT_MISSION_SHIP, var_34_0.id, arg_34_1, arg_34_3)
		end, SFX_PANEL)
		setActive(var_34_3, false)
		setActive(var_34_4, false)

		if arg_34_4 then
			arg_34_4()
		end
	end

	setActive(var_34_2, not var_34_1)
end

function GuildMissionFormationPage:CheckFormation()
	if self.contextData.index ~= self.canFormationIndex then
		pg.TipsMgr.GetInstance():ShowTips(i18n("guild_curr_fleet_can_not_edit"))

		return false
	end

	local var_38_1, var_38_2 = self.mission:CanFormation()

	if not var_38_1 then
		if var_38_2 then
			pg.TipsMgr.GetInstance():ShowTips(i18n("guild_next_edit_fleet_time", var_38_2))
		end

		return false
	end

	return true
end

function GuildMissionFormationPage:emit(...)
	if self.loading then
		return
	end

	if not self:CheckFormation() then
		return
	end

	GuildMissionFormationPage.super.emit(self, ...)
end

function GuildMissionFormationPage:send(...)
	GuildMissionFormationPage.super.emit(self, ...)
end

function GuildMissionFormationPage:GetBattleTarget(arg_41_1, arg_41_2)
	local var_41_0 = {}

	for iter_41_0, iter_41_1 in pairs((self.mission:GetAttrCntAcc())) do
		local var_41_1 = arg_41_1[iter_41_0] or 0

		table.insert(var_41_0, GuildMissionInfoPage.AttrCnt2Desc(iter_41_0, {
			value = iter_41_1.value + var_41_1,
			total = iter_41_1.total,
			goal = iter_41_1.goal,
			score = iter_41_1.score
		}))
	end

	for iter_41_2, iter_41_3 in pairs((self.mission:GetAttrAcc())) do
		local var_41_2 = arg_41_2[iter_41_2] or 0

		table.insert(var_41_0, GuildMissionInfoPage.AttrAcc2Desc(iter_41_2, {
			value = iter_41_3.value + var_41_2,
			op = iter_41_3.op,
			goal = iter_41_3.goal,
			score = iter_41_3.score
		}))
	end

	return var_41_0
end

function GuildMissionFormationPage:GetTagShipCnt(arg_42_1)
	local var_42_0 = self.mission:GetSquadron()
	local var_42_1 = 0
	local var_42_2 = getProxy(BayProxy)

	for iter_42_0, iter_42_1 in ipairs(arg_42_1) do
		local var_42_3 = var_42_2:getShipById(iter_42_1)

		if var_42_3 and var_42_3:IsTagShip(var_42_0) then
			var_42_1 = var_42_1 + 1
		end
	end

	return var_42_1
end

function GuildMissionFormationPage:CalcScoreAddition(arg_43_1)
	local var_43_0 = self.mission:GetAttrCntAcc()
	local var_43_1 = self.mission:GetAttrAcc()
	local var_43_2 = pg.attribute_info_by_type
	local var_43_3 = 0
	local var_43_4 = {}
	local var_43_5 = {}
	local var_43_6 = getProxy(BayProxy)

	for iter_43_0, iter_43_1 in ipairs(arg_43_1) do
		local var_43_7 = var_43_6:getShipById(iter_43_1)
		local var_43_8

		if var_43_7 then
			var_43_8 = _.detect(self.mission:getConfig("ship_camp_effect"), function(arg_44_0)
				return arg_44_0[1] == var_43_7:getNation()
			end)
		end

		if var_43_8 then
			var_43_3 = var_43_3 + var_43_8[2]
		end

		local var_43_9 = var_43_7 and var_43_7:getProperties() or {}

		for iter_43_2, iter_43_3 in pairs(var_43_0) do
			if (var_43_9[var_43_2[iter_43_2].name] or 0) >= iter_43_3.total then
				var_43_4[iter_43_2] = (var_43_4[iter_43_2] or 0) + 1
			end
		end

		for iter_43_4, iter_43_5 in pairs(var_43_1) do
			var_43_5[iter_43_4] = (var_43_5[iter_43_4] or 0) + (var_43_9[var_43_2[iter_43_4].name] or 0)
		end
	end

	for iter_43_6, iter_43_7 in pairs(var_43_0) do
		if (var_43_4[iter_43_6] or 0) + iter_43_7.value >= iter_43_7.goal then
			var_43_3 = var_43_3 + iter_43_7.score
		end
	end

	for iter_43_8, iter_43_9 in pairs(var_43_1) do
		local var_43_15 = iter_43_9.value + (var_43_5[iter_43_8] or 0)
		local var_43_16

		if iter_43_9.op == 1 then
			var_43_16 = var_43_15 >= iter_43_9.goal
		elseif iter_43_9.op == 2 then
			var_43_16 = var_43_15 <= iter_43_9.goal
		end

		if var_43_16 then
			var_43_3 = var_43_3 + iter_43_9.score
		end
	end

	return var_43_3, var_43_4, var_43_5
end

function GuildMissionFormationPage:getResource()
	local var_45_0 = GuildMissionFormationPage.super.getResource(self)

	for iter_45_0, iter_45_1 in ipairs((getProxy(GuildProxy):getData():GetActiveEvent():GetMissions())) do
		for iter_45_2, iter_45_3 in ipairs(iter_45_1) do
			for iter_45_4, iter_45_5 in ipairs((iter_45_3:GetMyShips())) do
				local var_45_1 = getProxy(BayProxy):getShipById(iter_45_5)

				if var_45_1 then
					local var_45_2 = var_45_1:getPrefab()

					table.insert(var_45_0, "char/" .. var_45_2)
					table.insert(var_45_0, "herohrzicon/" .. var_45_2)
				end
			end
		end
	end

	return var_45_0
end

function GuildMissionFormationPage:CalcEffectAddition(arg_46_1)
	local var_46_0 = GuildMission.CalcMyEffect(arg_46_1)
	local var_46_1 = getProxy(BayProxy)

	for iter_46_0, iter_46_1 in ipairs(arg_46_1) do
		local var_46_2 = var_46_1:getShipById(iter_46_1)
		local var_46_3

		if var_46_2 then
			var_46_3 = _.detect(self.mission:getConfig("ship_type_effect"), function(arg_47_0)
				return arg_47_0[1] == var_46_2:getShipType()
			end)
		end

		if var_46_3 then
			var_46_0 = var_46_0 + var_46_3[2]
		end
	end

	return var_46_0 * ((self.mission:GetSquadronTargetCnt() <= self:GetTagShipCnt(arg_46_1) and self.mission:IsEliteType() or nil) and self.mission:GetSquadronRatio())
end

function GuildMissionFormationPage:HasScoreAddition(arg_48_1)
	local var_48_0 = self.mission:GetAttrCntAcc()
	local var_48_1 = self.mission:GetAttrAcc()

	return table.contains(self.mission:GetRecommendShipNation(), arg_48_1:getNation()) or (function()
		local var_49_0 = arg_48_1:getProperties()

		for iter_49_0, iter_49_1 in pairs(var_48_0) do
			assert(var_49_0[pg.attribute_info_by_type[iter_49_0].name], pg.attribute_info_by_type[iter_49_0].name)

			if (var_49_0[pg.attribute_info_by_type[iter_49_0].name] or 0) >= iter_49_1.total then
				return true
			end
		end

		for iter_49_2, iter_49_3 in pairs(var_48_1) do
			assert(var_49_0[pg.attribute_info_by_type[iter_49_2].name], pg.attribute_info_by_type[iter_49_2].name)

			if iter_49_3.op == 1 then
				return (var_49_0[pg.attribute_info_by_type[iter_49_2].name] or 0) > 0
			elseif iter_49_3.op == 2 then
				return (var_49_0[pg.attribute_info_by_type[iter_49_2].name] or 0) == 0
			end
		end

		return false
	end)()
end

function GuildMissionFormationPage:HasEffectAddition(arg_50_1)
	return table.contains(self.mission:GetRecommendShipTypes(), arg_50_1:getShipType()) or arg_50_1:IsTagShip((self.mission:GetSquadron()))
end

function GuildMissionFormationPage:ClearSlots()
	for iter_51_0, iter_51_1 in pairs(self.shipGos) do
		iter_51_1:SetPivot(Vector2(0.5, 0.5))
		GetOrAddComponent(iter_51_1:GetModel(), "EventTriggerListener"):RemovePointClickFunc()
		iter_51_1:SetActionCallBack(nil)
		iter_51_1:Dispose()
	end

	self.shipGos = {}
end

function GuildMissionFormationPage:Hide()
	GuildMissionFormationPage.super.Hide(self)
	self:ClearSlots()

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

return GuildMissionFormationPage
