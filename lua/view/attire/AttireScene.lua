local AttireScene = class("AttireScene", import("..base.BaseUI"))

AttireScene.PAGE_ICONFRAME = 1
AttireScene.PAGE_CHATFRAME = 2
AttireScene.PAGE_ACHIEVEMENT = 3

function AttireScene:getUIName()
	return "AttireUI"
end

function AttireScene:getResource()
	local function var_2_0(arg_3_0, arg_3_1)
		if noEmptyStr(arg_3_1) and not table.contains(arg_3_0, arg_3_1) then
			table.insert(arg_3_0, arg_3_1)
		end
	end

	return ResPathSupport.MergeLuaArr({
		"ui/attireui",
		"ui/attireiconframeui",
		"ui/attirechatframeui",
		"ui/attireachievementui",
		"ui/attirecombatuiui",
		"ui/attireloadingpicui"
	}, (function()
		local var_4_0 = getProxy(AttireProxy):getAllData()
		local var_4_1 = {}

		for iter_4_0, iter_4_1 in ipairs(pg.item_data_frame.all) do
			if var_4_0.iconFrames[iter_4_1] then
				var_2_0(var_4_1, var_4_0.iconFrames[iter_4_1]:getIcon())
			end
		end

		for iter_4_2, iter_4_3 in ipairs(pg.item_data_chat.all) do
			if var_4_0.chatFrames[iter_4_3] then
				var_2_0(var_4_1, var_4_0.chatFrames[iter_4_3]:getIcon())
			end
		end

		for iter_4_4, iter_4_5 in ipairs(pg.item_data_battleui.all) do
			if var_4_0.combatUIStyles[iter_4_5] then
				local var_4_2 = var_4_0.combatUIStyles[iter_4_5]:getConfig("icon")

				if noEmptyStr(var_4_2) then
					var_2_0(var_4_1, "combatuistyle/" .. var_4_2)
				end
			end
		end

		return var_4_1
	end)(), (function()
		local var_5_0 = {}

		local function var_5_1(arg_6_0)
			if not arg_6_0 then
				return
			end

			if arg_6_0:isLoverLetter() then
				var_2_0(var_5_0, string.lower(arg_6_0:GetPrefabName()))
				table.insertto(var_5_0, ResPathSupport.GetPaintingSquareIconListByPaintingName(arg_6_0:GetPainting()))
			else
				local var_6_0 = arg_6_0:getConfig("icon")

				var_2_0(var_5_0, "medal/" .. var_6_0)
				var_2_0(var_5_0, "medal/s_" .. var_6_0)
			end
		end

		local var_5_2 = getProxy(AttireProxy):getDataAndTrophys()

		for iter_5_0, iter_5_1 in pairs(var_5_2.trophys or {}) do
			if iter_5_1:isClaimed() and not iter_5_1:isHide() then
				var_5_1(iter_5_1)
			end
		end

		for iter_5_2, iter_5_3 in ipairs(var_5_2.loveTrophys or {}) do
			if iter_5_3:isClaimed() and not iter_5_3:isHide() then
				var_5_1(iter_5_3)
			end
		end

		for iter_5_4, iter_5_5 in ipairs(getProxy(PlayerProxy):getData().displayTrophyList or {}) do
			var_5_1(iter_5_5 > 1000000000 and LoveLetterTrophy.New({
				id = iter_5_5
			}) or Trophy.New({
				id = iter_5_5
			}))
		end

		return var_5_0
	end)(), (CombatPreviewLayer.PushAllResource()))
end

function AttireScene:setAttires(arg_7_1)
	self.rawAttireVOs = arg_7_1

	self:updateTips(getProxy(AttireProxy):needTip(arg_7_1))
end

function AttireScene:setPlayer(arg_8_1)
	self.playerVO = arg_8_1
end

function AttireScene:init()
	self.backBtn = self._tf:Find("blur_panel/adapt/top/back_btn")
	self.blurPanel = self._tf:Find("blur_panel")
	self.toggles = {
		self.blurPanel:Find("adapt/left_length/frame/tagRoot/iconframe"),
		self.blurPanel:Find("adapt/left_length/frame/tagRoot/chatframe"),
		self.blurPanel:Find("adapt/left_length/frame/tagRoot/achievement"),
		self.blurPanel:Find("adapt/left_length/frame/tagRoot/combatUI"),
		self.blurPanel:Find("adapt/left_length/frame/tagRoot/loadingpic")
	}
	self.panels = {
		AttireIconFramePanel.New(self._tf, self.event, self.contextData),
		AttireChatFramePanel.New(self._tf, self.event, self.contextData),
		AttireAchievementPanel.New(self._tf, self.event, self.contextData),
		AttireCombatUIPanel.New(self._tf, self.event, self.contextData),
		AttireLoadingPicPanel.New(self._tf, self.event, self.contextData)
	}
end

function AttireScene:didEnter()
	onButton(self, self.backBtn, function()
		self:emit(AttireScene.ON_BACK)
	end, SOUND_BACK)

	for iter_10_0, iter_10_1 in ipairs(self.toggles) do
		onToggle(self, iter_10_1, function(arg_12_0)
			if arg_12_0 then
				self:switchPage(iter_10_0)
			end
		end, SFX_PANEL)
	end

	triggerToggle(self.toggles[self.contextData.index or AttireScene.PAGE_ICONFRAME], true)
end

function AttireScene:switchPage(arg_13_1)
	if self.page then
		self.panels[self.page]:ActionInvoke("Hide")
	end

	self.page = arg_13_1

	self.panels[self.page]:Load()
	self.panels[self.page]:ActionInvoke("Show")
	self:updateCurrPage()
end

function AttireScene:updateCurrPage()
	assert(self.page)
	self.panels[self.page]:ActionInvoke("Update", self.rawAttireVOs, self.playerVO)
end

function AttireScene:updateTips(arg_15_1)
	for iter_15_0, iter_15_1 in ipairs(arg_15_1) do
		setActive(self.toggles[iter_15_0]:Find("tip"), iter_15_1)
	end
end

function AttireScene:onBackPressed()
	if self.panels[self.page].onBackPressed and self.panels[self.page]:onBackPressed() then
		-- block empty
	else
		AttireScene.super.onBackPressed(self)
	end
end

function AttireScene:willExit()
	for iter_17_0, iter_17_1 in ipairs(self.panels) do
		iter_17_1:Destroy()
	end
end

return AttireScene
