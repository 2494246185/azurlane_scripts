local LevelInfoSPView = class("LevelInfoSPView", import(".LevelInfoView"))

function LevelInfoSPView:getUIName()
	return "LevelInfoSPUI"
end

function LevelInfoSPView:getResource()
	return table.insertto({
		"ui/levelmainscene_atlas"
	}, LevelInfoSPView.super.getResource(self))
end

function LevelInfoSPView:InitUI()
	LevelInfoSPView.super.InitUI(self)

	self.levelBanner = self._tf:Find("panel/Level")
	self.btnSwitchNormal = self._tf:Find("panel/Difficulty/Normal")
	self.btnSwitchHard = self._tf:Find("panel/Difficulty/Hard")
	self.tfAnim = self._tf:GetComponent(typeof(Animation))
	self.tfAniEvent = self._tf:GetComponent(typeof(DftAniEvent))

	self.tfAniEvent:SetEndEvent(function()
		self:playSelectFX()
	end)

	self.diffBtn = self._tf:Find("panel/Difficulty")
	self.btnAnim = self._tf:Find("panel/Difficulty"):GetComponent(typeof(Animation))
	self.btnAniEvent = self._tf:Find("panel/Difficulty"):GetComponent(typeof(DftAniEvent))

	self.btnAniEvent:SetEndEvent(function()
		self:playButtonLoopFX()
	end)

	self.btnAnimNormal = self._tf:Find("panel/Difficulty/Mask_Normal")
	self.btnAnimHard = self._tf:Find("panel/Difficulty/Mask_Difficlty")
	self.btnAnimLoopNormal = self._tf:Find("panel/Difficulty/Normal/Mask_Normal_Loop/Image")
	self.btnAnimLoopHard = self._tf:Find("panel/Difficulty/Hard/Mask_Difficulty_Loop")
	self.doEaseIn = false
end

function LevelInfoSPView:playSelectFX()
	local var_6_0 = 1

	if #self.groupInfo > 1 then
		var_6_0 = table.indexof(self.groupInfo, self.chapter.id)
	elseif self.chapter:IsSpChapter() or self.chapter:IsEXChapter() then
		var_6_0 = 2
	end

	if #self.groupInfo > 1 then
		if var_6_0 == 2 then
			setActive(self.btnAnimNormal, false)
			setActive(self.btnAnimLoopNormal, false)
			quickPlayAnimation(self.diffBtn, "Anim_LevelInfoSPUI_DifficultySelected")
		else
			setActive(self.btnAnimHard, false)
			setActive(self.btnAnimLoopHard, false)
			quickPlayAnimation(self.diffBtn, "Anim_LevelInfoSPUI_NormalSelected")
		end
	end
end

function LevelInfoSPView:playButtonLoopFX()
	if self.btnAnim:IsPlaying("Anim_LevelInfoSPUI_DifficultySelected") then
		quickPlayAnimation(self.diffBtn, "Anim_LevelInfoSPUI_DifficultyInLoop")
	elseif self.btnAnim:IsPlaying("Anim_LevelInfoSPUI_NormalSelected") then
		quickPlayAnimation(self.diffBtn, "Anim_LevelInfoSPUI_NormalInLoop")
	end
end

function LevelInfoSPView:SetChapterGroupInfo(arg_8_1)
	self.groupInfo = arg_8_1
end

function LevelInfoSPView:Show()
	pg.UIMgr.GetInstance():BlurPanel(self._tf, {
		force = true
	})
	setActive(self._tf, true)
	quickPlayAnimation(self._tf, "Anim_LevelInfoSPUI_in")
	self:CheckGuide()
end

function LevelInfoSPView:setAfterResDownload(arg_10_1, arg_10_2, arg_10_3)
	LevelInfoSPView.super.setAfterResDownload(self, arg_10_1, arg_10_2, arg_10_3)

	local var_10_0 = self.groupInfo

	assert(self.groupInfo)

	local var_10_1 = {
		"Normal",
		"Hard"
	}
	local var_10_2 = 1
	local var_10_3

	if #var_10_0 > 1 then
		local var_10_4 = table.indexof(var_10_0, arg_10_1)

		var_10_2 = var_10_4
		var_10_3 = var_10_0[#var_10_0 - var_10_4 + 1]
	elseif arg_10_3:IsSpChapter() or arg_10_3:IsEXChapter() then
		var_10_2 = 2
	end

	for iter_10_0, iter_10_1 in ipairs(var_10_1) do
		setActive(self.titleBG:Find(iter_10_1), iter_10_0 == var_10_2)
	end

	for iter_10_2, iter_10_3 in ipairs(var_10_1) do
		setActive(self.levelBanner:Find(iter_10_3), iter_10_2 == var_10_2)
	end

	setActive(self.btnSwitchNormal, #var_10_0 > 1 and var_10_2 == 1)
	setActive(self.btnSwitchHard, #var_10_0 > 1 and var_10_2 == 2)

	if #var_10_0 > 1 then
		for iter_10_4 = 1, 2 do
			local var_10_5 = ((var_10_2 == 1 or nil) and (self.btnSwitchNormal or self.btnSwitchHard)):Find("Bonus" .. iter_10_4)
			local var_10_6 = getProxy(ChapterProxy):getChapterById(var_10_0[iter_10_4], true)
			local var_10_7 = var_10_6:GetDailyBonusQuota()

			setActive(var_10_5, var_10_7)

			if var_10_7 then
				GetImageSpriteFromAtlasAsync("ui/levelmainscene_atlas", "bonusX" .. var_10_6:GetDailyBonusRate(), var_10_5:Find("Image"), true)

				local var_10_8 = getProxy(ChapterProxy)
				local var_10_9 = var_10_8:getMapById(var_10_6:getConfig("map"))
				local var_10_10 = getProxy(ActivityProxy)
				local var_10_11 = var_10_10:getActivityById(var_10_9:getConfig("on_activity"))

				GetImageSpriteFromAtlasAsync((var_10_8 and (var_10_11 and var_10_11:GetConfigClientPTActivity() or nil):GetPTDrop()).getIcon(var_10_10), "", var_10_5:Find("Image/icon"), true)
			end
		end
	end

	local var_10_12 = var_10_2 == 1 and Color.NewHex("FFDE38") or Color.white

	setTextColor(self.txTitle:Find("title_index"), var_10_12)
	setTextColor(self.txTitle:Find("title"), var_10_12)
	setTextColor(self.txTitle:Find("title_en"), var_10_12)

	local var_10_13 = arg_10_3:getConfig("boss_expedition_id")

	if arg_10_3:getPlayType() == ChapterConst.TypeMultiStageBoss then
		var_10_13 = pg.chapter_model_multistageboss[arg_10_3.id].boss_expedition_id
	end

	setText(self.levelBanner:Find("Text"), "LV " .. pg.expedition_data_template[var_10_13[#var_10_13]].level)
	onButton(self, self.btnSwitchNormal:Find("Switch"), function()
		setActive(self.btnAnimNormal, false)
		setActive(self.btnAnimLoopNormal, false)
		quickPlayAnimation(self.diffBtn, "Anim_LevelInfoSPUI_DifficultySelected")
		self:emit(LevelUIConst.SWITCH_SPCHAPTER_DIFFICULTY, var_10_3)
		self:set(var_10_3)
	end, SFX_PANEL)
	onButton(self, self.btnSwitchHard:Find("Switch"), function()
		setActive(self.btnAnimHard, false)
		setActive(self.btnAnimLoopHard, false)
		quickPlayAnimation(self.diffBtn, "Anim_LevelInfoSPUI_NormalSelected")
		self:emit(LevelUIConst.SWITCH_SPCHAPTER_DIFFICULTY, var_10_3)
		self:set(var_10_3)
	end, SFX_PANEL)
	;(function()
		if IsUnityEditor and not ENABLE_GUIDE then
			return
		end

		if var_10_2 ~= 1 or #var_10_0 == 1 then
			return
		end

		local var_13_0 = "NG0045"

		if pg.NewStoryMgr.GetInstance():IsPlayed("NG0045") then
			return
		end

		pg.SystemGuideMgr.GetInstance():PlayByGuideId(var_13_0)
	end)()
end

return LevelInfoSPView
