local IslandAgoraUpgradeMsgboxWindow = class("IslandAgoraUpgradeMsgboxWindow", import(".IslandCommonMsgboxEXWindow"))

function IslandAgoraUpgradeMsgboxWindow:OnLoaded()
	IslandAgoraUpgradeMsgboxWindow.super.OnLoaded(self)
	setText(self._tf:Find("cancel/Text"), i18n("island_label_furniture_exit"))
	setText(self._tf:Find("confirm/Text"), i18n("island_label_furniture_save"))
end

function IslandAgoraUpgradeMsgboxWindow:OnShow()
	IslandAgoraUpgradeMsgboxWindow.super.OnShow(self)
	self:AddTimer(self.settings.duetime)
end

function IslandAgoraUpgradeMsgboxWindow:AddTimer(arg_3_1)
	self:RemoveTimer()

	if arg_3_1 - pg.TimeMgr.GetInstance():GetServerTime() <= 0 then
		self:Hide()

		return
	end

	self.timer = Timer.New(function()
		local var_4_0 = pg.TimeMgr.GetInstance():GetServerTime()

		if arg_3_1 - var_4_0 <= 0 then
			self:RemoveTimer()
			self:Hide()
		else
			self.contentTxt.text = i18n("island_label_furniture_save_tip", pg.TimeMgr.GetInstance():DescCDTime(arg_3_1 - var_4_0))
		end
	end, 1, -1)

	self.timer:Start()
	self.timer.func()
end

function IslandAgoraUpgradeMsgboxWindow:RemoveTimer()
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

function IslandAgoraUpgradeMsgboxWindow:OnHide()
	IslandAgoraUpgradeMsgboxWindow.super.OnHide(self)
	self:RemoveTimer()
end

function IslandAgoraUpgradeMsgboxWindow:FlushBtn(arg_7_1)
	return
end

function IslandAgoraUpgradeMsgboxWindow:OnDestroy()
	self:RemoveTimer()
end

return IslandAgoraUpgradeMsgboxWindow
