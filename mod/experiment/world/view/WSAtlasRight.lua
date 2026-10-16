local WSAtlasRight = class("WSAtlasRight", import("...BaseEntity"))

WSAtlasRight.Fields = {
	isDisplay = "boolean",
	btnSwitch = "userdata",
	rtNameBg = "userdata",
	rtDisplayIcon = "userdata",
	delegateTimer = "table",
	btnDeleConfirm = "userdata",
	btnSettings = "userdata",
	rtMapInfo = "userdata",
	wsWorldInfo = "table",
	rtDelegatePanel = "userdata",
	world = "table",
	transform = "userdata",
	rtDisplayPanel = "userdata",
	btnDeleCancel = "userdata",
	rtBg = "userdata",
	btnDelegate = "userdata",
	rtWorldInfo = "userdata"
}

function WSAtlasRight:Setup()
	pg.DelegateInfo.New(self)
	self:Init()
end

function WSAtlasRight:Dispose()
	if self.delegateTimer then
		self.delegateTimer:Stop()

		self.delegateTimer = nil
	end

	self.wsWorldInfo:Dispose()
	pg.DelegateInfo.Dispose(self)
	self:Clear()
end

function WSAtlasRight:Init()
	self.rtBg = self.transform:Find("bg")
	self.rtNameBg = self.transform:Find("name_bg")
	self.rtDisplayIcon = self.transform:Find("line/display_icon")
	self.rtDisplayPanel = self.transform:Find("line/display_panel")
	self.rtWorldInfo = self.rtDisplayPanel:Find("world_info")
	self.btnSettings = self.rtDisplayPanel:Find("btns/settings_btn")
	self.btnSwitch = self.rtDisplayPanel:Find("btns/switch_btn")
	self.btnDelegate = self.rtDisplayPanel:Find("btns/delegate_btn")
	self.rtDelegatePanel = self.transform:Find("delegate_panel")
	self.btnDeleCancel = self.rtDelegatePanel:Find("doing/cancel_btn")
	self.btnDeleConfirm = self.rtDelegatePanel:Find("finish/confirm_btn")

	setText(self.rtWorldInfo:Find("power/bg/Word"), i18n("world_total_power"))
	setText(self.rtWorldInfo:Find("explore/mileage/Text"), i18n("world_mileage"))
	setText(self.rtWorldInfo:Find("explore/pressing/Text"), i18n("world_pressing"))
	setText(self.rtDelegatePanel:Find("doing/Slider/name"), i18n("world_auto_plan_progress"))

	self.wsWorldInfo = WSWorldInfo.New()
	self.wsWorldInfo.transform = self.rtWorldInfo

	self.wsWorldInfo:Setup()
	setActive(self.rtWorldInfo, nowWorld():IsSystemOpen(WorldConst.SystemWorldInfo))
	setText(self.rtDisplayIcon:Find("name"), i18n("world_map_title_tips"))
	onButton(self, self.rtDisplayIcon, function()
		self.isDisplay = not self.isDisplay

		self:Collapse()
	end, SFX_PANEL)

	self.isDisplay = true

	self:Collapse()
	self:UpdateDelegate()
end

function WSAtlasRight:Collapse()
	if self.isDisplay then
		self.rtDisplayIcon:Find("icon").localScale = Vector3.one or Vector3(-1, 1, 1)
	end

	setActive(self.rtDisplayPanel, self.isDisplay)
	setActive(self.rtBg, self.isDisplay)
	setActive(self.rtNameBg, not self.isDisplay)
end

function WSAtlasRight:SetOverSize(arg_6_1)
	self.rtBg.offsetMax = Vector2(-arg_6_1, self.rtBg.offsetMax.y)
	self.rtNameBg.offsetMax = Vector2(-arg_6_1, self.rtNameBg.offsetMax.y)
end

function WSAtlasRight:UpdateDelegate()
	local var_7_9000
	local var_7_0 = getProxy(ChapterAutoProxy)
	local var_7_1 = var_7_0:HasTypeCommission(ChapterAutoProxy.TYPE.WORLD)

	setActive(self.rtDelegatePanel, var_7_1)

	if not var_7_1 then
		if self.delegateTimer then
			self.delegateTimer:Stop()

			self.delegateTimer = nil
		end

		return
	end

	local var_7_2 = var_7_0:GetCommissionList()
	local var_7_3 = var_7_2[1]:GetStartTime()
	local var_7_4 = pg.TimeMgr.GetInstance():GetServerTime()
	local var_7_5 = var_7_2[var_7_9000]:GetFinishTime()

	setActive(self.rtDelegatePanel:Find("doing"), var_7_4 < #var_7_2)
	setActive(self.rtDelegatePanel:Find("finish"), var_7_5 <= var_7_4)

	if var_7_4 < var_7_5 then
		if self.delegateTimer then
			self.delegateTimer:Stop()
		end

		self.delegateTimer = Timer.New(function()
			local var_8_0 = 0

			var_7_4 = pg.TimeMgr.GetInstance():GetServerTime()

			for iter_8_0, iter_8_1 in ipairs(var_7_2) do
				if var_7_4 < iter_8_1:GetFinishTime() then
					break
				else
					var_8_0 = var_8_0 + 1
				end
			end

			if var_8_0 < #var_7_2 then
				setText(self.rtDelegatePanel:Find("doing/time"), string.format("%02d:%02d:%02d", calcFloor((var_7_5 - var_7_4) / 3600), calcFloor((var_7_5 - var_7_4) % 3600 / 60), (var_7_5 - var_7_4) % 60))
				setText(self.rtDelegatePanel:Find("doing/Slider/Text"), string.format("%d/%d", var_8_0, #var_7_2))
				setText(self.rtDelegatePanel:Find("doing/name/Text"), pg.world_chapter_random[var_7_2[var_8_0 + 1].id].name)
				setSlider(self.rtDelegatePanel:Find("doing/Slider"), 0, var_7_5 - var_7_3, var_7_4 - var_7_3)
			else
				setActive(self.rtDelegatePanel:Find("doing"), false)
				setActive(self.rtDelegatePanel:Find("finish"), true)
			end
		end, 1, var_7_5 - var_7_4 + 1)

		self.delegateTimer.func()
		self.delegateTimer:Start()
	end
end

return WSAtlasRight
