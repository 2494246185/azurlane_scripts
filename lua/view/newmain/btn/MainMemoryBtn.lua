local MainMemoryBtn = class("MainMemoryBtn", import(".MainBaseBtn"))

function MainMemoryBtn:OnClick()
	self:emit(NewMainMediator.GO_SCENE, SCENE.MEDIA_COLLECTION_ENTRANCE)
end

return MainMemoryBtn
