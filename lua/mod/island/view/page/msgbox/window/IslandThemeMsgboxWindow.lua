local IslandThemeMsgboxWindow = class("IslandThemeMsgboxWindow", import(".IslandCommonMsgboxWindow"))

function IslandThemeMsgboxWindow:getUIName()
	return "IslandCommonMsgBoxForTheme"
end

function IslandThemeMsgboxWindow:OnLoaded()
	IslandThemeMsgboxWindow.super.OnLoaded(self)

	self.iconRaw = self._tf:Find("icon_raw"):GetComponent(typeof(RawImage))
	self.icon = self._tf:Find("icon"):GetComponent(typeof(Image))
	self.delBtn = self._tf:Find("delete")

	setText(self.delBtn:Find("Text"), i18n("island_btn_label_del"))
	setText(self._tf:Find("confirm/Text"), i18n("island_word_place"))
end

function IslandThemeMsgboxWindow:OnInit()
	IslandThemeMsgboxWindow.super.OnInit(self)
	onButton(self, self.delBtn, function()
		if self.settings.onDel then
			self.settings.onDel()
		end

		self:Hide()
	end, SFX_PANEL)
end

function IslandThemeMsgboxWindow:OnShow()
	self.settings.content = self.settings.theme.name

	IslandThemeMsgboxWindow.super.OnShow(self)
	self:FlushIcon()
end

function IslandThemeMsgboxWindow:OnHide()
	IslandThemeMsgboxWindow.super.OnHide(self)

	if not IsNil(self.iconRaw.texture) then
		Object.Destroy(self.iconRaw.texture)

		self.iconRaw.texture = nil
	end
end

function IslandThemeMsgboxWindow:FlushBtn(arg_7_1)
	return
end

function IslandThemeMsgboxWindow:FlushIcon()
	if isa(self.settings.theme, AgoraTheme) then
		self:LoadRawTex(self.settings.theme.id)
	else
		self:LoadImage(self.settings.theme.id)
	end
end

function IslandThemeMsgboxWindow:LoadRawTex(arg_9_1)
	local var_9_0 = AgoraCalc.BuildScreenShootSavePath(arg_9_1)
	local var_9_1

	if not PathMgr.FileExists(var_9_0) then
		self:LoadImage(0)

		do return end

		var_9_1 = UnityEngine.Texture2D.New(426, 320)
	end

	Tex2DExtension.LoadImage(var_9_1, (System.IO.File.ReadAllBytes(var_9_0)))

	self.iconRaw.texture = var_9_1

	setActive(self.iconRaw, true)
	setActive(self.icon, false)
end

function IslandThemeMsgboxWindow:LoadImage(arg_10_1)
	LoadSpriteAsync("island/IslandThemeIcon/" .. arg_10_1, function(arg_11_0)
		self.icon.sprite = arg_11_0

		self.icon:SetNativeSize()
	end)
	setActive(self.iconRaw, false)
	setActive(self.icon, true)
end

return IslandThemeMsgboxWindow
