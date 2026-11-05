local NcPlayGuide = class("NcPlayGuide", import("..base.NodeCanvasBaseTask"))

function NcPlayGuide:OnExecute()
	pg.NewGuideMgr.GetInstance():Play(self:GetStringArg("guide"), {}, function()
		self:EndAction()
	end, nil)
end

return NcPlayGuide
