local GuildMissionInfoPage = class("GuildMissionInfoPage", import(".GuildEventBasePage"))
local var_0_1 = 10001

function GuildMissionInfoPage:AttrCnt2Desc(arg_1_1)
	return i18n("guild_event_info_desc1", pg.attribute_info_by_type[self].condition, arg_1_1.total, (arg_1_1.value >= arg_1_1.goal or nil) and (COLOR_GREEN or COLOR_RED), arg_1_1.value, arg_1_1.goal)
end

function GuildMissionInfoPage:AttrAcc2Desc(arg_2_1)
	local var_2_0 = pg.attribute_info_by_type[self]

	assert(pg.attribute_info_by_type[self], self)

	local var_2_1

	if arg_2_1.op == 1 then
		var_2_1 = arg_2_1.value >= arg_2_1.goal and COLOR_GREEN or COLOR_RED
	elseif arg_2_1.op == 2 then
		var_2_1 = arg_2_1.value <= arg_2_1.goal and COLOR_GREEN or COLOR_RED
	end

	assert(var_2_1)

	return i18n("guild_event_info_desc2", var_2_0.condition, var_2_1, arg_2_1.value, arg_2_1.goal)
end

function GuildMissionInfoPage:getUIName()
	return "GuildMissionInfoPage"
end

function GuildMissionInfoPage:OnLoaded()
	self.closeBtn = self._tf:Find("top/close")
	self.sea = self._tf:Find("bg/sea"):GetComponent(typeof(RawImage))
	self.titleTxt = self._tf:Find("top/title/Text"):GetComponent(typeof(Text))
	self.logBtn = self._tf:Find("bottom/log_btn")
	self.formationBtn = self._tf:Find("bottom/formationBtn")
	self.doingBtn = self._tf:Find("bottom/doing_btn")
	self.helpBtn = self._tf:Find("bottom/help")
	self.logPanel = self._tf:Find("log_panel")
	self.logList = UIItemList.New(self.logPanel:Find("scrollrect/content"), self.logPanel:Find("scrollrect/content/tpl"))
	self.peopleCnt = self._tf:Find("bottom/cnt/Text"):GetComponent(typeof(Text))
	self.effectCnt = self._tf:Find("bottom/effect/Text"):GetComponent(typeof(Text))

	setText(self._tf:Find("bottom/cnt"), i18n("guild_join_member_cnt"))
	setText(self._tf:Find("bottom/effect"), i18n("guild_total_effect"))

	self.areaTxt = self._tf:Find("top/title/Text/target/area"):GetComponent(typeof(Text))
	self.goalTxt = self._tf:Find("top/title/Text/target/goal"):GetComponent(typeof(Text))
	self.timeTxt = self._tf:Find("bottom/progress/time/Text"):GetComponent(typeof(Text))
	self.nodesUIlist = UIItemList.New(self._tf:Find("bottom/progress/nodes"), self._tf:Find("bottom/progress/nodes/tpl"))
	self.progress = self._tf:Find("bottom/progress")
	self.nodeLength = self.progress.rect.width
	self.healTF = self._tf:Find("resources/heal")
	self.nameTF = self._tf:Find("resources/name")
end

function GuildMissionInfoPage:OnInit()
	onButton(self, self.closeBtn, function()
		self.contextData.mission = nil

		self:Hide()
	end, SFX_PANEL)
	onButton(self, self.helpBtn, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.guild_mission_info_tip.tip
		})
	end, SFX_PANEL)
	onButton(self, self.logBtn, function()
		if self.isShowLogPanel then
			self:ShowOrHideLogPanel(false)
		else
			self:ShowOrHideLogPanel(true)
		end
	end, SFX_PANEL)
	onButton(self, self.logPanel, function()
		self:ShowOrHideLogPanel(false)
	end, SFX_PANEL)
	onButton(self, self.formationBtn, function()
		if self.mission:IsFinish() then
			pg.TipsMgr.GetInstance():ShowTips(i18n("guild_event_is_finish"))

			return
		end

		self:emit(GuildEventLayer.OPEN_MISSION_FORAMTION, self.mission)
	end, SFX_PANEL)
	onButton(self, self.doingBtn, function()
		triggerButton(self.formationBtn)
	end, SFX_PANEL)
end

function GuildMissionInfoPage:OnRefreshMission(arg_12_1)
	self:Flush(arg_12_1)
end

function GuildMissionInfoPage:OnShow()
	self:Flush(self.extraData.mission)
	self:EnterFormation()
	self:AddOtherShipMoveTimer()
end

function GuildMissionInfoPage:Flush(arg_14_1)
	self.mission = arg_14_1

	self:InitBattleSea()
	self:InitView()
	self:AddRefreshProgressTimer()
end

function GuildMissionInfoPage:EnterFormation()
	if self.contextData.missionShips then
		triggerButton(self.formationBtn)
	end
end

function GuildMissionInfoPage:InitView()
	local var_16_0 = self.mission

	self.titleTxt.text = self.mission:GetName()
	self.peopleCnt.text = self.mission:GetJoinMemberCnt() .. "/" .. self.guild.memberCount .. i18n("guild_word_people")
	self.effectCnt.text = self.mission:GetEfficiency() .. "(" .. self.mission:GetMyEffect() .. ")"
	self.areaTxt.text = i18n("guild_word_battle_area") .. table.concat(_.map(self.mission:GetNations(), function(arg_17_0)
		return i18n("guild_event_info_desc3", Nation.Nation2Name(arg_17_0), #var_16_0:GetShipsByNation(arg_17_0))
	end), " 、")

	local var_16_1 = table.concat(GuildMissionInfoPage.GetBattleTarget(self.mission), " 、")

	if var_16_1 ~= "" then
		self.goalTxt.text = i18n("guild_wrod_battle_target") .. var_16_1
	end

	setActive(self.goalTxt.gameObject, var_16_1 ~= "")
	self:UpdateNodes()
	self:UpdateFormationBtn()
end

function GuildMissionInfoPage:UpdateFormationBtn()
	local var_18_0 = self.mission:CanFormation()

	setActive(self.formationBtn, var_18_0)
	setActive(self.doingBtn, not var_18_0)
end

function GuildMissionInfoPage:GetBattleTarget()
	local var_19_0 = {}

	for iter_19_0, iter_19_1 in pairs((self:GetAttrCntAcc())) do
		table.insert(var_19_0, GuildMissionInfoPage.AttrCnt2Desc(iter_19_0, iter_19_1))
	end

	for iter_19_2, iter_19_3 in pairs((self:GetAttrAcc())) do
		table.insert(var_19_0, GuildMissionInfoPage.AttrAcc2Desc(iter_19_2, iter_19_3))
	end

	return var_19_0
end

function GuildMissionInfoPage:UpdateNodes()
	self.nodes = {}

	local var_20_0 = self.mission:GetNodes()
	local var_20_1 = 1

	if not self.mission:IsFinish() then
		self.nodesUIlist:make(function(arg_21_0, arg_21_1, arg_21_2)
			if arg_21_0 == UIItemList.EventUpdate then
				local var_21_0 = var_20_0[arg_21_1 + 1]:GetPosition()

				arg_21_2:GetComponent(typeof(Image)).sprite = GetSpriteFromAtlas("ui/GuildMissionInfoUI_atlas", var_21_0)

				setAnchoredPosition(arg_21_2, {
					x = self.nodeLength * (var_21_0 / 100)
				})

				arg_21_2:Find("item"):GetComponent(typeof(Image)).sprite = LoadSprite("GuildNode/" .. var_20_0[arg_21_1 + 1]:GetIcon())

				table.insert(self.nodes, arg_21_2)
			end
		end)
		self.nodesUIlist:align(#var_20_0)

		var_20_1 = self.mission:GetProgress()
	end

	setSlider(self.progress, 0, 100, var_20_1 * 100)
end

function GuildMissionInfoPage:InitBattleSea()
	if self.loading then
		return
	end

	self.loading = true

	local var_22_0 = {}

	if not self.battleView then
		self.battleView = GuildMissionBattleView.New(self.sea)

		self.battleView:configUI(self.healTF, self.nameTF)
		table.insert(var_22_0, function(arg_23_0)
			self.battleView:load(var_0_1, arg_23_0)
		end)
	end

	local var_22_1 = self.mission:GetMyFlagShip()
	local var_22_2
	local var_22_3 = {}
	local var_22_4 = ""

	if var_22_1 then
		var_22_2 = getProxy(BayProxy):getShipById(var_22_1) or Ship.New({
			id = 9999,
			configId = 101171
		})

		local var_22_5 = math.floor(var_22_2.configId / 10)

		for iter_22_0 = 1, 4 do
			local var_22_6 = pg.ship_data_breakout[tonumber(var_22_5 .. iter_22_0)]

			for iter_22_1, iter_22_2 in ipairs((var_22_6 or nil) and (var_22_6.weapon_ids or {})) do
				if not table.contains(var_22_3, iter_22_2) then
					table.insert(var_22_3, iter_22_2)
				end
			end
		end

		var_22_4 = getProxy(PlayerProxy):getRawData().name
	end

	table.insert(var_22_0, function(arg_24_0)
		self:downloadBattleShipResList(var_22_2, var_22_3, arg_24_0)
	end)
	table.insert(var_22_0, function(arg_25_0)
		self.battleView:LoadShip(var_22_2, var_22_3, var_22_4, function()
			if var_22_2 then
				self:CheckNodesState()
			end

			arg_25_0()
		end)
	end)
	seriesAsync(var_22_0, function()
		self.loading = false
	end)
end

function GuildMissionInfoPage:AddOtherShipMoveTimer()
	local function var_28_0(arg_29_0)
		local var_29_0 = {}
		local var_29_1 = self.mission:GetOtherShips()

		if #var_29_1 == 0 then
			return var_29_0
		end

		if arg_29_0 >= #var_29_1 then
			return var_29_1
		end

		shuffle(var_29_1)

		for iter_29_0 = 1, arg_29_0 do
			table.insert(var_29_0, var_29_1[iter_29_0])
		end

		return var_29_0
	end

	local function var_28_2()
		if self.timer then
			self.timer:Stop()

			self.timer = nil
		end

		self.timer = Timer.New(function()
			self.battleView:PlayOtherShipAnim(var_28_0((math.random(1, 2))), var_28_2)
		end, math.random(30, 150), 1)

		self.timer:Start()
	end

	;(nil)()
end

function GuildMissionInfoPage:CheckNodesState()
	local var_32_0 = self.mission:GetNewestSuccessNode()

	if var_32_0 then
		local var_32_1 = var_32_0:GetPosition()

		if self.mission:GetNodeAnimPosistion() < var_32_1 then
			(function(arg_33_0)
				if arg_33_0:IsItemType() then
					self.battleView:PlayItemAnim()
				elseif arg_33_0:IsBattleType() then
					self.battleView:PlayAttackAnim()
				end
			end)(var_32_0)
			self:emit(GuildEventMediator.ON_UPDATE_NODE_ANIM_FLAG, self.mission.id, var_32_1)
		end
	end
end

function GuildMissionInfoPage:AddRefreshProgressTimer()
	self:RemoveCdTimer()
	self:RemoveRefreshTimer()

	local var_34_0 = self.mission
	local var_34_1 = self.mission:GetTotalTimeCost()
	local var_34_2 = not self.mission:IsFinish() and var_34_1 > 0

	if var_34_2 then
		assert(var_34_1 > 900, var_34_1)

		self.refreshTimer = Timer.New(function()
			self:RemoveRefreshTimer()
			self:emit(GuildEventMediator.FORCE_REFRESH_MISSION, var_34_0.id)
		end, var_34_1 * 0.01, 1)

		self.refreshTimer:Start()

		local var_34_3 = var_34_0:GetRemainingTime()

		if var_34_3 > 0 then
			self.cdTimer = Timer.New(function()
				var_34_3 = var_34_3 - 1

				if var_34_3 <= 0 then
					self:RemoveCdTimer()
					setActive(self.timeTxt.gameObject.transform.parent, false)
				else
					self.timeTxt.text = pg.TimeMgr.GetInstance():DescCDTime(var_34_3)
				end
			end, 1, -1)

			self.cdTimer:Start()
			self.cdTimer.func()
		else
			setActive(self.timeTxt.gameObject.transform.parent, false)
		end
	end

	setActive(self.timeTxt.gameObject.transform.parent, var_34_2)
end

function GuildMissionInfoPage:RemoveCdTimer()
	if self.cdTimer then
		self.cdTimer:Stop()

		self.cdTimer = nil
	end
end

function GuildMissionInfoPage:getResource()
	local var_38_0 = GuildMissionInfoPage.super.getResource(self)

	local function var_38_1(arg_39_0)
		if not table.contains(var_38_0, arg_39_0) then
			table.insert(var_38_0, arg_39_0)
		end
	end

	var_38_1("guildnode/box")
	var_38_1("guildnode/battle")
	var_38_1("ui/guildmissioninfoui_atlas")
	var_38_1("ui/guildformationui_atlas")
	table.insertto(var_38_0, ys.Battle.BattleResourceManager.GetDisplayCommonResource())
	table.insertto(var_38_0, ys.Battle.BattleResourceManager.GetMapResource(var_0_1))
	var_38_1(ys.Battle.BattleResourceManager.GetCharacterPath(pg.enemy_data_statistics[10].prefab))
	var_38_1(ys.Battle.BattleResourceManager.GetCharacterPath(pg.enemy_data_statistics[1028].prefab))

	for iter_38_0, iter_38_1 in ipairs((getProxy(GuildProxy):getData():GetActiveEvent():GetMissions())) do
		for iter_38_2, iter_38_3 in ipairs(iter_38_1) do
			for iter_38_4, iter_38_5 in ipairs((iter_38_3:GetMyShips())) do
				local var_38_2 = getProxy(BayProxy):getShipById(iter_38_5)

				if var_38_2 then
					local var_38_3 = var_38_2:getPrefab()

					table.insert(var_38_0, "char/" .. var_38_3)
					table.insert(var_38_0, "herohrzicon/" .. var_38_3)
				end
			end
		end
	end

	return var_38_0
end

function GuildMissionInfoPage:downloadBattleShipResList(arg_40_1, arg_40_2, arg_40_3)
	local var_40_0 = {}

	if arg_40_1 then
		table.insert(var_40_0, ys.Battle.BattleResourceManager.GetCharacterPath(arg_40_1:getPrefab()))

		if arg_40_1:getShipType() ~= ShipType.WeiXiu then
			for iter_40_0, iter_40_1 in ipairs(arg_40_2) do
				if iter_40_1 ~= 0 then
					for iter_40_2, iter_40_3 in ipairs(ys.Battle.BattleDataFunction.GetWeaponDataFromID(iter_40_1).weapon_id) do
						for iter_40_4, iter_40_5 in ipairs((ys.Battle.BattleResourceManager.GetWeaponResource(iter_40_3))) do
							if not table.contains(var_40_0, iter_40_5) and string.sub(iter_40_5, -#"/") ~= "/" then
								table.insert(var_40_0, iter_40_5)
							end
						end
					end
				end
			end
		end
	end

	if #var_40_0 == 0 then
		arg_40_3()

		return
	end

	SplitPackConst.DownloadByLuaArr(var_40_0, function()
		if not self.loading then
			return
		end

		arg_40_3()
	end)
end

function GuildMissionInfoPage:ShowOrHideLogPanel(arg_42_1, arg_42_2)
	arg_42_2 = arg_42_2 or 0.3

	if LeanTween.isTweening(self.logPanel) then
		return
	end

	local var_42_0 = self.logPanel.rect.width + 300

	LeanTween.value(self.logPanel.gameObject, arg_42_1 and var_42_0 or 0, arg_42_1 and 0 or var_42_0, arg_42_2):setOnUpdate(System.Action_float(function(arg_43_0)
		setAnchoredPosition(self.logPanel, {
			x = arg_43_0
		})
	end)):setOnComplete(System.Action(function()
		if not arg_42_1 then
			setActive(self.logPanel, false)
		end
	end))

	self.isShowLogPanel = arg_42_1

	if arg_42_1 then
		setActive(self.logPanel, true)
		self:InitLogs()
	end
end

function GuildMissionInfoPage:InitLogs()
	local var_45_0 = self.mission:GetLogs()

	self.logList:make(function(arg_46_0, arg_46_1, arg_46_2)
		if arg_46_0 == UIItemList.EventUpdate then
			setText(arg_46_2, var_45_0[arg_46_1 + 1])
		end
	end)
	self.logList:align(#var_45_0)
end

function GuildMissionInfoPage:RemoveRefreshTimer()
	if self.refreshTimer then
		self.refreshTimer:Stop()

		refreshTimer = nil
	end
end

function GuildMissionInfoPage:Hide()
	self:ShowOrHideLogPanel(false, 0)
	GuildMissionInfoPage.super.Hide(self)

	if self.battleView then
		self.battleView:clear()

		self.battleView = nil
	end

	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end

	self:RemoveRefreshTimer()
	self:RemoveCdTimer()
end

return GuildMissionInfoPage
