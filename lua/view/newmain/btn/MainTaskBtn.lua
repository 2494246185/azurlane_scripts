local MainTaskBtn = class("MainTaskBtn", import(".MainBaseBtn"))

function MainTaskBtn:OnClick()
	self:emit(NewMainMediator.GO_SCENE, SCENE.TASK)
end

return MainTaskBtn
