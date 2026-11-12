local MainBuildBtn = class("MainBuildBtn", import(".MainBaseBtn"))

function MainBuildBtn:OnClick()
	self:emit(NewMainMediator.GO_SCENE, SCENE.GETBOAT)
end

return MainBuildBtn
