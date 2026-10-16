local MainCollectionBtn = class("MainCollectionBtn", import(".MainBaseBtn"))

function MainCollectionBtn:OnClick()
	self:emit(NewMainMediator.GO_SCENE, SCENE.COLLECTSHIP)
end

return MainCollectionBtn
