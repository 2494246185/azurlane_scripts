local SettingsAccountUSPanle = class("SettingsAccountUSPanle", import(".SettingsBasePanel"))

function SettingsAccountUSPanle:GetUIName()
	return "SettingsAccountUS"
end

function SettingsAccountUSPanle:GetTitle()
	return i18n("Settings_title_LoginJP")
end

function SettingsAccountUSPanle:GetTitleEn()
	return "  / ACCOUNT"
end

function SettingsAccountUSPanle:OnInit()
	self.userProxy = getProxy(UserProxy)
	self.accountTwitterUI = findTF(self._tf, "page1")
	self.yostarBtn = findTF(findTF(self.accountTwitterUI, "btn_layout/yostar_con"), "bind_yostar")

	setText(findTF(self.yostarBtn, "Text"), "Account Management")
	self:OnRegisterEvent()
end

function SettingsAccountUSPanle:OnRegisterEvent()
	onButton(self, self.yostarBtn, function()
		pg.SdkMgr.GetInstance():YoStarShowUserCenter()
	end)
end

function SettingsAccountUSPanle:OnUpdate()
	return
end

return SettingsAccountUSPanle
