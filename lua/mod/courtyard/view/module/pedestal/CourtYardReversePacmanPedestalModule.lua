local CourtYardReversePacmanPedestalModule = class("CourtYardReversePacmanPedestalModule", import("..CourtYardBaseModule"))

function CourtYardReversePacmanPedestalModule:OnInit()
	self.storey = self.data
	self.scrollView = self._tf.parent:Find("scroll_view")
end

function CourtYardReversePacmanPedestalModule:AddListeners()
	self:AddListener(CourtYardEvent.UPDATE_STOREY, self.OnUpdate)
end

function CourtYardReversePacmanPedestalModule:RemoveListeners()
	self:RemoveListener(CourtYardEvent.UPDATE_STOREY, self.OnUpdate)
end

function CourtYardReversePacmanPedestalModule:OnUpdate(arg_4_1)
	self.level = arg_4_1

	self:InitScrollRect(arg_4_1)
end

function CourtYardReversePacmanPedestalModule:InitScrollRect(arg_5_1)
	self._tf.sizeDelta = Vector2(self._tf.sizeDelta.x, 1080 + (arg_5_1 - 1) * 150)

	scrollTo(self.scrollView, 0.5, 0.5)
end

function CourtYardReversePacmanPedestalModule:OnDispose()
	return
end

return CourtYardReversePacmanPedestalModule
