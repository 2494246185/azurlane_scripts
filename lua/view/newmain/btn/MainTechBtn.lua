local MainTechBtn = class("MainTechBtn", import(".MainBaseBtn"))

function MainTechBtn:OnClick()
	self:emit(NewMainMediator.GO_SCENE, SCENE.SELTECHNOLOGY)
end

return MainTechBtn
