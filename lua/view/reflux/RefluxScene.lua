local RefluxScene = class("RefluxScene", import("..base.BaseUI"))

RefluxScene.Sign = 1
RefluxScene.Task = 2
RefluxScene.PT = 3
RefluxScene.Shop = 4

function RefluxScene:getUIName()
	return "RefluxUI"
end

function RefluxScene:init()
	self:findUI()
	self:initData()
	self:addListener()
end

function RefluxScene:didEnter()
	self:updateRedPotList()

	if not getProxy(RefluxProxy):isInRefluxTime() then
		self:closeView()

		return
	end

	if not self:tryOpenLetterView() then
		self:tryAutoOpenLastView()
	end

	self:updateDay()
	self:OverlayPanel(self._tf)
end

function RefluxScene:willExit()
	for iter_4_0, iter_4_1 in ipairs(self.viewList) do
		if iter_4_1 and iter_4_1:GetLoaded() then
			iter_4_1:Destroy()
		end
	end

	if self.letterView then
		self.letterView:Destroy()

		self.letterView = nil

		return
	end

	self:UnOverlayPanel(self._tf, self._parentTf)
end

function RefluxScene:onBackPressed()
	if self.letterView and self.letterView:isShowing() then
		self.letterView:Hide()

		self.letterView = nil

		return
	end

	self:closeView()
end

function RefluxScene:findUI()
	self.letterContainer = self._tf:Find("PanelLetter")
	self.panelContainer = self._tf:Find("PanelContainer")

	local var_6_0 = self._tf:Find("left/left_bar")

	self.letterBtn = var_6_0:Find("letter")
	self.signToggle = var_6_0:Find("tabs/sign")
	self.taskToggle = var_6_0:Find("tabs/task")
	self.ptToggle = var_6_0:Find("tabs/pt")
	self.shopToggle = var_6_0:Find("tabs/shop")
	self.toggleList = {
		[RefluxScene.Sign] = self.signToggle,
		[RefluxScene.Task] = self.taskToggle,
		[RefluxScene.PT] = self.ptToggle,
		[RefluxScene.Shop] = self.shopToggle
	}
	self.redPotList = {
		[RefluxScene.Sign] = self.signToggle:Find("Red"),
		[RefluxScene.Task] = self.taskToggle:Find("Red"),
		[RefluxScene.PT] = self.ptToggle:Find("Red"),
		[RefluxScene.Shop] = self.shopToggle:Find("Red")
	}
	self.backBtn = var_6_0:Find("back")
	self.dayText = self._tf:Find("left/time/text")

	setText(self._tf:Find("left/time/icon"), i18n("reflux_word_1"))
	setText(self._tf:Find("left/time/icon1"), i18n("word_date"))
end

function RefluxScene:initData()
	self.curViewIndex = 0
	self.letterView = RefluxAnimationPlayer.New(pg.UIMgr.GetInstance().OverlayUITop)
	self.signView = RefluxSignView.New(self.panelContainer, self.event, self.contextData)
	self.taskView = RefluxTaskView.New(self.panelContainer, self.event, self.contextData)
	self.ptView = RefluxPTView.New(self.panelContainer, self.event, self.contextData)
	self.shopView = RefluxShopView.New(self.panelContainer, self.event, self.contextData)
	self.viewList = {
		[RefluxScene.Sign] = self.signView,
		[RefluxScene.Task] = self.taskView,
		[RefluxScene.PT] = self.ptView,
		[RefluxScene.Shop] = self.shopView
	}
end

function RefluxScene:addListener()
	onButton(self, self.backBtn, function()
		self:onBackPressed()
	end, SFX_CANCEL)
	onButton(self, self.letterBtn, function()
		self:switchLetter()
	end, SFX_PANEL)
	onToggle(self, self.signToggle, function(arg_11_0)
		if arg_11_0 == true then
			self:switchPage(RefluxScene.Sign)
		end
	end, SFX_PANEL)
	onToggle(self, self.taskToggle, function(arg_12_0)
		if arg_12_0 == true then
			self:switchPage(RefluxScene.Task)
		end
	end, SFX_PANEL)
	onToggle(self, self.ptToggle, function(arg_13_0)
		if arg_13_0 == true then
			self:switchPage(RefluxScene.PT)
		end
	end, SFX_PANEL)
	onToggle(self, self.shopToggle, function(arg_14_0)
		if arg_14_0 == true then
			self:switchPage(RefluxScene.Shop)
			self:updateRedPotList()
		end
	end, SFX_PANEL)
end

function RefluxScene:tryOpenLetterView()
	return false
end

function RefluxScene:switchPage(arg_16_1)
	if self.curViewIndex ~= arg_16_1 then
		self.viewList[arg_16_1]:Load()
		self.viewList[arg_16_1]:ActionInvoke("Show")
		self.viewList[arg_16_1]:ActionInvoke("updateOutline")

		if self.curViewIndex > 0 then
			self.viewList[self.curViewIndex]:Hide()
		end

		self.curViewIndex = arg_16_1
		self.contextData.lastViewIndex = arg_16_1
	end
end

function RefluxScene:tryAutoOpenLastView()
	if self.contextData.lastViewIndex then
		triggerToggle(self.toggleList[self.contextData.lastViewIndex], true)
	else
		triggerToggle(self.toggleList[RefluxScene.Sign], true)
	end
end

function RefluxScene:switchLetter()
	self.letterView:ExecuteAction("Play4Review", getProxy(RefluxProxy):GetRefluxBgs(), function()
		self.letterView:Hide()
	end)
end

function RefluxScene:updateRedPotList()
	setActive(self.redPotList[RefluxScene.Sign], false)
	setActive(self.redPotList[RefluxScene.Task], (RefluxTaskView.isAnyTaskCanGetAward()))
	setActive(self.redPotList[RefluxScene.PT], (RefluxPTView.isAnyPTCanGetAward()))
	setActive(self.redPotList[RefluxScene.Shop], (RefluxShopView.isShowRedPot()))
end

function RefluxScene:updateDay()
	local var_21_0 = pg.TimeMgr.GetInstance()

	setText(self.dayText, #pg.return_sign_template.all - math.clamp(var_21_0:DiffDay(getProxy(RefluxProxy).returnTimestamp, var_21_0:GetServerTime()), 0, #pg.return_sign_template.all - 1))
end

return RefluxScene
