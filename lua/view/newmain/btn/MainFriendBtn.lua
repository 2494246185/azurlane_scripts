local MainFriendBtn = class("MainFriendBtn", import(".MainBaseBtn"))

function MainFriendBtn:OnClick()
	self:emit(NewMainMediator.GO_SCENE, SCENE.FRIEND)
end

return MainFriendBtn
