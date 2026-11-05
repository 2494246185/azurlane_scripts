local WorldChapterAutoRewardLayer = class("WorldChapterAutoRewardLayer", BaseUI)

function WorldChapterAutoRewardLayer:getUIName()
	return "WorldChapterAutoRewardUI"
end

local var_0_1 = 0.1

function WorldChapterAutoRewardLayer:init()
	self.window = self._tf:Find("Window")
	self.boxView = self.window:Find("Layout/Box/ScrollView")

	setActive(self.boxView, true)

	self.emptyTip = self.window:Find("Layout/Box/EmptyTip")
	self.itemList = self.boxView:Find("Content/ItemGrid")

	setText(self.emptyTip, i18n("autofight_rewards_none"))
	setActive(self.emptyTip, false)
	setText(self.window:Find("Fixed/top/bg/obtain/title"), i18n("autofight_rewards"))
	setText(self.boxView:Find("Content/Title/Text"), i18n("battle_end_subtitle1"))

	self.buffTF = self.boxView:Find("Content/TextArea")
	self.eventTF = self.boxView:Find("Content/TextArea_1")
	self.proficiencyTF = self.boxView:Find("Content/TextArea_2")
end

function WorldChapterAutoRewardLayer:didEnter()
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
	self:UpdateView()

	local var_3_0 = getProxy(MetaCharacterProxy):getMetaTacticsInfoOnEnd()

	if var_3_0 and #var_3_0 > 0 then
		self.metaExpView = MetaExpView.New(self.window:Find("Layout"), self.event, self.contextData)

		self.metaExpView:setData(var_3_0)
		self.metaExpView:Reset()
		self.metaExpView:Load()
		self.metaExpView:ActionInvoke("Show")
	end
end

function WorldChapterAutoRewardLayer:willExit()
	self:SkipAnim()

	if self.metaExpView then
		self.metaExpView:Destroy()
	end

	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)
end

function WorldChapterAutoRewardLayer:UpdateView()
	local var_5_0 = self.contextData

	onButton(self, self._tf:Find("BG"), function()
		if self.isRewardAnimating then
			self:SkipAnim()

			return
		end

		existCall(var_5_0.onClose)
		self:closeView()
	end)
	setText(self.window:Find("Fixed/ButtonExit/pic"), i18n("autofight_leave"))
	onButton(self, self.window:Find("Fixed/ButtonExit"), function()
		existCall(var_5_0.onClose)
		self:closeView()
	end, SFX_CANCEL)

	local var_5_1 = {}

	setActive(self.boxView:Find("Content/Title"), false)
	setActive(self.itemList, false)
	setActive(self.buffTF, false)
	setActive(self.eventTF, false)
	setActive(self.proficiencyTF, false)

	self.hasRewards = #self.contextData.awards > 0

	if self.hasRewards then
		isEmpty = false

		table.insert(var_5_1, function(arg_8_0)
			setActive(self.boxView:Find("Content/Title"), true)
			setActive(self.itemList, true)
			arg_8_0()
		end)

		local var_5_2 = CustomIndexLayer.Clone2Full(self.itemList, #self.contextData.awards)

		for iter_5_0, iter_5_1 in ipairs(self.contextData.awards) do
			updateDrop(var_5_2[iter_5_0]:Find("Shell/Icon"), iter_5_1)
			onButton(self, var_5_2[iter_5_0]:Find("Shell/Icon"), function()
				self:emit(BaseUI.ON_DROP, iter_5_1)
			end, SFX_PANEL)
		end

		self.isRewardAnimating = true

		for iter_5_2 = 1, #self.contextData.awards do
			local var_5_4 = var_5_2[iter_5_2]

			setActive(var_5_2[iter_5_2], false)
			table.insert(var_5_1, function(arg_10_0)
				if self.exited then
					return
				end

				setActive(var_5_4, true)
				scrollTo(self.boxView:Find("Content"), {
					y = 0
				})

				self.LTid = LeanTween.delayedCall(var_0_1, System.Action(arg_10_0)).uniqueId
			end)
		end
	end

	self.hasBuffMsg = false

	local var_5_5 = nowWorld()
	local var_5_6 = {}

	for iter_5_3, iter_5_4 in ipairs(self.contextData.buffInfos) do
		if var_5_6[iter_5_4.id] then
			-- block empty
		else
			var_5_6[iter_5_4.id] = iter_5_4.before
		end
	end

	local var_5_7 = underscore.map(pg.gameset.world_mapbuff_list.description, function(arg_11_0)
		if not var_5_6[arg_11_0] then
			return 0
		else
			return var_5_5:GetGlobalBuff(arg_11_0):GetFloor() - var_5_6[arg_11_0]
		end
	end)

	if underscore.any(var_5_7, function(arg_12_0)
		return arg_12_0 ~= 0
	end) then
		self.hasBuffMsg = true
		self.buffMsg = i18n("autofight_effect", unpack(var_5_7))
	end

	if self.hasBuffMsg then
		setText(self.buffTF:Find("Text"), self.buffMsg)
		table.insert(var_5_1, function(arg_13_0)
			setActive(self.buffTF, true)
			arg_13_0()
		end)
	end

	seriesAsync(var_5_1, function()
		self:SkipAnim()
	end)
end

function WorldChapterAutoRewardLayer:SkipAnim()
	if not self.isRewardAnimating then
		return
	end

	self.isRewardAnimating = nil

	if self.LTid then
		LeanTween.cancel(self.LTid)

		self.LTid = nil
	end

	eachChild(self.itemList, function(arg_16_0)
		setActive(arg_16_0, true)
	end)
	setActive(self.boxView:Find("Content/Title"), self.hasRewards)
	setActive(self.itemList, self.hasRewards)
	setActive(self.buffTF, self.hasBuffMsg)
	self:UpdateEvent()
	setActive(self.proficiencyTF, self.contextData.proficiency > 0)

	if self.contextData.proficiency > 0 then
		setText(self.proficiencyTF:Find("Text"), i18n("auto_battle_end_exp", self.contextData.proficiency))
	end
end

function WorldChapterAutoRewardLayer:UpdateEvent()
	local var_17_0 = getProxy(ChapterAutoProxy):GetNewEventIds()

	setActive(self.eventTF, #var_17_0 > 0)

	if #var_17_0 <= 0 then
		return
	end

	local var_17_1 = {}

	for iter_17_0, iter_17_1 in ipairs(var_17_0) do
		table.insert(var_17_1, i18n("autofight_entrust", (pg.collection_template[iter_17_1] or nil) and (pg.collection_template[iter_17_1].title or "")))
	end

	setText(self.eventTF:Find("Text"), table.concat(var_17_1, "\n"))
end

return WorldChapterAutoRewardLayer
