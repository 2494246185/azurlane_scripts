local CourtYardFollowInteraction = class("CourtYardFollowInteraction", import(".CourtYardInteraction"))

function CourtYardFollowInteraction:OnStepEnd()
	if self:IsCompleteOwnerStep() then
		self:DoStep()
	end
end

return CourtYardFollowInteraction
