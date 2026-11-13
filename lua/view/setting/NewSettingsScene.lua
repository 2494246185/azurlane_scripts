local NewSettingsScene = class("NewSettingsScene", import("..base.BaseUI"))

NewSettingsScene.PAGE_OTHER = 1
NewSettingsScene.PAGE_OPTION = 2
NewSettingsScene.PAGE_BATTLE = 3
NewSettingsScene.PAGE_RES = 4
NewSettingsScene.PAGE_3D = 5

function NewSettingsScene:getUIName()
	return "NewSettingsUI"
end

function NewSettingsScene:OnShowDescWindow(arg_2_1)
	self.descWindow:ExecuteAction("Show", arg_2_1.desc, arg_2_1.alignment)
end

function NewSettingsScene:OnClearExchangeCode()
	if self.pages and self.pages[1] and self.pages[1]:GetLoaded() then
		self.pages[1]:OnClearExchangeCode()
	end
end

function NewSettingsScene:OnShowTranscode(arg_4_1)
	if self.pages and self.pages[1] and self.pages[1]:GetLoaded() then
		self.pages[1]:OnShowTranscode(arg_4_1)
	end
end

function NewSettingsScene:OnCheckAllAccountState()
	if self.pages and self.pages[1] and self.pages[1]:GetLoaded() then
		self.pages[1]:OnCheckAllAccountState()
	end
end

function NewSettingsScene:OnSecondPwdStateChange()
	if self.pages and self.pages[1] and self.pages[1]:GetLoaded() then
		self.pages[1]:OnSecondPwdStateChange()
	end
end

function NewSettingsScene:OnRandomFlagShipModeUpdate()
	self:emit(SettingsRandomFlagShipAndSkinPanel.EVT_UPDTAE)
end

function NewSettingsScene:OnSelectGraphicSettingLevel()
	self:emit(SettingsOtherGraphicsPanle.EVT_UPDTAE)
end

function NewSettingsScene:OnSelectCustomGraphicSetting()
	self:emit(SettingsGraphicsPanle.EVT_UPDTAE)
end

function NewSettingsScene:OnApplicationPause()
	self:emit(SettingsNotificationPanel.UPDATE_ALARM_PANEL)
end

function NewSettingsScene:GetPage(arg_11_1)
	for iter_11_0, iter_11_1 in ipairs(self.pages) do
		if isa(iter_11_1, arg_11_1) then
			return iter_11_1
		end
	end
end

function NewSettingsScene:init()
	self.backBtn = self._tf:Find("blur_panel/adapt/top/back_btn")

	local var_12_0 = self._tf:Find("pages")

	self.pages = {
		SettingsOtherPage.New(var_12_0, self.event, self.contextData),
		SettingsOptionPage.New(var_12_0, self.event, self.contextData),
		SettingsBattlePage.New(var_12_0, self.event, self.contextData),
		SettingsResPage.New(var_12_0, self.event, self.contextData)
	}
	self.toggles = {
		self._tf:Find("blur_panel/adapt/left_length/other"),
		self._tf:Find("blur_panel/adapt/left_length/options"),
		self._tf:Find("blur_panel/adapt/left_length/battle_ui"),
		self._tf:Find("blur_panel/adapt/left_length/resources")
	}
	self.otherTip = self.toggles[1]:Find("tip")
	self.logoutBtn = self._tf:Find("blur_panel/adapt/left_length/logout")
	self.helpBtn = self._tf:Find("blur_panel/adapt/left_length/help_us")
	self.descWindow = SettingsMsgBosPage.New(self._tf, self.event)

	setActive(self._tf:Find("blur_panel/adapt/left_length/threeD"), false)
end

function NewSettingsScene:didEnter()
	onButton(self, self.backBtn, function()
		self:closeView()
	end, SFX_CANCEL)
	onButton(self, self.logoutBtn, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			content = i18n("main_settingsScene_quest_exist"),
			onYes = function()
				self:emit(NewSettingsMediator.ON_LOGOUT)
			end
		})
	end, SFX_PANEL)

	if PLATFORM_CODE == PLATFORM_KR then
		setActive(self.helpBtn, true)
		onButton(self, self.helpBtn, function()
			pg.SdkMgr.GetInstance():BugReport()
		end, SFX_CANCEL)
		self.helpBtn:SetAsFirstSibling()
	end

	for iter_13_0, iter_13_1 in ipairs(self.toggles) do
		onToggle(self, iter_13_1, function(arg_18_0)
			if arg_18_0 then
				self:SwitchPage(iter_13_0)
			end
		end, SFX_PANEL)
	end

	setActive(self.otherTip, PlayerPrefs.GetInt("firstIntoOtherPanel", 0) == 0)
	self:EnterDefaultPage()
end

function NewSettingsScene:EnterDefaultPage()
	triggerToggle(self.toggles[self.contextData.page or (self.contextData.toggle and type(self.contextData.toggle) == "string" or nil) and ((self.contextData.toggle == "sound" or self.contextData.toggle == "res") and NewSettingsScene.PAGE_RES or table.indexof({
		"other",
		"options",
		"interface",
		"res"
	}, self.contextData.toggle)) or NewSettingsScene.PAGE_RES], true)
end

function NewSettingsScene:SwitchPage(arg_20_1)
	if self.page and self.page ~= self.pages[arg_20_1] and self.page:GetLoaded() then
		self.page:Hide()
	end

	self.pages[arg_20_1]:ExecuteAction("Show")

	self.page = self.pages[arg_20_1]

	if isa(self.pages[arg_20_1], Settings3DPage) then
		self.hasShow3d = true
	end

	if isa(self.pages[arg_20_1], SettingsOtherPage) and isActive(self.otherTip) then
		setActive(self.otherTip, false)
	end
end

function NewSettingsScene:OpenYostarAlertView()
	self.yostarAlertView = YostarAlertView.New(self._tf, self.event, {
		isLinkMode = true,
		isDestroyOnClose = true
	})

	self.yostarAlertView:Load()
	self.yostarAlertView:ActionInvoke("Show")
end

function NewSettingsScene:CloseYostarAlertView()
	if self.yostarAlertView and self.yostarAlertView:CheckState(BaseSubView.STATES.INITED) then
		self.yostarAlertView:Destroy()
	end
end

function NewSettingsScene:onBackPressed()
	pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_CANCEL)

	local var_23_0 = GameObject.Find("OverlayCamera/Overlay/UIMain/DialogPanel")

	if isActive(var_23_0) then
		triggerButton(var_23_0.transform:Find("dialog/title/back"))

		return
	end

	self:emit(NewSettingsScene.ON_BACK)
end

function NewSettingsScene:willExit()
	if self.hasShow3d then
		GraphicSettingConst.SettingQuality()
	end

	for iter_24_0, iter_24_1 in pairs(self.pages) do
		iter_24_1:Destroy()
	end

	if self.descWindow then
		self.descWindow:Destroy()

		self.descWindow = nil
	end

	self.page = nil
	self.pages = nil
end

return NewSettingsScene
