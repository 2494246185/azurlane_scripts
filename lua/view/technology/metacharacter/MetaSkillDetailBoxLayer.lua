local MetaSkillDetailBoxLayer = class("MetaSkillDetailBoxLayer", import("...base.BaseUI"))

function MetaSkillDetailBoxLayer:getUIName()
	return "MetaSkillDetailBoxUI"
end

function MetaSkillDetailBoxLayer:getResource()
	local var_2_0 = {}
	local var_2_1 = MetaCharacterConst.getTacticsSkillIDListByShipConfigID(getProxy(BayProxy):getShipById(self.contextData.metaShipID).configId)

	for iter_2_0 = 1, #var_2_1 do
		table.insert(var_2_0, "skillicon/" .. getSkillConfig(var_2_1[iter_2_0]).icon)
	end

	table.insertto(var_2_0, MetaSkillDetailBoxLayer.super.getResource(self))

	return var_2_0
end

function MetaSkillDetailBoxLayer:init()
	self:initUITextTips()
	self:initData()
	self:findUI()
	self:addListener()
end

function MetaSkillDetailBoxLayer:didEnter()
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
	self:updateShipDetail()
	self:updateSkillList()
end

function MetaSkillDetailBoxLayer:willExit()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)
end

function MetaSkillDetailBoxLayer:initUITextTips()
	setText(self._tf:Find("Window/top/bg/infomation/title"), i18n("battle_end_subtitle2"))
	setText(self._tf:Find("Window/MetaSkillDetailBox/ExpDetail/ExpTipText"), i18n("meta_skill_dailyexp"))
	setText(self._tf:Find("Window/MetaSkillDetailBox/TipText"), i18n("meta_skill_learn"))
end

function MetaSkillDetailBoxLayer:initData()
	self.metaProxy = getProxy(MetaCharacterProxy)
	self.metaShipID = self.contextData.metaShipID
end

function MetaSkillDetailBoxLayer:findUI()
	self.bg = self._tf:Find("BG")
	self.window = self._tf:Find("Window")
	self.closeBtn = self.window:Find("top/btnBack")
	self.panel = self.window:Find("MetaSkillDetailBox")
	self.skillTpl = self.panel:Find("SkillTpl")
	self.expDetailTF = self.panel:Find("ExpDetail")
	self.shipIcon = self.expDetailTF:Find("IconTpl/Icon")
	self.shipNameText = self.expDetailTF:Find("NameMask/Name")
	self.expProgressText = self.expDetailTF:Find("ExpProgressText")
	self.skillContainer = self.panel:Find("ScrollView/Content")
	self.skillUIItemList = UIItemList.New(self.skillContainer, self.skillTpl)
end

function MetaSkillDetailBoxLayer:addListener()
	onButton(self, self.bg, function()
		self:closeView()
	end, SFX_PANEL)
	onButton(self, self.closeBtn, function()
		self:closeView()
	end, SFX_PANEL)
end

function MetaSkillDetailBoxLayer:updateSkillTF(arg_12_1, arg_12_2)
	local var_12_0 = arg_12_1:Find("frame")
	local var_12_1 = arg_12_1:Find("check_mark")
	local var_12_2 = var_12_0:Find("skillInfo")
	local var_12_3 = var_12_0:Find("mask")
	local var_12_4 = var_12_0:Find("Slider")
	local var_12_5 = var_12_2:Find("ExpProgressText")
	local var_12_6 = var_12_0:Find("Tag/learing")
	local var_12_7 = var_12_0:Find("Tag/unlockable")
	local var_12_8 = getProxy(BayProxy)
	local var_12_9 = var_12_8:getShipById(self.metaShipID)
	local var_12_10 = var_12_9:getMetaSkillLevelBySkillID(arg_12_2)

	setImageSprite(var_12_2:Find("icon"), LoadSprite("skillicon/" .. var_12_8.icon))
	setText(var_12_2:Find("name_contain/name"), shortenString(getSkillName(getSkillConfig(arg_12_2).id), 8))
	setText(var_12_2:Find("name_contain/level_contain/Text"), var_12_10)

	local var_12_11 = self.metaProxy:getMetaTacticsInfoByShipID(self.metaShipID)
	local var_12_12 = arg_12_2 == var_12_11.curSkillID
	local var_12_13 = var_12_10 > 0
	local var_12_14 = var_12_9:isSkillLevelMax(arg_12_2)
	local var_12_15 = var_12_11:getSkillExp(arg_12_2)

	if var_12_10 < pg.skill_data_template[arg_12_2].max_level then
		if var_12_13 then
			local var_12_16 = MetaCharacterConst.getMetaSkillTacticsConfig(arg_12_2, var_12_10).need_exp

			setText(var_12_5, var_12_15 .. "/" .. var_12_16)
			setSlider(var_12_4, 0, var_12_16, var_12_15)
			setActive(var_12_5, true)
			setActive(var_12_4, true)
		else
			setActive(var_12_5, false)
			setActive(var_12_4, false)
		end
	else
		setText(var_12_5, var_12_15 .. "/Max")
		setSlider(var_12_4, 0, 1, 1)
		setActive(var_12_5, true)
		setActive(var_12_4, true)
	end

	setActive(var_12_1, var_12_12 and not var_12_14)
	setActive(var_12_6, var_12_12 and not var_12_14)
	setActive(var_12_7, not var_12_13)
	setActive(var_12_3, not var_12_13)
	onToggle(self, arg_12_1, function(arg_13_0)
		if arg_13_0 then
			if not var_12_13 then
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					hideYes = true,
					hideNo = true,
					type = MSGBOX_TYPE_META_SKILL_UNLOCK,
					metaShipVO = var_12_9,
					skillID = arg_12_2
				})
			elseif not var_12_12 and not var_12_14 then
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					content = i18n("meta_switch_skill_box_title", getSkillName(arg_12_2)),
					onYes = function()
						pg.m02:sendNotification(GAME.TACTICS_META_SWITCH_SKILL, {
							shipID = self.metaShipID,
							skillID = arg_12_2
						})
					end
				})
			elseif var_12_14 then
				pg.TipsMgr.GetInstance():ShowTips(i18n("meta_skill_maxtip2"))
			end
		end
	end, SFX_PANEL)
end

function MetaSkillDetailBoxLayer:updateSkillList()
	local var_15_0 = MetaCharacterConst.getTacticsSkillIDListByShipConfigID(getProxy(BayProxy):getShipById(self.metaShipID).configId)

	self.skillUIItemList:make(function(arg_16_0, arg_16_1, arg_16_2)
		if arg_16_0 == UIItemList.EventUpdate then
			arg_16_1 = arg_16_1 + 1

			self:updateSkillTF(arg_16_2, var_15_0[arg_16_1])
		end
	end)
	self.skillUIItemList:align(#var_15_0)
end

function MetaSkillDetailBoxLayer:updateShipDetail()
	local var_17_0 = getProxy(BayProxy):getShipById(self.metaShipID)
	local var_17_1 = var_17_0:getPainting()

	setImageSprite(self.shipIcon, LoadSprite("SquareIcon/" .. var_17_1, var_17_1))
	setScrollText(self.shipNameText, var_17_0:getName())
	setText(self.expProgressText, setColorStr(self.metaProxy:getMetaTacticsInfoByShipID(self.metaShipID).curDayExp, "#FFF152FF") .. "/" .. pg.gameset.meta_skill_exp_max.key_value)
end

return MetaSkillDetailBoxLayer
