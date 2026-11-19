local IslandRequestFriendBox = class("IslandRequestFriendBox", import("view.base.BaseSubView"))

function IslandRequestFriendBox:getUIName()
	return "IslandRequestFriendBox"
end

function IslandRequestFriendBox:OnLoaded()
	setText(self._tf:Find("frame/title"), i18n("word_apply"))
	setText(self._tf:Find("Text"), i18n("friend_request_msg_title"))

	self.closeBtn = self._tf:Find("frame/close")
	self.requestBtn = self._tf:Find("request")

	setText(self.requestBtn:Find("Text"), i18n("word_apply"))

	self.input = self._tf:Find("InputField")

	setText(self.input:Find("Placeholder"), i18n("friend_request_msg_placeholder"))
end

function IslandRequestFriendBox:OnInit()
	onButton(self, self.closeBtn, function()
		self:Hide()
	end, SFX_PANEL)
	onButton(self, self.requestBtn, function()
		pg.m02:sendNotification(GAME.FRIEND_SEND_REQUEST, {
			id = self.userId,
			msg = getInputText(self.input)
		})
	end, SFX_PANEL)
end

function IslandRequestFriendBox:Show(arg_6_1)
	IslandRequestFriendBox.super.Show(self)

	self.userId = arg_6_1

	setInputText(self.input, "")
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
end

function IslandRequestFriendBox:Hide()
	IslandRequestFriendBox.super.Hide(self)
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, self._parentTf)
end

function IslandRequestFriendBox:OnDestroy()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, self._parentTf)
end

return IslandRequestFriendBox
