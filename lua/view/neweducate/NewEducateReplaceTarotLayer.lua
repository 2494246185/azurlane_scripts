local NewEducateReplaceTarotLayer = class("NewEducateReplaceTarotLayer", import("view.newEducate.base.NewEducateBaseUI"))

function NewEducateReplaceTarotLayer:getUIName()
	return "NewEducateReplaceTarotUI"
end

function NewEducateReplaceTarotLayer:init()
	setText(self._tf:Find("title"), i18n("child2_replace_title"))
	setText(self._tf:Find("tip"), i18n("child2_replace_tip"))

	self.toggleTF = self._tf:Find("toggle")

	setText(self.toggleTF:Find("Text"), i18n("child2_show_detail_desc"))

	self.oldTF = self._tf:Find("old")
	self.oldCard = NewEducateTarotCard.New(self.oldTF)
	self.newTF = self._tf:Find("new")
	self.newCard = NewEducateTarotCard.New(self.newTF)
	self.cancelBtn = self._tf:Find("cancel_btn")

	setText(self.cancelBtn:Find("Text"), i18n("child2_replace_cancel"))

	self.sureBtn = self._tf:Find("sure_btn")

	setText(self.sureBtn:Find("Text"), i18n("child2_replace_sure"))
end

function NewEducateReplaceTarotLayer:didEnter()
	self:BlurPanel(self._tf, {
		groupDelta = 3
	})
	onButton(self, self.cancelBtn, function()
		self.state:SetHoldId(self.oldId)
		self:CheckState()
	end, SFX_PANEL)
	onButton(self, self.sureBtn, function()
		self.state:SetHoldId(self.newId)
		self:CheckState()
	end, SFX_PANEL)
	onToggle(self, self.toggleTF, function(arg_6_0)
		NewEducateHelper.SetTarotDeatilDescData(arg_6_0)
		self.oldCard:UpdateDescMode(arg_6_0)
		self.newCard:UpdateDescMode(arg_6_0)
	end, SFX_PANEL)
	self:UpdateView()
	triggerToggle(self.toggleTF, NewEducateHelper.IsShowTarotDeatilDesc())
end

function NewEducateReplaceTarotLayer:UpdateView()
	self.state = getProxy(NewEducateProxy):GetCurChar():GetFSM():GetPriorityState()
	self.oldId = self.state:GetHoldId()

	if self.oldId == 0 then
		self.oldId = self.contextData.char:GetTarotId()
	end

	self.newId = self.state:GetFirstId()

	self.oldCard:Update(self.oldId, NewEducateTarotCard.TYPE.CURRENT)
	self.newCard:Update(self.newId, NewEducateTarotCard.TYPE.REPLACE)
	triggerToggle(self.toggleTF, false)
end

function NewEducateReplaceTarotLayer:CheckState()
	self.state:PopId()

	if self.state:IsFinish() then
		self:emit(NewEducateReplaceTarotMediator.ON_REPLACE_TAROT, self.state:GetHoldId() == self.contextData.char:GetTarotId() and 0 or self.state:GetHoldId())
	else
		self:closeView()
	end
end

function NewEducateReplaceTarotLayer:OnReplaceDone(arg_9_1)
	seriesAsync({
		function(arg_10_0)
			self._tf:GetComponent(typeof(Animation)):Play("Anim_NewEducateReplaceTarotUI_cliek")
			onDelayTick(arg_10_0, 0.4)
		end,
		function(arg_11_0)
			if #arg_9_1.drops > 0 then
				self:emit(NewEducateReplaceTarotLayer.ON_DROP, {
					items = arg_9_1.drops,
					removeFunc = function()
						arg_11_0()
					end
				})
			else
				arg_11_0()
			end
		end
	}, function()
		self:closeView()
	end)
end

function NewEducateReplaceTarotLayer:onBackPressed()
	return
end

function NewEducateReplaceTarotLayer:willExit()
	self.oldCard:Dispose()
	self.newCard:Dispose()
	self:UnOverlayPanel(self._tf)
	existCall(self.contextData.onExit)
end

return NewEducateReplaceTarotLayer
