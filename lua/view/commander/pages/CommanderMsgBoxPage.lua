local CommanderMsgBoxPage = class("CommanderMsgBoxPage", import("...base.BaseSubView"))

function CommanderMsgBoxPage:getUIName()
	return "CommanderMsgBoxUI"
end

function CommanderMsgBoxPage:OnInit()
	self.cancelBtn = self._tf:Find("frame/cancel_btn")
	self.text = self._tf:Find("frame/bg/content/Text")
	self.text1 = self._tf:Find("frame/bg/content/Text1")
	self.text2 = self._tf:Find("frame/bg/content/Text2")
	self.confirmBtn = self._tf:Find("frame/confirm_btn")
	self.closeBtn = self._tf:Find("frame/close_btn")

	onButton(self, self._tf, function()
		self:Hide()
	end, SFX_PANEL)
end

function CommanderMsgBoxPage:Show(arg_4_1)
	CommanderMsgBoxPage.super.Show(self)

	if arg_4_1.content1 then
		setText(self.text1, arg_4_1.content)
		setText(self.text2, arg_4_1.content1)
	elseif arg_4_1.content then
		setText(self.text, setColorStr(arg_4_1.content, "#847D7B"))
	end

	onButton(self, self.cancelBtn, function()
		self:Hide()

		if arg_4_1.onNo then
			arg_4_1.onNo()
		end
	end, SFX_PANEL)
	onButton(self, self.confirmBtn, function()
		self:Hide()

		if arg_4_1.onYes then
			arg_4_1.onYes()
		end
	end, SFX_PANEL)
	onButton(self, self.closeBtn, function()
		self:Hide()

		if arg_4_1.onClose then
			arg_4_1.onClose()
		end
	end, SFX_PANEL)

	if arg_4_1.onShow then
		arg_4_1.onShow()
	end

	self._tf:SetAsLastSibling()
end

function CommanderMsgBoxPage:Hide()
	CommanderMsgBoxPage.super.Hide(self)
	setText(self.text, "")
	setText(self.text1, "")
	setText(self.text2, "")
end

function CommanderMsgBoxPage:OnDestroy()
	self:Hide()
end

return CommanderMsgBoxPage
