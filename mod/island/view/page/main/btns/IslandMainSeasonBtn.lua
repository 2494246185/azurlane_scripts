local IslandMainSeasonBtn = class("IslandMainSeasonBtn", import(".IslandMainBaseBtn"))

function IslandMainSeasonBtn:Init()
	IslandMainSeasonBtn.super.Init(self)

	self.invitePanel = self._tf:Find("invitePanel")
	self.inviteSlider = GetComponent(self.invitePanel:Find("Slider"), typeof(Image))

	setText(self.invitePanel:Find("Text"), i18n("match_ui_matching_invitation"))

	self.timer = FrameTimer.New(function()
		self:RefreshInvite()
	end, 3, -1)

	self.timer:Start()
end

function IslandMainSeasonBtn:Dispose()
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end

	self:StopLeanTween()
	IslandMainSeasonBtn.super.Dispose(self)
end

function IslandMainSeasonBtn:RefreshInvite()
	local var_4_0 = getProxy(PlayRoomProxy):GetInviteList()

	setActive(self.invitePanel, var_4_0[1] ~= nil)

	if var_4_0[1] and self.endTime ~= var_4_0[1].timestamp then
		self.endTime = var_4_0[1].timestamp

		self:StartLeanTween(pg.TimeMgr.GetInstance():GetServerTime(), var_4_0[1].timestamp + pg.gameset.match_refuseCD.key_value)
	end
end

function IslandMainSeasonBtn:StartLeanTween(arg_5_1, arg_5_2)
	self:StopLeanTween()

	if arg_5_2 <= arg_5_1 then
		return
	end

	LeanTween.value(self._tf.gameObject, (arg_5_2 - arg_5_1) / pg.gameset.match_refuseCD.key_value, 0, arg_5_2 - arg_5_1):setOnUpdate(System.Action_float(function(arg_6_0)
		self.inviteSlider.fillAmount = arg_6_0
	end)):setOnComplete(System.Action(function()
		self:StopLeanTween()
	end))
end

function IslandMainSeasonBtn:StopLeanTween()
	LeanTween.cancel(self._tf.gameObject)
end

return IslandMainSeasonBtn
