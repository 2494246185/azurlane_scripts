local MainEducateCharIcon = class("MainEducateCharIcon", import(".MainBaseIcon"))

function MainEducateCharIcon:Ctor(arg_1_1)
	MainEducateCharIcon.super.Ctor(self, arg_1_1)

	self.iconTr = arg_1_1:Find("icon")
	self.iconImg = self.iconTr:GetComponent(typeof(Image))
end

function MainEducateCharIcon:Load(arg_2_1)
	setActive(self.iconTr, true)
	GetImageSpriteFromAtlasAsync("SquareIcon/" .. arg_2_1, "", self.iconTr, true)
end

function MainEducateCharIcon:Unload()
	setActive(self.iconTr, false)

	self.iconImg.sprite = nil
end

return MainEducateCharIcon
