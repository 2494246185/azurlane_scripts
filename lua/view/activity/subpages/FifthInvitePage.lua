local FifthInvitePage = class("FifthInvitePage", import(".FourthInvitePage"))

function FifthInvitePage:OnFirstFlush()
	FifthInvitePage.super.OnFirstFlush(self)
	onButton(self, self.helpBtn, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.five_qingdian.tip
		})
	end, SFX_PANEL)
end

return FifthInvitePage
