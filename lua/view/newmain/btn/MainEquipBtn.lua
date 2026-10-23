local MainEquipBtn = class("MainEquipBtn", import(".MainBaseBtn"))

function MainEquipBtn:OnClick()
	self:emit(NewMainMediator.GO_SCENE, SCENE.EQUIPSCENE)
end

return MainEquipBtn
