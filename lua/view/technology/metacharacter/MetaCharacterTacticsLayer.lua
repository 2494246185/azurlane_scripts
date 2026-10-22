local MetaCharacterTacticsLayer = class("MetaCharacterTacticsLayer", import("...base.BaseUI"))

function MetaCharacterTacticsLayer:getUIName()
	return "MetaCharacterTacticsUI"
end

function MetaCharacterTacticsLayer:getResource()
	local var_2_0 = {}
	local var_2_1 = {}
	local var_2_2 = self.contextData.shipID and getProxy(BayProxy):getShipById(self.contextData.shipID)

	if var_2_2 then
		local var_2_3 = var_2_2:getMetaCharacter()

		if var_2_3 then
			local var_2_4, var_2_5 = MetaCharacterConst.GetMetaCharacterPaintPath(var_2_3.id, true)

			table.insert(var_2_0, var_2_4)
		end

		for iter_2_0, iter_2_1 in ipairs((MetaCharacterConst.getTacticsSkillIDListByShipConfigID(var_2_2.configId))) do
			local var_2_6 = getSkillConfig(iter_2_1)

			if var_2_6 and var_2_6.icon then
				table.insert(var_2_1, ResPathSupport.CombinePath("skillicon", var_2_6.icon))
			end
		end
	end

	return ResPathSupport.MergeLuaArr(MetaCharacterTacticsLayer.super.getResource(self), {
		"ui/metacharactertacticsui",
		"ui/iconcolorful"
	}, var_2_0, var_2_1)
end

function MetaCharacterTacticsLayer:init()
	self:initUITextTips()
	self:initData()
	self:initUI()
	self:addListener()
end

function MetaCharacterTacticsLayer:didEnter()
	self:updateRedTag()
	self:updateShipImg()
	self:updateNamePanel()
	self:updateChar()
	self:updateSkillListPanel()
	self:enablePartialBlur()

	if self.contextData.isMainOpen then
		self.contextData.isMainOpen = nil

		self:moveShipImg(true)
	end

	self:moveRightPanel()
end

function MetaCharacterTacticsLayer:willExit()
	self:moveShipImg(false)
	self:recycleChar()
	self:disablePartialBlur()
end

function MetaCharacterTacticsLayer:onBackPressed()
	if isActive(self.skillUnlockPanel) then
		self:closeUnlockSkillPanel()

		return
	else
		self:emit(MetaCharacterTacticsLayer.ON_BACK_PRESSED)
	end
end

function MetaCharacterTacticsLayer:initUITextTips()
	setText(self._tf:Find("ExpPanel"):Find("ExpEveryDay"), i18n("meta_exp_per_day"))
	setText(self._tf:Find("TaskPanel/StudySkillTip/TipText"), i18n("meta_skill_unlock"))
end

function MetaCharacterTacticsLayer:initData()
	self.metaCharacterProxy = getProxy(MetaCharacterProxy)
	self.bayProxy = getProxy(BayProxy)
	self.shipPrefab = nil
	self.shipModel = nil
	self.curMetaShipID = self.contextData.shipID
	self.curShipVO = nil
	self.curMetaCharacterVO = nil

	self:updateData()

	self.skillBtnList = {}
	self.curUnlockSkillID = nil
	self.curUnlockMaterialID = nil
	self.curUnlockMaterialNeedCount = nil
end

function MetaCharacterTacticsLayer:updateData()
	self.curShipVO = self.bayProxy:getShipById(self.curMetaShipID)
	self.curMetaCharacterVO = self.curShipVO:getMetaCharacter()
end

function MetaCharacterTacticsLayer:setTacticsData(arg_10_1)
	self.doubleExpValue = arg_10_1.doubleExp
	self.normalExpValue = arg_10_1.normalExp
	self.curSkillID = arg_10_1.curSkillID
	self.switchCountLeft = arg_10_1.switchCount
	self.taskInfoTable = arg_10_1.taskInfoTable
	self.skillExpTable = arg_10_1.skillExpTable
	arg_10_1 = nil
end

function MetaCharacterTacticsLayer:switchTacticsSkillData(arg_11_1, arg_11_2)
	self.curSkillID = arg_11_1
	self.switchCountLeft = arg_11_2
end

function MetaCharacterTacticsLayer:levelupTacticsSkillData(arg_12_1, arg_12_2)
	self.skillExpTable[arg_12_1] = 0
	self.switchCountLeft = arg_12_2

	self:clearTaskInfo()
end

function MetaCharacterTacticsLayer:updateSkillExp(arg_13_1, arg_13_2)
	self.skillExpTable[arg_13_1] = arg_13_2
end

function MetaCharacterTacticsLayer:clearTaskInfo(arg_14_1)
	self.taskInfoTable[arg_14_1] = {}
end

function MetaCharacterTacticsLayer:initUI()
	self.shipImg = self._tf:Find("ShipImg")
	self.nameTF = self._tf:Find("NamePanel")
	self.nameScrollText = self.nameTF:Find("NameMask/NameText")
	self.shipTypeImg = self.nameTF:Find("TypeImg")
	self.enNameText = self.nameTF:Find("NameENText")
	self.nameTFStarUIList = UIItemList.New(self.nameTF:Find("StarContainer"), (self.nameTF:Find("StarTpl")))
	self.expPanel = self._tf:Find("ExpPanel")
	self.expText = self.expPanel:Find("ExpText")
	self.expDoubleTag = self.expText:Find("DoubleTag")
	self.taskPanel = self._tf:Find("TaskPanel")
	self.qCharContainer = self.taskPanel:Find("QChar")
	self.taskTpl = self.taskPanel:Find("TaskTpl")
	self.taskScrollTF = self.taskPanel:Find("ScrollView")
	self.taskTplContainer = self.taskPanel:Find("ScrollView/Viewport/Content")
	self.taskScrollBar = self.taskPanel:Find("ScrollView/Scrollbar Vertical")
	self.taskUIItemList = UIItemList.New(self.taskTplContainer, self.taskTpl)
	self.skillInfoPanel = self.taskPanel:Find("SkillInfo")
	self.curSkillIcon = self.skillInfoPanel:Find("Skill/Icon")
	self.curSkillNameScrollText = self.skillInfoPanel:Find("NameMask/Name")
	self.curSkillLevelText = self.skillInfoPanel:Find("LevelInfo/CurLevel")
	self.nextSkillLevelText = self.skillInfoPanel:Find("LevelInfo/NextLevel")
	self.curSkillDescText = self.skillInfoPanel:Find("DescView/Viewport/SkillDesc")
	self.curSkillProgressText = self.skillInfoPanel:Find("ExpProgress/Text")
	self.curSkillProgressSlider = self.skillInfoPanel:Find("ExpSlider")
	self.curSkillQuickBtn = self.skillInfoPanel:Find("QuickBtn")
	self.studySkillTip = self.taskPanel:Find("StudySkillTip")
	self.startSkillTip = self.taskPanel:Find("StartLearn")
	self.maxSkillTip = self.taskPanel:Find("SkillMax")
	self.studySkillBtn = self.startSkillTip:Find("StartLearnBtn")
	self.skillPanel = self._tf:Find("SkillPanel")
	self.skillTpl = self.skillPanel:Find("SkillTpl")
	self.skillContainer = self.skillPanel:Find("Skills/Content")
	self.skillUIItemList = UIItemList.New(self.skillContainer, self.skillTpl)
	self.skillUnlockPanel = self._tf:Find("SkillLearnBox")
	self.skillUnlockPanelBG = self.skillUnlockPanel:Find("BG")
	self.skillUnlockPanelTipText = self.skillUnlockPanel:Find("Box/TipText")
	self.skillUnlockPanelCancelBtn = self.skillUnlockPanel:Find("Box/Btns/CancenBtn")
	self.skillUnlockPanelConfirmBtn = self.skillUnlockPanel:Find("Box/Btns/ConfirmBtn")
	self.materialTpl = self.skillUnlockPanel:Find("Box/Material")
	self.materialTplContainer = self.skillUnlockPanel:Find("Box/MaterialContainer")
	self.materialUIItemList = UIItemList.New(self.materialTplContainer, self.materialTpl)
end

function MetaCharacterTacticsLayer:addListener()
	onButton(self, self.skillUnlockPanelBG, function()
		self:closeUnlockSkillPanel()
	end, SFX_PANEL)
	onButton(self, self.skillUnlockPanelCancelBtn, function()
		self:closeUnlockSkillPanel()
	end, SFX_PANEL)
	onButton(self, self.skillUnlockPanelConfirmBtn, function()
		if not self.curUnlockMaterialID then
			pg.TipsMgr.GetInstance():ShowTips(i18n("meta_unlock_skill_select"))

			return
		elseif getProxy(BagProxy):getItemCountById(self.curUnlockMaterialID) < self.curUnlockMaterialNeedCount then
			pg.TipsMgr.GetInstance():ShowTips(i18n("word_materal_no_enough"))
		else
			local var_19_0 = 0
			local var_19_1 = 0

			for iter_19_0, iter_19_1 in ipairs(self:getMetaSkillTacticsConfigBySkillID(self.curUnlockSkillID, 1).skill_unlock) do
				if self.curUnlockMaterialID == iter_19_1[2] then
					var_19_0 = iter_19_0
					var_19_1 = iter_19_1[3]

					break
				end
			end

			pg.m02:sendNotification(GAME.TACTICS_META_UNLOCK_SKILL, {
				shipID = self.curMetaShipID,
				skillID = self.curUnlockSkillID,
				materialIndex = var_19_0,
				materialInfo = {
					id = self.curUnlockMaterialID,
					count = var_19_1
				}
			})
		end
	end, SFX_PANEL)
end

function MetaCharacterTacticsLayer:updateRedTag()
	self.metaCharacterProxy:updateRedTag(self.curMetaCharacterVO.id)
end

function MetaCharacterTacticsLayer:updateShipImg()
	local var_21_0, var_21_1 = MetaCharacterConst.GetMetaCharacterPaintPath(self.curMetaCharacterVO.id, true)

	setImageSprite(self.shipImg, LoadSprite(var_21_0, var_21_1), true)
	setLocalPosition(self.shipImg, {
		x = MetaCharacterConst.UIConfig[self.curMetaCharacterVO.id][7],
		y = MetaCharacterConst.UIConfig[self.curMetaCharacterVO.id][8]
	})
	setLocalScale(self.shipImg, {
		x = MetaCharacterConst.UIConfig[self.curMetaCharacterVO.id][3],
		y = MetaCharacterConst.UIConfig[self.curMetaCharacterVO.id][4]
	})
end

function MetaCharacterTacticsLayer:updateNamePanel()
	setScrollText(self.nameScrollText, (self.curShipVO:getName()))
	setImageSprite(self.shipTypeImg, LoadSprite("shiptype", (self.curShipVO:getShipType())))
	setText(self.enNameText, (self.curShipVO:getConfig("english_name")))

	local var_22_1 = self.curShipVO:getStar()

	self.nameTFStarUIList:make(function(arg_23_0, arg_23_1, arg_23_2)
		if arg_23_0 == UIItemList.EventUpdate then
			local var_23_0 = arg_23_2:Find("empty")

			arg_23_1 = arg_23_1 + 1

			setActive(arg_23_2:Find("on"), arg_23_1 <= var_22_1)
		end
	end)
	self.nameTFStarUIList:align((self.curShipVO:getMaxStar()))
end

function MetaCharacterTacticsLayer:updateChar()
	return
end

function MetaCharacterTacticsLayer:recycleChar()
	if self.shipPrefab and self.shipModel then
		PoolMgr.GetInstance():ReturnSpineChar(self.shipPrefab, self.shipModel)

		self.shipPrefab = nil
		self.shipModel = nil
	end
end

function MetaCharacterTacticsLayer:updateSkillListPanel()
	local var_26_1 = self:getSkillIDListForShow(self.curShipVO.configId)

	self.skillUIItemList:make(function(arg_27_0, arg_27_1, arg_27_2)
		if arg_27_0 == UIItemList.EventUpdate then
			if var_26_1[arg_27_1 + 1] then
				self.skillBtnList[var_26_1[arg_27_1 + 1]] = arg_27_2

				self:updateSkillTF(arg_27_2, var_26_1[arg_27_1 + 1])
			end
		end
	end)
	self.skillUIItemList:align(#var_26_1)
end

function MetaCharacterTacticsLayer:updateSkillTF(arg_28_1, arg_28_2)
	local var_28_1 = arg_28_1:Find("Skill/Level")
	local var_28_2 = arg_28_1:Find("Skill/Arrow")
	local var_28_3 = arg_28_1:Find("Lock")
	local var_28_4 = arg_28_1:Find("Learning")
	local var_28_5 = getSkillConfig(arg_28_2)
	local var_28_6 = self.curShipVO:getMetaSkillLevelBySkillID(arg_28_2)

	setImageSprite(arg_28_1:Find("Skill/Icon"), LoadSprite("skillicon/" .. var_28_5.icon))
	setScrollText(arg_28_1:Find("Skill/Mask/Name"), getSkillName(var_28_5.id))

	if var_28_6 > 0 then
		setText(var_28_1, "LEVEL: " .. var_28_6)
		setActive(var_28_3, false)
		onButton(self, arg_28_1, function()
			if not isActive(var_28_2) then
				eachChild(self.skillContainer, function(arg_30_0)
					setActive(arg_30_0:Find("Skill/Arrow"), false)
				end)
				setActive(var_28_2, true)
				self:updateTaskPanel(arg_28_2)
			end
		end, SFX_PANEL)
	else
		setText(var_28_1, "LEVEL: ??")
		setActive(var_28_3, true)
		onButton(self, arg_28_1, function()
			self:openUnlockSkillPanel(arg_28_2)
		end, SFX_PANEL)
	end
end

function MetaCharacterTacticsLayer:updateSkillTFLearning()
	for iter_32_0, iter_32_1 in pairs(self.skillBtnList) do
		setActive(iter_32_1:Find("Learning"), iter_32_0 == self.curSkillID and not self.curShipVO:isSkillLevelMax(iter_32_0))
	end
end

function MetaCharacterTacticsLayer:TryPlayGuide()
	pg.SystemGuideMgr.GetInstance():PlayByGuideId("NG0025")
end

function MetaCharacterTacticsLayer:updateExpPanel()
	if self:isAllSkillLock() or self:isAllSkillMaxLevel() then
		setActive(self.expPanel, false)
	elseif self.curSkillID > 0 then
		setActive(self.expPanel, true)

		local var_34_0 = pg.gameset.meta_skill_exp_double.key_value

		setText(self.expText, self.normalExpValue .. "/" .. pg.gameset.meta_skill_exp_max.key_value)
		setActive(self.expDoubleTag, var_34_0 > self.doubleExpValue)
	else
		setActive(self.expPanel, false)
	end
end

function MetaCharacterTacticsLayer:updateSkillInfoPanel(arg_35_1)
	local var_35_0 = getSkillConfig(arg_35_1)

	setImageSprite(self.curSkillIcon, LoadSprite("skillicon/" .. var_35_0.icon))
	setScrollText(self.curSkillNameScrollText, getSkillName(var_35_0.id))

	local var_35_1 = pg.skill_data_template[arg_35_1].max_level
	local var_35_2 = self.curShipVO:getMetaSkillLevelBySkillID(arg_35_1)
	local var_35_3 = pg.skill_data_template[arg_35_1].max_level <= var_35_2

	setText(self.curSkillLevelText, var_35_2)
	setText(self.nextSkillLevelText, (math.min(var_35_2 + 1, var_35_1)))
	setText(self.curSkillDescText, getSkillDesc(arg_35_1, self.curShipVO:getMetaSkillLevelBySkillID(arg_35_1)))
	setActive(self.curSkillQuickBtn, not var_35_3 and not LOCK_META_SKILL_QUICK)
	onButton(self, self.curSkillQuickBtn, function()
		self:emit(MetaCharacterTacticsMediator.ON_QUICK, self.curShipVO.id, arg_35_1)
	end, SFX_PANEL)

	local var_35_4 = self.skillExpTable[arg_35_1] or 0

	if not var_35_3 then
		local var_35_5 = self:getMetaSkillTacticsConfigBySkillID(arg_35_1, var_35_2).need_exp

		setText(self.curSkillProgressText, var_35_4 .. "/" .. var_35_5)
		setSlider(self.curSkillProgressSlider, 0, var_35_5, var_35_4)

		if var_35_4 < var_35_5 then
			-- block empty
		end
	else
		setText(self.curSkillProgressText, var_35_4 .. "/Max")
		setSlider(self.curSkillProgressSlider, 0, 1, 1)
	end
end

function MetaCharacterTacticsLayer:updateTaskListPanel(arg_37_1)
	local var_37_0 = self:sortTaskConfig(arg_37_1, self:getMetaSkillTacticsConfigBySkillID(arg_37_1, (self.curShipVO:getMetaSkillLevelBySkillID(arg_37_1))).skill_levelup_task)

	self.taskUIItemList:make(function(arg_38_0, arg_38_1, arg_38_2)
		if arg_38_0 == UIItemList.EventUpdate then
			local var_38_0 = arg_38_2:Find("Desc")
			local var_38_1 = arg_38_2:Find("AddExp")
			local var_38_2 = arg_38_2:Find("Text")

			arg_38_1 = arg_38_1 + 1

			local var_38_3 = var_37_0[arg_38_1]
			local var_38_4 = var_37_0[arg_38_1][1]
			local var_38_5 = self:getTaskInfoBySkillAndTaskID(arg_37_1, var_37_0[arg_38_1][1])
			local var_38_6

			if var_38_5 then
				var_38_6 = var_38_5.finishCount or 0
			end

			setText(var_38_1, "+" .. var_38_3[3])

			if var_38_3[2] == 0 then
				setText(var_38_2, var_38_6 .. "/∞")
			else
				setText(var_38_2, var_38_6 .. "/" .. var_38_3[2])
			end

			setText(var_38_0, pg.task_meta_data_template[var_38_4].desc)
		end
	end)
	self.taskUIItemList:align(#var_37_0)
end

function MetaCharacterTacticsLayer:updateTaskPanel(arg_39_1)
	local var_39_0 = self.curShipVO

	if self.curShipVO:isSkillLevelMax(arg_39_1) == true then
		setActive(self.studySkillTip, false)
		setActive(self.startSkillTip, false)
		setActive(self.maxSkillTip, true)
		setActive(self.skillInfoPanel, true)
		setActive(self.taskTplContainer, false)
		setActive(self.taskScrollBar, false)
		self:updateSkillInfoPanel(arg_39_1)
	elseif arg_39_1 ~= self.curSkillID then
		setActive(self.studySkillTip, false)
		setActive(self.startSkillTip, true)
		setActive(self.maxSkillTip, false)
		setActive(self.skillInfoPanel, true)
		setActive(self.taskTplContainer, true)
		setActive(self.taskScrollBar, true)
		self:updateSkillInfoPanel(arg_39_1)
		self:updateTaskListPanel(arg_39_1)
		onButton(self, self.studySkillBtn, function()
			if self.switchCountLeft == 0 then
				pg.TipsMgr.GetInstance():ShowTips(i18n("meta_switch_skill_disable"))
			else
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					content = i18n("meta_switch_skill_box_title", getSkillName(arg_39_1)),
					onYes = function()
						pg.m02:sendNotification(GAME.TACTICS_META_SWITCH_SKILL, {
							shipID = var_39_0.id,
							skillID = arg_39_1
						})
					end
				})
			end
		end, SFX_PANEL)
	else
		setActive(self.studySkillTip, false)
		setActive(self.startSkillTip, false)
		setActive(self.maxSkillTip, false)
		setActive(self.skillInfoPanel, true)
		setActive(self.taskTplContainer, true)
		setActive(self.taskScrollBar, true)
		self:updateSkillInfoPanel(arg_39_1)
		self:updateTaskListPanel(arg_39_1)
	end
end

function MetaCharacterTacticsLayer:updateMain()
	local var_42_0 = self:getSkillIDListForShow(self.curShipVO.configId)
	local var_42_3, var_42_4 = self:isAllSkillLock()

	setActive(self.taskScrollTF, not var_42_3)

	if var_42_3 then
		setActive(self.expPanel, false)
		setActive(self.skillInfoPanel, false)
		setActive(self.taskTplContainer, false)
		setActive(self.taskScrollBar, false)
		setActive(self.studySkillTip, true)
		setActive(self.startSkillTip, false)
		setActive(self.maxSkillTip, false)
	elseif self.curUnlockSkillID then
		triggerButton(self.skillBtnList[self.curUnlockSkillID])
	elseif self.curSkillID > 0 then
		triggerButton(self.skillBtnList[self.curSkillID])
	else
		triggerButton(self.skillBtnList[var_42_4])
	end
end

function MetaCharacterTacticsLayer:tryLearnSkillAfterFirstUnlock()
	self:switchTacticsSkillData(self.curUnlockSkillID, 1)
	self:updateExpPanel()
	self:updateTaskPanel(self.curUnlockSkillID)
	self:updateSkillTFLearning()
	self:TryPlayGuide()
end

function MetaCharacterTacticsLayer:moveShipImg(arg_44_1)
	local var_44_0 = MetaCharacterConst.UIConfig[self.curMetaCharacterVO.id]

	self:managedTween(LeanTween.moveX, nil, rtf(self.shipImg), (arg_44_1 or nil) and (var_44_0[7] or -2000), 0.2):setFrom(arg_44_1 and -2000 or var_44_0[7])
end

function MetaCharacterTacticsLayer:moveRightPanel()
	self:managedTween(LeanTween.moveX, nil, rtf(self.skillPanel), 500, 0.2):setFrom(2000)
	self:managedTween(LeanTween.moveX, nil, rtf(self.taskPanel), 500, 0.2):setFrom(2000)
end

function MetaCharacterTacticsLayer:openUnlockSkillPanel(arg_46_1)
	self.curUnlockSkillID = arg_46_1

	setText(self.skillUnlockPanelTipText, i18n("meta_unlock_skill_tip", ShipGroup.getDefaultShipNameByGroupID(self.curMetaCharacterVO.id), (getSkillName(arg_46_1))))

	local var_46_1 = self:getMetaSkillTacticsConfigBySkillID(arg_46_1, 1)
	local var_46_3 = {
		var_46_1.skill_unlock[1]
	}

	self.materialUIItemList:make(function(arg_47_0, arg_47_1, arg_47_2)
		if arg_47_0 == UIItemList.EventUpdate then
			arg_47_1 = arg_47_1 + 1

			local var_47_0 = var_46_3[arg_47_1]
			local var_47_1 = arg_47_2:Find("Count/Text")

			updateDrop(arg_47_2:Find("Item"), {
				type = DROP_TYPE_ITEM,
				id = var_46_3[arg_47_1][2],
				count = var_46_3[arg_47_1][3]
			})
			setActive(arg_47_2:Find("SelectedTag"), false)

			local var_47_2 = var_47_0[2]
			local var_47_3 = var_47_0[3]
			local var_47_4 = getProxy(BagProxy):getItemCountById(var_47_0[2])

			setText(var_47_1, (var_47_4 < var_47_0[3] and setColorStr(var_47_4, COLOR_RED) or setColorStr(var_47_4, COLOR_GREEN)) .. "/" .. var_47_0[3])

			self.curUnlockMaterialID = var_47_2
			self.curUnlockMaterialNeedCount = var_47_3
		end
	end)
	self.materialUIItemList:align(#var_46_3)
	setActive(self.skillUnlockPanel, true)
	pg.UIMgr.GetInstance():BlurPanel(self.skillUnlockPanel)
end

function MetaCharacterTacticsLayer:closeUnlockSkillPanel()
	self.curUnlockSkillID = nil
	self.curUnlockMaterialID = nil
	self.curUnlockMaterialNeedCount = nil

	setActive(self.skillUnlockPanel, false)
	pg.UIMgr.GetInstance():UnOverlayPanel(self.skillUnlockPanel, self._tf)
end

function MetaCharacterTacticsLayer:enablePartialBlur()
	if self._tf then
		local var_49_0 = {}

		table.insert(var_49_0, self.taskPanel)
		table.insert(var_49_0, self.skillPanel)
		self:OverlayPanel(self._tf, {
			groupDelta = -1,
			pbList = var_49_0
		})
	end
end

function MetaCharacterTacticsLayer:disablePartialBlur()
	if self._tf then
		self:UnOverlayPanel(self._tf)
	end
end

function MetaCharacterTacticsLayer:getMetaSkillTacticsConfigBySkillID(arg_51_1, arg_51_2)
	return MetaCharacterConst.getMetaSkillTacticsConfig(arg_51_1, arg_51_2)
end

function MetaCharacterTacticsLayer:getTaskInfoBySkillAndTaskID(arg_52_1, arg_52_2)
	for iter_52_0, iter_52_1 in ipairs(self.taskInfoTable[arg_52_1] or {}) do
		if iter_52_1.taskID == arg_52_2 then
			return iter_52_1
		end
	end
end

function MetaCharacterTacticsLayer:isAllSkillLock()
	local var_53_0 = true
	local var_53_1 = 0

	for iter_53_0, iter_53_1 in ipairs((self:getSkillIDListForShow(self.curShipVO.configId))) do
		if self.curShipVO:getMetaSkillLevelBySkillID(iter_53_1) > 0 then
			var_53_0 = false
			var_53_1 = iter_53_1

			break
		end
	end

	return var_53_0, var_53_1
end

function MetaCharacterTacticsLayer:isAllSkillMaxLevel()
	for iter_54_0, iter_54_1 in ipairs((self:getSkillIDListForShow(self.curShipVO.configId))) do
		if not self.curShipVO:isSkillLevelMax(iter_54_1) then
			return false
		end
	end
end

function MetaCharacterTacticsLayer:updateTacticsRedTag()
	local var_55_0 = self.curShipVO:getMetaCharacter()

	for iter_55_0, iter_55_1 in ipairs((self:getSkillIDListForShow(self.curShipVO.configId))) do
		local var_55_2 = self.curShipVO:getMetaSkillLevelBySkillID(iter_55_1)

		if var_55_2 > 0 and not self.curShipVO:isSkillLevelMax(iter_55_1) then
			if self.skillExpTable then
				if self:getMetaSkillTacticsConfigBySkillID(iter_55_1, var_55_2).need_exp <= (self.skillExpTable[iter_55_1] or 0) then
					break
				end
			end
		end
	end
end

function MetaCharacterTacticsLayer:sortTaskConfig(arg_56_1, arg_56_2)
	local var_56_0 = Clone(arg_56_2)

	table.sort(var_56_0, function(arg_57_0, arg_57_1)
		local var_57_0 = arg_57_1[1]
		local var_57_1 = arg_57_0[2]
		local var_57_2 = arg_57_1[2]
		local var_57_3 = self:getTaskInfoBySkillAndTaskID(arg_56_1, arg_57_0[1])
		local var_57_4 = self:getTaskInfoBySkillAndTaskID(arg_56_1, arg_57_1[1])
		local var_57_5

		if var_57_3 then
			var_57_5 = var_57_3.finishCount or 0

			local var_57_6

			if var_57_4 then
				var_57_6 = var_57_4.finishCount or 0
			end
		end

		local var_57_7 = var_57_1 > 0 and var_57_5 <= var_57_1
		local var_57_8 = var_57_2 > 0 and var_57_6 <= var_57_2

		if var_57_1 == 0 and var_57_2 == 0 then
			return arg_57_0[1] < var_57_0
		elseif var_57_1 == 0 then
			return true
		elseif var_57_2 == 0 then
			return false
		elseif var_57_7 == true and var_57_8 == true then
			return arg_57_0[1] < var_57_0
		elseif var_57_7 == true then
			return false
		elseif var_57_8 == true then
			return true
		else
			return arg_57_0[1] < var_57_0
		end
	end)

	return var_56_0
end

function MetaCharacterTacticsLayer:getSkillIDListForShow(arg_58_1)
	return MetaCharacterConst.getTacticsSkillIDListByShipConfigID(arg_58_1)
end

return MetaCharacterTacticsLayer
