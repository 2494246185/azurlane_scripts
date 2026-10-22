local AiriLoginPanelView = class("AiriLoginPanelView", import("...base.BaseSubView"))

function AiriLoginPanelView:getUIName()
	return "AiriLoginPanelView"
end

function AiriLoginPanelView:OnLoaded()
	return
end

function AiriLoginPanelView:SetShareData(arg_3_1)
	self.shareData = arg_3_1
end

function AiriLoginPanelView:OnInit()
	self.airiLoginBtn = self._tf:Find("airi_login")
	self.clearTranscodeBtn = self._tf:Find("clear_transcode")
	self.jpLoginCon = self._tf:Find("jp_login_btns")
	self.jpYoStarLoginBtn = self.jpLoginCon:Find("yostar_login")
	self.jpTransBtn = self.jpLoginCon:Find("yostar_trans")
	self.usLoginCon = self._tf:Find("en_login_btns")
	self.usYoStarLoginBtn = self.usLoginCon:Find("yostar_login")
	self.usTransBtn = self.usLoginCon:Find("yostar_trans")
	self.usLogOutBtn = self.usLoginCon:Find("yostar_logout")

	setActive(self.clearTranscodeBtn, false)
	setText(self.jpYoStarLoginBtn:Find("Text"), i18n("yostar_login_btn"))
	setText(self.jpTransBtn:Find("Text"), i18n("yostar_trans_btn"))
	setActive(self.jpYoStarLoginBtn, PLATFORM_CODE == PLATFORM_JP)
	setActive(self.jpTransBtn, PLATFORM_CODE == PLATFORM_JP)
	setActive(self.usLoginCon, PLATFORM_CODE == PLATFORM_US)
	self:InitEvent()
end

function AiriLoginPanelView:InitEvent()
	onButton(self, self.airiLoginBtn, function()
		pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_CONFIRM)
		pg.SdkMgr.GetInstance():YoStarLoginSDK()
	end)
	onButton(self, self.clearTranscodeBtn, function()
		return
	end)

	if PLATFORM_CODE == PLATFORM_JP then
		onButton(self, self.jpYoStarLoginBtn, function()
			pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_CONFIRM)
			pg.SdkMgr.GetInstance():YoStarLoginSDK()
		end)
		onButton(self, self.jpTransBtn, function()
			pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_CONFIRM)
			Application.OpenURL("https://migration.yostar.co.jp?pid=JP-AZURLANE")
		end)
	elseif PLATFORM_CODE == PLATFORM_US then
		onButton(self, self.usTransBtn, function()
			pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_CONFIRM)
			Application.OpenURL("https://migration.yo-star.com/?pid=US-AZURLANE")
		end)
		onButton(self, self.usLogOutBtn, function()
			pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_CONFIRM)
			pg.SdkMgr.GetInstance():YoStarShowSwitchAccount()
		end)
	end

	self:RefreshUI(false)
	triggerButton(self.airiLoginBtn)
end

function AiriLoginPanelView:RefreshUI(arg_12_1)
	setActive(self.usLogOutBtn, arg_12_1)
end

function AiriLoginPanelView:OnDestroy()
	return
end

return AiriLoginPanelView
