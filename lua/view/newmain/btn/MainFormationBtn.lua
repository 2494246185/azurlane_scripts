local MainFormationBtn = class("MainFormationBtn", import(".MainBaseBtn"))

function MainFormationBtn:OnClick()
	self:emit(NewMainMediator.GO_SCENE, SCENE.BIANDUI, {
		fleetId = 1
	})
end

function MainFormationBtn:IsFixed()
	return true
end

return MainFormationBtn
