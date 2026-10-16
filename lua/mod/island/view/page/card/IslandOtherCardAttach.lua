local IslandOtherCardAttach = class("IslandOtherCardAttach", import(".external.IslandOtherCardLayer"))

function IslandOtherCardAttach:didEnter()
	IslandOtherCardAttach.super.didEnter(self)
	onNextTick(function()
		self:ExtraHandle()
	end)
end

function IslandOtherCardAttach:ExtraHandle()
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
end

function IslandOtherCardAttach:closeView()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, self.contextData.container)
	self.contextData.onClose()
end

return IslandOtherCardAttach
