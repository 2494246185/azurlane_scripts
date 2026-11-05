local NewEducateDropLayer = class("NewEducateDropLayer", import("view.newEducate.base.NewEducateBaseUI"))

function NewEducateDropLayer:getUIName()
	return "NewEducateDropUI"
end

function NewEducateDropLayer:init()
	pg.UIMgr.GetInstance():BlurPanel(self._tf)

	self.drops = self.contextData.items or {}
	self.awardWindow = self._tf:Find("award_window")
	self.anim = self.awardWindow:GetComponent(typeof(Animation))
	self.animEvent = self.awardWindow:GetComponent(typeof(DftAniEvent))

	self.animEvent:SetEndEvent(function()
		self:emit(NewEducateDropLayer.ON_CLOSE)
	end)

	self.tipTF = self.awardWindow:Find("tip")

	setText(self.tipTF, i18n("child_close_tip"))

	self.itemContainer = self.awardWindow:Find("scroll/content")
	self.itemTpl = self.awardWindow:Find("tpl")

	setActive(self.itemTpl, false)

	self.favorWindow = self._tf:Find("favor_window")
	self.favorLvTF = self.favorWindow:Find("gift/heart/level")

	setActive(self.awardWindow, false)
	setActive(self.favorWindow, false)
	self._tf:SetAsLastSibling()
end

function NewEducateDropLayer:didEnter()
	onButton(self, self.awardWindow:Find("close"), function()
		self:_close()
	end, SFX_CANCEL)
	seriesAsync({
		function(arg_6_0)
			if self.contextData.isFavor then
				setActive(self.favorWindow, true)
				setText(self.favorLvTF, self.contextData.char:GetFavorInfo().lv)
				self:managedTween(LeanTween.delayedCall, arg_6_0, 1, nil)
			else
				arg_6_0()
			end
		end
	}, function()
		self:ShowAwardWindow()
	end)
end

function NewEducateDropLayer:ShowAwardWindow()
	setActive(self.favorWindow, false)

	self.inAnimPlaying = true

	setActive(self.awardWindow, true)
	self.anim:Play("anim_educate_dropaward_in")

	local var_8_0 = {}

	table.insert(var_8_0, function(arg_9_0)
		self:managedTween(LeanTween.delayedCall, function()
			arg_9_0()
		end, 0.33, nil)
	end)

	for iter_8_0 = 1, #self.drops do
		table.insert(var_8_0, function(arg_11_0)
			local var_11_0 = self.drops[iter_8_0]
			local var_11_1 = cloneTplTo(self.itemTpl, self.itemContainer)

			NewEducateHelper.UpdateItem(var_11_1, self.drops[iter_8_0])
			onButton(self, var_11_1, function()
				self:emit(NewEducateBaseUI.ON_ITEM, {
					drop = var_11_0
				})
			end)
			self:managedTween(LeanTween.delayedCall, function()
				arg_11_0()
			end, 0.066, nil)
		end)
	end

	seriesAsync(var_8_0, function()
		self:managedTween(LeanTween.delayedCall, function()
			self.inAnimPlaying = false
		end, 0.066, nil)
	end)
end

function NewEducateDropLayer:_close()
	if pg.NewGuideMgr.GetInstance():IsBusy() then
		self:emit(NewEducateDropLayer.ON_CLOSE)

		return
	end

	if self.inAnimPlaying or self.isCloseAnim then
		return
	end

	self.anim:Play("anim_educate_awardinfo_award_out")

	self.isCloseAnim = true
end

function NewEducateDropLayer:onBackPressed()
	self:_close()
end

function NewEducateDropLayer:willExit()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)

	if self.contextData.removeFunc then
		self.contextData.removeFunc()

		self.contextData.removeFunc = nil
	end
end

return NewEducateDropLayer
