local NcClickObject = class("NcClickObject", import("..base.NodeCanvasBaseTask"))

function NcClickObject:OnExecute()
	function NcClickObject.Click(arg_2_0)
		self:EndAction()
	end

	self:GetRouter().onMouseDown = self:GetRouter().onMouseDown + NcClickObject.Click
end

function NcClickObject:OnStop()
	if NcClickObject.Click then
		self:GetRouter().onMouseDown = self:GetRouter().onMouseDown - NcClickObject.Click
		NcClickObject.Click = nil
	end
end

return NcClickObject
