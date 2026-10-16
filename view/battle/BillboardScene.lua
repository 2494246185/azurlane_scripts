local BillboardScene = class("BillboardScene", import("..base.BaseUI"))

BillboardScene.SINGLE_SHOW = {
	PowerRank.TYPE_EXTRA_CHAPTER,
	PowerRank.TYPE_ACT_BOSS_BATTLE,
	PowerRank.TYPE_BOSSRUSH
}

function BillboardScene:getUIName()
	return "BillboardUI"
end

function BillboardScene:getResource()
	local var_2_0 = {
		"commonbg/bg_fengshan",
		"billboardframe",
		"weaponframes",
		"shiptype",
		"ui/iconcolorful"
	}

	local function var_2_1(arg_3_0)
		if noEmptyStr(arg_3_0) and not table.contains(var_2_0, arg_3_0) then
			table.insert(var_2_0, arg_3_0)
		end
	end

	for iter_2_0, iter_2_1 in pairs(PowerRank.typeInfo) do
		if iter_2_1.score_icon and iter_2_1.score_icon[1] then
			var_2_1(iter_2_1.score_icon[1])
		end
	end

	for iter_2_2, iter_2_3 in ipairs((getProxy(ActivityProxy):getActivitiesByType(ActivityConst.ACTIVITY_TYPE_PT_RANK))) do
		if not iter_2_3:isEnd() and tonumber(iter_2_3:getConfig("config_data")) > 0 then
			var_2_1((Drop.New({
				type = DROP_TYPE_RESOURCE,
				id = iter_2_3:getConfig("config_id")
			}):getIcon()))
		end
	end

	local var_2_2 = checkExist(self.contextData, {
		"page"
	}) or PowerRank.TYPE_POWER
	local var_2_3 = getProxy(BillboardProxy):getRankList(var_2_2, checkExist(self.contextData, {
		"act_id"
	}) or checkExist(PowerRank:getActivityByRankType(var_2_2), {
		"id"
	}))

	for iter_2_4, iter_2_5 in ipairs(var_2_3 or {}) do
		var_2_1("emblem/" .. iter_2_5.arenaRank)
		var_2_1("emblem/n_" .. iter_2_5.arenaRank)
	end

	if not var_2_3 then
		for iter_2_6 = 1, #pg.arena_data_rank.all do
			var_2_1("emblem/" .. iter_2_6)
			var_2_1("emblem/n_" .. iter_2_6)
		end
	end

	local var_2_4 = getProxy(MilitaryExerciseProxy):RawGetSeasonInfo()

	if var_2_4 then
		local var_2_5 = SeasonInfo.getEmblem(var_2_4.score, var_2_4.rank)

		var_2_1("emblem/" .. var_2_5)
		var_2_1("emblem/n_" .. var_2_5)
	end

	return table.insertto(var_2_0, BillboardScene.super.getResource(self))
end

function BillboardScene:updateRankList(arg_4_1, arg_4_2, arg_4_3, arg_4_4)
	self.rankVOs = self.rankVOs or {}
	self.playerRankVOs = self.playerRankVOs or {}
	self.rankVOs[arg_4_1] = arg_4_2
	self.ptRanks = self.ptRanks or {}

	if arg_4_1 == PowerRank.TYPE_PT then
		assert(arg_4_4)

		self.ptRanks[arg_4_4] = arg_4_2
		self.playerPTRankVOMap = self.playerPTRankVOMap or {}
		self.playerPTRankVOMap[arg_4_4] = arg_4_3
	end

	self.playerRankVOs[arg_4_1] = arg_4_3
end

function BillboardScene:init()
	self.blurPanel = self._tf:Find("blur_panel")
	self.rankRect = self._tf:Find("main/frame/ranks"):GetComponent("LScrollRect")
	self.playerRankTF = self._tf:Find("main/frame/player_rank")

	setActive(self.playerRankTF, false)

	self.topPanel = self.blurPanel:Find("adapt/top")
	self.leftPanel = self.blurPanel:Find("adapt/left_length")
	self.mainPanel = self._tf:Find("main")
	self.extraChapterBg = self._tf:Find("extra_chapter_bg")
	self.toggleScrollRect = self.leftPanel:Find("frame/scroll_rect")
	self.toggleContainer = self.leftPanel:Find("frame/scroll_rect/tagRoot")
	self.listEmptyTF = self._tf:Find("main/frame/empty")

	setActive(self.listEmptyTF, false)

	self.listEmptyTxt = self.listEmptyTF:Find("Text")

	setText(self.listEmptyTxt, i18n("list_empty_tip_billboardui"))

	self.toggles = {
		self.leftPanel:Find("frame/scroll_rect/tagRoot/power"),
		self.leftPanel:Find("frame/scroll_rect/tagRoot/collection"),
		self.leftPanel:Find("frame/scroll_rect/tagRoot/pt"),
		self.leftPanel:Find("frame/scroll_rect/tagRoot/pledge"),
		self.leftPanel:Find("frame/scroll_rect/tagRoot/chanllenge"),
		self.leftPanel:Find("frame/scroll_rect/tagRoot/extra_chapter"),
		self.leftPanel:Find("frame/scroll_rect/tagRoot/boss_battle"),
		self.leftPanel:Find("frame/scroll_rect/tagRoot/guild"),
		self.leftPanel:Find("frame/scroll_rect/tagRoot/military"),
		self.leftPanel:Find("frame/scroll_rect/tagRoot/bossrush")
	}
	self.ptToggles = {}

	local var_5_0 = _.filter(getProxy(ActivityProxy):getActivitiesByType(ActivityConst.ACTIVITY_TYPE_PT_RANK), function(arg_6_0)
		return not arg_6_0:isEnd() and arg_6_0:IsShowRank()
	end)

	if #var_5_0 > 1 then
		for iter_5_0, iter_5_1 in pairs(var_5_0) do
			self.ptToggles[iter_5_1.id] = cloneTplTo(self.toggles[3], self.toggles[3].parent)
		end

		self.toggles[3] = nil
	end

	self:updateToggles()

	self.rankRect.decelerationRate = 0.07

	local var_5_1 = self.contextData.page or PowerRank.TYPE_POWER

	if table.contains(BillboardScene.SINGLE_SHOW, var_5_1) then
		setActive(self.leftPanel, false)
		setAnchoredPosition(self.mainPanel, Vector2(0, -35.5))
		setImageSprite(self.extraChapterBg, (GetSpriteFromAtlas("commonbg/bg_fengshan", "")))
	end

	setActive(self.extraChapterBg, var_5_1 == PowerRank.TYPE_EXTRA_CHAPTER)
end

function BillboardScene:updateToggles()
	for iter_7_0, iter_7_1 in pairs(self.toggles) do
		setActive(iter_7_1, PowerRank.typeInfo[iter_7_0].act_type and PowerRank:getActivityByRankType(iter_7_0) or (iter_7_0 ~= PowerRank.TYPE_PLEDGE or false) and (iter_7_0 == PowerRank.TYPE_GUILD_BATTLE and true or true))
	end

	for iter_7_2, iter_7_3 in pairs(self.ptToggles) do
		local var_7_1 = getProxy(ActivityProxy):getActivityById(iter_7_2)

		setActive(iter_7_3, var_7_1 and not var_7_1:isEnd())
	end

	setActive(self.toggleContainer, true)
	Canvas.ForceUpdateCanvases()

	self.toggleContainer:GetComponent(typeof(ScrollRect)).enabled = self.toggleScrollRect.rect.height < self.toggleContainer.rect.height
end

function BillboardScene:didEnter()
	onButton(self, self.topPanel:Find("back_btn"), function()
		self:emit(BillboardScene.ON_BACK)
	end, SFX_CANCEL)

	for iter_8_0, iter_8_1 in pairs(self.toggles) do
		onToggle(self, iter_8_1, function(arg_10_0)
			if iter_8_0 == PowerRank.TYPE_GUILD_BATTLE then
				setActive(self.mainPanel, not arg_10_0)
				self:emit(BillboardMediator.ON_GUILD_RANK, arg_10_0)

				return
			end

			if arg_10_0 then
				self:switchPage(iter_8_0, (checkExist(PowerRank:getActivityByRankType(iter_8_0), {
					"id"
				})))
			end
		end, SFX_PANEL)
	end

	for iter_8_2, iter_8_3 in pairs(self.ptToggles) do
		onToggle(self, iter_8_3, function(arg_11_0)
			if arg_11_0 then
				self:switchPage(PowerRank.TYPE_PT, iter_8_2)
			end
		end, SFX_PANEL)
	end

	self.cards = {}

	function self.rankRect.onInitItem(arg_12_0)
		self:onInintItem(arg_12_0)
	end

	function self.rankRect.onUpdateItem(arg_13_0, arg_13_1)
		self:onUpdateItem(arg_13_0, arg_13_1, self.curPagePTActID)
	end

	function self.rankRect.onReturnItem(arg_14_0, arg_14_1)
		self:onReturnItem(arg_14_0, arg_14_1)
	end

	self.playerCard = RankCard.New(self.playerRankTF, RankCard.TYPE_SELF)

	triggerToggle(self.toggles[self.contextData.page or PowerRank.TYPE_POWER], true)
end

function BillboardScene:onInintItem(arg_15_1)
	local var_15_0 = RankCard.New(arg_15_1, RankCard.TYPE_OTHER)

	onButton(self, var_15_0._tf, function()
		if var_15_0.rankVO.type == PowerRank.TYPE_MILITARY_RANK then
			self:emit(BillboardMediator.OPEN_RIVAL_INFO, var_15_0.rankVO.id)
		end
	end)

	self.cards[arg_15_1] = var_15_0
end

function BillboardScene:onUpdateItem(arg_17_1, arg_17_2, arg_17_3)
	if not self.cards[arg_17_2] then
		self:onInintItem(arg_17_2)
	end

	self.cards[arg_17_2]:update(self.displayRankVOs[arg_17_1 + 1], arg_17_3)
end

function BillboardScene:onReturnItem(arg_18_1, arg_18_2)
	if self.exited then
		return
	end

	if self.cards[arg_18_2] then
		self.cards[arg_18_2]:clear()
	end
end

function BillboardScene:filter(arg_19_1, arg_19_2)
	if arg_19_1 ~= self.page then
		return
	end

	local var_19_0 = self.page
	local var_19_1

	if PowerRank.TYPE_PT == arg_19_1 then
		assert(arg_19_2)

		var_19_1 = self.ptRanks[arg_19_2]
	else
		var_19_1 = self.rankVOs[var_19_0]
	end

	local function var_19_2()
		self.displayRankVOs = {}

		for iter_20_0, iter_20_1 in ipairs(var_19_1) do
			table.insert(self.displayRankVOs, iter_20_1)
		end

		self.rankRect:SetTotalCount(#self.displayRankVOs)
		setActive(self.listEmptyTF, #self.displayRankVOs <= 0)

		if PowerRank.TYPE_PT == arg_19_1 then
			self.playerCard:update(self.playerPTRankVOMap[arg_19_2], arg_19_2)
		else
			self.playerCard:update(self.playerRankVOs[self.page], arg_19_2)
		end
	end

	if var_19_1 and #var_19_1 > 0 then
		local var_19_3 = {}

		for iter_19_0, iter_19_1 in ipairs(var_19_1) do
			table.insert(var_19_3, "squareicon/" .. iter_19_1:getPainting())
		end

		SplitPackConst.DownloadByLuaArr(var_19_3, function()
			var_19_2()
		end)
	else
		var_19_2()
	end
end

function BillboardScene:switchPage(arg_22_1, arg_22_2)
	if self.page == arg_22_1 and arg_22_1 ~= PowerRank.TYPE_PT then
		return
	end

	self.curPagePTActID = arg_22_1 == PowerRank.TYPE_PT and arg_22_2 or nil
	self.page = arg_22_1

	local var_22_0

	if self.page == PowerRank.TYPE_PT then
		assert(arg_22_2)

		var_22_0 = self.ptRanks[arg_22_2]
	else
		var_22_0 = self.rankVOs[arg_22_1]
	end

	if not var_22_0 then
		self.rankRect:SetTotalCount(0)
		self.playerCard:clear()
		self:emit(BillboardMediator.FETCH_RANKS, self.page, arg_22_2)
	else
		self:filter(self.page, arg_22_2)
	end

	setActive(self.topPanel:Find("tip"), not table.contains(BillboardProxy.NONTIMER, self.page))
	self:updateScoreTitle(self.page, arg_22_2)
end

function BillboardScene:updateScoreTitle(arg_23_1, arg_23_2)
	local var_23_0 = self._tf:Find("main/frame/title")
	local var_23_1 = PowerRank:getTitleWord(arg_23_1, arg_23_2)

	for iter_23_0 = 1, 4 do
		setText(var_23_0:GetChild(iter_23_0 - 1), var_23_1[iter_23_0])
	end
end

function BillboardScene:willExit()
	for iter_24_0, iter_24_1 in ipairs(self.cards) do
		iter_24_1:dispose()
	end

	self.playerCard:dispose()

	if self.name then
		retPaintingPrefab(self.paintingTF, self.name)
	end
end

return BillboardScene
