local MainMailBtn = class("MainMailBtn", import(".MainBaseBtn"))

function MainMailBtn:OnClick()
	self:emit(NewMainMediator.OPEN_MAIL)
end

return MainMailBtn
