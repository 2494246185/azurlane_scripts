local CommanderCatScene = class("CommanderCatScene", import("view.base.BaseUI"))

CommanderCatScene.MODE_VIEW = 1
CommanderCatScene.MODE_SELECT = 2
CommanderCatScene.SELECT_MODE_SINGLE = 1
CommanderCatScene.SELECT_MODE_MULTI = 2
CommanderCatScene.PAGE_PLAY = 1
CommanderCatScene.PAGE_TALENT = 2
CommanderCatScene.PAGE_DOCK = 3
CommanderCatScene.FLEET_TYPE_COMMON = 1
CommanderCatScene.FLEET_TYPE_ACTBOSS = 2
CommanderCatScene.FLEET_TYPE_HARD_CHAPTER = 3
CommanderCatScene.FLEET_TYPE_CHALLENGE = 4
CommanderCatScene.FLEET_TYPE_GUILDBOSS = 5
CommanderCatScene.FLEET_TYPE_WORLD = 6
CommanderCatScene.FLEET_TYPE_BOSSRUSH = 7
CommanderCatScene.FLEET_TYPE_LIMIT_CHALLENGE = 8
CommanderCatScene.FLEET_TYPE_BOSSSINGLE = 9
CommanderCatScene.FLEET_TYPE_BOSSSINGLE_VARIABLE = 10
CommanderCatScene.EVENT_SELECTED = "CommanderCatScene:EVENT_SELECTED"
CommanderCatScene.EVENT_BACK = "CommanderCatScene:EVENT_BACK"
CommanderCatScene.EVENT_FOLD = "CommanderCatScene:EVENT_FOLD"
CommanderCatScene.EVENT_PREV_ONE = "CommanderCatScene:EVENT_PREV_ONE"
CommanderCatScene.EVENT_NEXT_ONE = "CommanderCatScene:EVENT_NEXT_ONE"
CommanderCatScene.EVENT_CLOSE_DESC = "CommanderCatScene:EVENT_CLOSE_DESC"
CommanderCatScene.EVENT_OPEN_DESC = "CommanderCatScene:EVENT_OPEN_DESC"
CommanderCatScene.EVENT_UPGRADE = "CommanderCatScene:EVENT_UPGRADE"
CommanderCatScene.EVENT_QUICKLY_TOOL = "CommanderCatScene:EVENT_QUICKLY_TOOL"
CommanderCatScene.EVENT_SWITCH_PAGE = "CommanderCatScene:EVENT_SWITCH_PAGE"
CommanderCatScene.EVENT_PREVIEW_PLAY = "CommanderCatScene:EVENT_PREVIEW_PLAY"
CommanderCatScene.EVENT_PREVIEW = "CommanderCatScene:EVENT_PREVIEW"
CommanderCatScene.EVENT_PREVIEW_REVERSE = "CommanderCatScene:EVENT_PREVIEW_REVERSE"
CommanderCatScene.EVENT_PREVIEW_ADDITION = "CommanderCatScene:EVENT_PREVIEW_ADDITION"
CommanderCatScene.MSG_RESERVE_BOX = "CommanderCatScene:MSG_RESERVE_BOX"
CommanderCatScene.MSG_QUICKLY_FINISH_TOOL_ERROR = "CommanderCatScene:MSG_QUICKLY_FINISH_TOOL_ERROR"
CommanderCatScene.MSG_UPGRADE = "CommanderCatScene:MSG_UPGRADE"
CommanderCatScene.MSG_LOCK = "CommanderCatScene:MSG_LOCK"
CommanderCatScene.MSG_RENAME = "CommanderCatScene:MSG_RENAME"
CommanderCatScene.MSG_FETCH_TALENT_LIST = "CommanderCatScene:MSG_FETCH_TALENT_LIST"
CommanderCatScene.MSG_LEARN_TALENT = "CommanderCatScene:MSG_LEARN_TALENT"
CommanderCatScene.MSG_UPDATE = "CommanderCatScene:MSG_UPDATE"
CommanderCatScene.MSG_HOME_TIP = "CommanderCatScene:MSG_HOME_TIP"
CommanderCatScene.MSG_BUILD = "CommanderCatScene:MSG_BUILD"
CommanderCatScene.MSG_OPEN_BOX = "CommanderCatScene:MSG_OPEN_BOX"
CommanderCatScene.MSG_BATCH_BUILD = "CommanderCatScene:MSG_BATCH_BUILD"
CommanderCatScene.MSG_RES_UPDATE = "CommanderCatScene:MSG_RES_UPDATE"

function CommanderCatScene:getUIName()
	return "CommanderCatUI"
end

function CommanderCatScene:init()
	self.bgTF = self._tf:Find("background")
	self.bgImg = self.bgTF:GetComponent(typeof(Image))
	self.paintingTF = self._tf:Find("painting/frame")
	self.blurPanel = self._tf:Find("blur_panel")
	self.backBtn = findTF(self.blurPanel, "top/back_btn")
	self.topPanel = findTF(self.blurPanel, "top")
	self.pageContainer = findTF(self.blurPanel, "pages")
	self.leftPanel = findTF(self.blurPanel, "left_panel")
	self.eyeBtn = findTF(self.leftPanel, "eye")
	self.helpBtn = findTF(self.leftPanel, "help_btn")
	self.titles = {
		[CommanderCatScene.PAGE_PLAY] = findTF(self._tf, "blur_panel/top/title/play"),
		[CommanderCatScene.PAGE_TALENT] = findTF(self._tf, "blur_panel/top/title/talent"),
		[CommanderCatScene.PAGE_DOCK] = findTF(self._tf, "blur_panel/top/title/Text")
	}
	self.toggles = {
		[CommanderCatScene.PAGE_PLAY] = findTF(self.leftPanel, "toggles/play"),
		[CommanderCatScene.PAGE_TALENT] = findTF(self.leftPanel, "toggles/talent"),
		[CommanderCatScene.PAGE_DOCK] = findTF(self.leftPanel, "toggles/detail")
	}
	self.pages = {
		[CommanderCatScene.PAGE_PLAY] = CommanderCatPlayPage.New(self.pageContainer, self.event, self.contextData),
		[CommanderCatScene.PAGE_TALENT] = CommanderCatTalentPage.New(self.pageContainer, self.event, self.contextData),
		[CommanderCatScene.PAGE_DOCK] = CommanderCatDockPage.New(self.pageContainer, self.event, self.contextData)
	}
	self.detailPage = CommanderDetailPage.New(self.pageContainer, self.event, self.contextData)
	self.contextData.msgBox = CommanderMsgBoxPage.New(pg.UIMgr.GetInstance().OverlayMain, self.event)
	self.contextData.treePanel = CommanderTreePage.New(pg.UIMgr.GetInstance().OverlayMain, self.event)
	self.commanderPaintingUtil = CommanderPaintingUtil.New(self.paintingTF)

	local var_2_0 = {}

	var_2_0[1] = findTF(self.blurPanel, "top/res/1/Text"):GetComponent(typeof(Text))
	var_2_0[2] = findTF(self.blurPanel, "top/res/2/Text"):GetComponent(typeof(Text))
	var_2_0[3] = findTF(self.blurPanel, "top/res/3/Text"):GetComponent(typeof(Text))
	self.resources = var_2_0
	self.goldTxt = findTF(self.blurPanel, "top/res/gold/Text"):GetComponent(typeof(Text))
end

function CommanderCatScene:didEnter()
	onButton(self, self.backBtn, function()
		if self.pageType == CommanderCatScene.PAGE_PLAY or self.pageType == CommanderCatScene.PAGE_TALENT then
			triggerButton(self.toggles[CommanderCatScene.PAGE_DOCK])
		else
			self:emit(CommanderCatScene.ON_BACK)
		end
	end, SFX_CANCEL)
	onButton(self, self.helpBtn, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.help_commander_info.tip
		})
	end, SFX_PANEL)
	onButton(self, self.eyeBtn, function()
		self:Fold()
	end, SFX_PANEL)
	addSlip(SLIP_TYPE_HRZ, self.bgTF, function()
		self:emit(CommanderCatScene.EVENT_PREV_ONE, self.selectedCommander.id)
	end, function()
		self:emit(CommanderCatScene.EVENT_NEXT_ONE, self.selectedCommander.id)
	end)

	self.contextData.mode = self.contextData.mode or CommanderCatScene.MODE_VIEW

	self:RegisterEvent()
	self:UpdateStyle()
	self:UpdateResources()
	self:UpdateGold()
	self:UpdateToggles()
	triggerButton(self.toggles[CommanderCatScene.PAGE_DOCK])
	setActive(self.toggles[CommanderCatScene.PAGE_DOCK], false)
end

function CommanderCatScene:RegisterEvent()
	self:bind(CommanderCatScene.EVENT_SELECTED, function(arg_10_0, arg_10_1, arg_10_2)
		self:UpdateMainView(arg_10_1, arg_10_2)
	end)
	self:bind(CommanderCatScene.EVENT_BACK, function(arg_11_0)
		self:emit(CommanderCatScene.ON_BACK)
	end)
	self:bind(CommanderCatScene.MSG_RESERVE_BOX, function(arg_12_0, arg_12_1)
		self:UpdateResources()
		self:UpdateGold()
	end)
	self:bind(CommanderCatScene.MSG_RES_UPDATE, function(arg_13_0)
		self:UpdateGold()
	end)
	self:bind(CommanderCatScene.MSG_BUILD, function(arg_14_0)
		self:UpdateResources()
	end)
end

function CommanderCatScene:UpdateStyle()
	setActive(self.helpBtn, CommanderCatScene.MODE_VIEW == self.contextData.mode)

	if self.contextData.mode == CommanderCatScene.MODE_SELECT then
		if self.contextData.maxCount > 1 then
			setActive(self.topPanel, false)
			onButton(self, go(self.bgTF), function()
				self:emit(CommanderCatScene.ON_BACK)
			end, SOUND_BACK)
		end

		setActive(self.leftPanel, false)
	end
end

function CommanderCatScene:UpdateResources()
	for iter_17_0, iter_17_1 in pairs((getProxy(CommanderProxy):getPools())) do
		if self.resources[iter_17_1.id] then
			self.resources[iter_17_1.id].text = iter_17_1:getItemCount()
		end
	end
end

function CommanderCatScene:UpdateGold()
	self.goldTxt.text = getProxy(PlayerProxy):getRawData().gold
end

function CommanderCatScene:UpdateToggles()
	for iter_19_0, iter_19_1 in pairs(self.toggles) do
		onButton(self, iter_19_1, function()
			if self.pageType then
				setActive(self.toggles[self.pageType]:Find("Image"), false)
			end

			self:SwitchPage(iter_19_0)
			setActive(iter_19_1:Find("Image"), true)
		end, SFX_PANEL)
	end
end

function CommanderCatScene:SwitchPage(arg_21_1)
	if (arg_21_1 == CommanderCatScene.PAGE_PLAY or arg_21_1 == CommanderCatScene.PAGE_TALENT) and not self.selectedCommander then
		return
	end

	if arg_21_1 == CommanderCatScene.PAGE_PLAY and self.selectedCommander.inBattle then
		pg.TipsMgr.GetInstance():ShowTips(i18n("commander_is_in_battle"))

		return
	end

	if self.pageType then
		if self.pages[self.pageType]:GetLoaded() then
			self.pages[self.pageType]:Hide()
		end

		setActive(self.titles[self.pageType], false)
	end

	local var_21_0 = self.pages[arg_21_1]

	if arg_21_1 == CommanderCatScene.PAGE_DOCK then
		var_21_0:ExecuteAction("Show")
	else
		var_21_0:ExecuteAction("Show", self.selectedCommander)
	end

	setActive(self.titles[arg_21_1], true)
	self:CheckFirstHelp(arg_21_1)

	self.pageType = arg_21_1

	self:emit(CommanderCatScene.EVENT_SWITCH_PAGE, arg_21_1)
end

function CommanderCatScene:CheckFirstHelp(arg_22_1)
	if arg_22_1 == CommanderCatScene.PAGE_PLAY then
		checkFirstHelpShow("help_commander_play")
	elseif arg_22_1 == CommanderCatScene.PAGE_TALENT then
		checkFirstHelpShow("help_commander_ability")
	end
end

function CommanderCatScene:UpdateMainView(arg_23_1, arg_23_2)
	if not arg_23_2 and self.selectedCommander and arg_23_1.id == self.selectedCommander.id then
		return
	end

	local var_23_0 = arg_23_1:getPainting()

	if not self.paintingName or var_23_0 ~= self.paintingName then
		self.paintingName = var_23_0

		self:ReturnCommanderPainting()
		setCommanderPaintingPrefab(self.paintingTF, var_23_0, "info")

		local var_23_1 = self.paintingTF:Find("fitter"):GetChild(0)

		if var_23_1 then
			var_23_1:GetComponent(typeof(Image)).raycastTarget = false
		end
	end

	local var_23_2 = arg_23_1:getConfig("bg")

	if self.bgName ~= var_23_2 then
		LoadSpriteAsync("bg/commander_bg_" .. var_23_2, function(arg_24_0)
			if self.exited then
				return
			end

			self.bgImg.sprite = arg_24_0
		end)

		self.bgName = var_23_2
	end

	self.detailPage:ExecuteAction("Update", arg_23_1, self.contextData.mode == CommanderCatScene.MODE_SELECT)

	local var_23_3 = arg_23_1:getTalentPoint()

	if var_23_3 > 0 then
		setText(self.toggles[CommanderCatScene.PAGE_TALENT]:Find("tip/Text"), var_23_3)
	end

	setActive(self.toggles[CommanderCatScene.PAGE_TALENT]:Find("tip"), var_23_3 > 0)

	self.selectedCommander = arg_23_1
end

function CommanderCatScene:ReturnCommanderPainting()
	if self.selectedCommander then
		retCommanderPaintingPrefab(self.paintingTF, self.selectedCommander:getPainting())

		self.selectedCommander = nil
	end
end

function CommanderCatScene:Fold()
	if self.doAnimation then
		return
	end

	self.doAnimation = true

	self.commanderPaintingUtil:Fold()
	LeanTween.moveX(rtf(self.leftPanel), -300, 0.5)
	LeanTween.moveY(rtf(self.topPanel), 300, 0.5):setOnComplete(System.Action(function()
		self.doAnimation = false
	end))
	onButton(self, self.bgTF, function()
		self:UnFold()
	end, SFX_PANEL)
	self:emit(CommanderCatScene.EVENT_FOLD, true)
end

function CommanderCatScene:UnFold()
	if self.doAnimation then
		return
	end

	self.doAnimation = true

	removeOnButton(self.bgTF)
	self.commanderPaintingUtil:UnFold()
	LeanTween.moveX(rtf(self.leftPanel), 0, 0.5)
	LeanTween.moveY(rtf(self.topPanel), 0, 0.5):setOnComplete(System.Action(function()
		self.doAnimation = false
	end))
	self:emit(CommanderCatScene.EVENT_FOLD, false)
end

function CommanderCatScene:onBackPressed()
	if self.pageType and (self.pageType == CommanderCatScene.PAGE_PLAY or self.pageType == CommanderCatScene.PAGE_TALENT) then
		triggerButton(self.toggles[CommanderCatScene.PAGE_DOCK])

		return
	end

	if self.contextData.msgBox and self.contextData.msgBox:GetLoaded() and self.contextData.msgBox:isShowing() then
		self.contextData.msgBox:Hide()

		return
	end

	if self.contextData.treePanel and self.contextData.treePanel:GetLoaded() and self.contextData.treePanel:isShowing() then
		self.contextData.treePanel:Hide()

		return
	end

	if self.pageType and self.pages[self.pageType] then
		if self.pages[self.pageType].CanBack and not self.pages[self.pageType]:CanBack() then
			return
		end
	end

	if self.detailPage and self.detailPage:GetLoaded() and self.detailPage.CanBack and not self.detailPage:CanBack() then
		return false
	end

	CommanderCatScene.super.onBackPressed(self)
end

function CommanderCatScene:getResource()
	local var_32_0 = CommanderCatScene.super.getResource(self)

	for iter_32_0 = 1, 4 do
		table.insert(var_32_0, "char/NekoBox" .. iter_32_0)
		table.insert(var_32_0, "char/SRNekoBox" .. iter_32_0)
		table.insert(var_32_0, "char/SSRNekoBox" .. iter_32_0)
	end

	for iter_32_1, iter_32_2 in pairs(pg.commander_home_style.all) do
		if pg.commander_home_style[iter_32_2].name and pg.commander_home_style[iter_32_2].name ~= "" and not table.contains(var_32_0, "catterystyle/" .. pg.commander_home_style[iter_32_2].name) then
			table.insert(var_32_0, "catterystyle/" .. pg.commander_home_style[iter_32_2].name)
			table.insert(var_32_0, "catterystyle/" .. pg.commander_home_style[iter_32_2].name .. "_d")
		end
	end

	for iter_32_3, iter_32_4 in pairs(pg.commander_skill_template.all) do
		if pg.commander_skill_template[iter_32_4].icon and pg.commander_skill_template[iter_32_4].icon ~= "" and not table.contains(var_32_0, "commanderskillicon/" .. pg.commander_skill_template[iter_32_4].icon) then
			table.insert(var_32_0, "commanderskillicon/" .. pg.commander_skill_template[iter_32_4].icon)
		end
	end

	for iter_32_5, iter_32_6 in pairs(pg.commander_ability_template.all) do
		if pg.commander_ability_template[iter_32_6].icon and pg.commander_ability_template[iter_32_6].icon ~= "" and not table.contains(var_32_0, "commandertalenticon/" .. pg.commander_ability_template[iter_32_6].icon) then
			table.insert(var_32_0, "commandertalenticon/" .. pg.commander_ability_template[iter_32_6].icon)
		end
	end

	for iter_32_7, iter_32_8 in pairs(pg.commander_data_template.all) do
		if pg.commander_data_template[iter_32_8].painting and pg.commander_data_template[iter_32_8].painting ~= "" and not table.contains(var_32_0, "commandericon/" .. pg.commander_data_template[iter_32_8].painting) then
			table.insert(var_32_0, "commandericon/" .. pg.commander_data_template[iter_32_8].painting)
		end

		if pg.commander_data_template[iter_32_8].painting and pg.commander_data_template[iter_32_8].painting ~= "" and not table.contains(var_32_0, "commanderpainting/" .. pg.commander_data_template[iter_32_8].painting) then
			table.insert(var_32_0, "commanderpainting/" .. pg.commander_data_template[iter_32_8].painting)
		end
	end

	table.insert(var_32_0, "props/20010")
	table.insert(var_32_0, "props/20011")
	table.insert(var_32_0, "props/20012")
	table.insert(var_32_0, "props/20013")
	table.insert(var_32_0, "bg/commander_bg_1")
	table.insert(var_32_0, "bg/commander_bg_2")
	table.insert(var_32_0, "commanderrarity/n")
	table.insert(var_32_0, "commanderrarity/r")
	table.insert(var_32_0, "commanderrarity/sr")
	table.insert(var_32_0, "commanderrarity/ssr")
	table.insert(var_32_0, "char/ai_manjuuu")
	table.insert(var_32_0, "painting/mingshi")
	table.insert(var_32_0, "ui/CommanderCatPlayui")
	table.insert(var_32_0, "ui/CommanderCatTalentui")
	table.insert(var_32_0, "ui/CommanderCatDockui")
	table.insert(var_32_0, "ui/CommanderDetailUI")
	table.insert(var_32_0, "ui/CommanderMsgBoxUI")
	table.insert(var_32_0, "ui/CommanderTreeUI")
	table.insert(var_32_0, "ui/CommanderReserveUI")
	table.insert(var_32_0, "ui/CommanderBoxesUI")
	table.insert(var_32_0, "ui/CommanderIndexUI")
	table.insert(var_32_0, "ui/CommandeRenameUI")
	table.insert(var_32_0, "ui/CommanderQuicklyFinishBoxUI")
	table.insert(var_32_0, "ui/CommanderBuildPoolUI")
	table.insert(var_32_0, "ui/GetCommanderResultUI")
	table.insert(var_32_0, "attricon")
	table.insert(var_32_0, "ui/CommanderBuildResultUI_atlas")

	return var_32_0
end

function CommanderCatScene:willExit()
	self:ReturnCommanderPainting()

	for iter_33_0, iter_33_1 in pairs(self.pages) do
		iter_33_1:Destroy()
	end

	self.pages = {}

	if self.detailPage then
		self.detailPage:Destroy()

		self.detailPage = nil
	end

	if self.contextData.msgBox then
		self.contextData.msgBox:Destroy()

		self.contextData.msgBox = nil
	end

	if self.contextData.treePanel then
		self.contextData.treePanel:Destroy()

		self.contextData.treePanel = nil
	end
end

return CommanderCatScene
