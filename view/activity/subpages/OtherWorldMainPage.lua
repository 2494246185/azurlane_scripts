local OtherWorldMainPage = class("OtherWorldMainPage", import(".TemplatePage.PreviewTemplatePage"))
local var_0_1 = 0.45
local var_0_2 = 0.2
local var_0_3 = 1.2

function OtherWorldMainPage:OnInit()
	OtherWorldMainPage.super.OnInit(self)

	self.effectBlankScreen = self.bg:Find("blank_screen_effect")
	self.effectOpen = self.bg:Find("open_effect")
	self.effectBlink = self.bg:Find("blink_effect")
	self.effectClick = self.bg:Find("click_effect")
end

function OtherWorldMainPage:OnFirstFlush()
	self.skinshopBtn = self.btnList:Find("skinshop")

	onButton(self, self.skinshopBtn, function()
		self:PlayClickEffect(self.skinshopBtn, function()
			pg.m02:sendNotification(GAME.GO_SCENE, SCENE.SKINSHOP)
		end)
	end, SFX_PANEL)

	self.mountainBtn = self.btnList:Find("mountain")

	onButton(self, self.mountainBtn, function()
		self:PlayClickEffect(self.mountainBtn, function()
			pg.m02:sendNotification(GAME.GO_SCENE, SCENE.OTHERWORLD_BACKHILL)
		end)
	end, SFX_PANEL)

	self.buildBtn = self.btnList:Find("build")

	onButton(self, self.buildBtn, function()
		self:PlayClickEffect(self.buildBtn, function()
			self:emit(ActivityMediator.EVENT_GO_SCENE, SCENE.GETBOAT, {
				projectName = BuildShipScene.PROJECTS.ACTIVITY
			})
		end)
	end, SFX_PANEL)

	self.fightBtn = self.btnList:Find("fight")

	onButton(self, self.fightBtn, function()
		self:PlayClickEffect(self.fightBtn, function()
			pg.m02:sendNotification(GAME.GO_SCENE, SCENE.OTHERWORLD_MAP)
		end)
	end, SFX_PANEL)
	self:PlayOpenEffect()
end

function OtherWorldMainPage:PlayOpenEffect()
	setActive(self.effectBlankScreen, true)
	setActive(self.effectOpen, false)
	self:managedTween(LeanTween.delayedCall, function()
		setActive(self.effectOpen, true)
	end, var_0_2, nil)
	self:managedTween(LeanTween.delayedCall, function()
		setActive(self.effectBlankScreen, false)
	end, var_0_1, nil)
	self:managedTween(LeanTween.delayedCall, function()
		setActive(self.effectOpen, false)
		setActive(self.effectBlink, true)
	end, var_0_2 + var_0_3, nil)
end

function OtherWorldMainPage:PlayClickEffect(arg_15_1, arg_15_2)
	local var_15_0 = pg.UIMgr.GetInstance().OverlayEffect
	local var_15_1 = var_15_0:GetChild(0)
	local var_15_2 = var_15_1 and var_15_1.localPosition:Sub((Vector3(192, 60, 0))) or arg_15_1.localPosition

	setLocalPosition(self.effectClick, var_15_0)
	setActive(self.effectClick, true)
	self:managedTween(LeanTween.delayedCall, function()
		setActive(self.effectClick, false)

		if arg_15_2 then
			arg_15_2()
		end
	end, 0.3, nil)
end

function OtherWorldMainPage:OnDestroy()
	self:cleanManagedTween()
end

return OtherWorldMainPage
