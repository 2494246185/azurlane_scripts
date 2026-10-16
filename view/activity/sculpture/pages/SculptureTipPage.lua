local SculptureTipPage = class("SculptureTipPage", import("view.base.BaseSubView"))

function SculptureTipPage:getUIName()
	return "SculptureTipUI"
end

function SculptureTipPage:OnLoaded()
	self.tip = self._tf:Find("tip")
end

function SculptureTipPage:OnInit()
	return
end

function SculptureTipPage:Show()
	SculptureTipPage.super.Show(self)
	setActive(self.tip, true)
	onDelayTick(function()
		self:Hide()
	end, 2)
end

function SculptureTipPage:Hide()
	SculptureTipPage.super.Hide(self)
	setActive(self.tip, false)
end

function SculptureTipPage:OnDestroy()
	return
end

return SculptureTipPage
