local TwoPointFiveMainPage = class("TwoPointFiveMainPage", import("view.activity.CorePage.CoreActivityPage"))

function TwoPointFiveMainPage:OnInit()
	self.storyBtn = self._tf:Find("AD/story_btn")
	self.redPoint = self.storyBtn:Find("redPoint")
end

function TwoPointFiveMainPage:OnFirstFlush()
	TwoPointFiveMainPage.super.OnFirstFlush(self)

	self.scenario = self:GetOutPostScenarioPage().New(self._tf, self.event)

	self.scenario:SetCoreStoryPage(self)
	self.scenario:RegisterView(self.coreActivityUI)

	local var_2_0 = self.activity:getConfig("config_client")

	if type(var_2_0) == "table" then
		local var_2_1 = var_2_0.intro_story or nil

		if type(var_2_1) == "table" then
			var_2_1 = var_2_1[1]
		end

		if var_2_1 and var_2_1 ~= "" then
			local var_2_2 = pg.NewStoryMgr.GetInstance()

			if not var_2_2:IsPlayed(var_2_1) then
				var_2_2:Play(var_2_1)
			end
		end
	end

	onButton(self, self.storyBtn, function()
		self.scenario:Load()
		self.scenario:SetActivity(self.activity)
		self.scenario:UpdateStoryTask()
		self.scenario:ActionInvoke("UpdateView")
		self:ShowScenarioLayer(true)
		PlayerPrefs.SetInt(Activity.GetPlayerActivyIDKey(self.activity.id), 1)
	end, SFX_PANEL)
	self:refreshRed()
end

function TwoPointFiveMainPage:OnUpdateFlush()
	TwoPointFiveMainPage.super.OnUpdateFlush(self)
	self:refreshRed()

	if self.coreActivityUI.contextData.activeScenario and not self:IsShowingPopWindow() then
		triggerButton(self.storyBtn)
	end
end

function TwoPointFiveMainPage:GetOutPostScenarioPage()
	return TwoPointFiveScenarioPage
end

function TwoPointFiveMainPage:refreshRed()
	setActive(self.redPoint, self.activity:readyToAchieve())
end

function TwoPointFiveMainPage:ShowScenarioLayer(arg_7_1)
	if not self.coreActivityUI.exited then
		self.coreActivityUI:ActiveScenarioLayer(arg_7_1)
	end

	if arg_7_1 then
		self.scenario:ActionInvoke("Show")
	else
		self.scenario:Hide()
	end
end

function TwoPointFiveMainPage:IsShowingPopWindow()
	return self.scenario and self.scenario:isShowing() or false
end

function TwoPointFiveMainPage:ClosePopWindow()
	if self:IsShowingPopWindow() then
		self:ShowScenarioLayer(false)
	end
end

function TwoPointFiveMainPage:OnDestroy()
	if self.scenario then
		self:ClosePopWindow()
		self.scenario:Destroy()

		self.scenario = nil
	end
end

return TwoPointFiveMainPage
