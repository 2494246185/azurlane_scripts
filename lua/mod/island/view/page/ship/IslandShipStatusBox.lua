local IslandShipStatusBox = class("IslandShipStatusBox", import(".IslandShipStatusPage"))

function IslandShipStatusBox:getUIName()
	return "IslandShipStatusBox"
end

function IslandShipStatusBox:OnLoaded()
	IslandShipStatusBox.super.OnLoaded(self)

	self.hideBtn = self._tf:Find("close")
end

function IslandShipStatusBox:OnInit()
	IslandShipStatusBox.super.OnInit(self)
	onButton(self, self.hideBtn, function()
		self:Hide()
	end, SFX_PANEL)
end

function IslandShipStatusBox:OnShow(...)
	IslandShipStatusBox.super.OnShow(self, ...)
	self:OverlayPanel(self._tf, {
		groupDelta = 1
	})
end

function IslandShipStatusBox:OnHide()
	IslandShipStatusBox.super.OnHide(self)
	self:UnOverlayPanel(self._tf, self._parentTf)
end

function IslandShipStatusBox:OnDisable()
	self:OnHide()
end

return IslandShipStatusBox
