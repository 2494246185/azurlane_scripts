local IslandSelfCardAttach = class("IslandSelfCardAttach", import(".external.IslandSelfCardLayer"))

function IslandSelfCardAttach:didEnter()
	IslandSelfCardAttach.super.didEnter(self)
	onNextTick(function()
		self:ExtraHandle()
	end)
end

function IslandSelfCardAttach:ExtraHandle()
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
end

function IslandSelfCardAttach:closeView()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, self.contextData.container)
	self.contextData.onClose()
end

return IslandSelfCardAttach
