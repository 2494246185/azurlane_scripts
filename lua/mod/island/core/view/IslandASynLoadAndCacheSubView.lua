local IslandASynLoadAndCacheSubView = class("IslandASynLoadAndCacheSubView", import(".IslandASynLoadSubView"))

function IslandASynLoadAndCacheSubView:LoadUI(arg_1_1)
	self:GetPoolMgr():GetUI(self:GetUIName(), function(arg_2_0)
		setParent(arg_2_0, (self:GetUIParent()))
		arg_1_1(arg_2_0)
	end)
end

function IslandASynLoadAndCacheSubView:UnloadUI()
	if not self._go then
		return
	end

	self:GetPoolMgr():ReturnUI(self:GetUIName(), self._go)
end

return IslandASynLoadAndCacheSubView
