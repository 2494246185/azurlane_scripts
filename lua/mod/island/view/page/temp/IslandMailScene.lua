local IslandMailScene = class("IslandMailScene", import("view.main.Mail.MailScene"))

function IslandMailScene:didEnter()
	IslandMailScene.super.didEnter(self)
	onNextTick(function()
		self:ExtraHandle()
	end)
end

function IslandMailScene:ExtraHandle()
	setActive(self._tf:Find("adapt/top/res"), false)
	setActive(self._tf:Find("adapt/top/option"), false)
	setActive(self._tf:Find("adapt/left_length/frame/tagRoot/store"), false)
	setActive(self._tf:Find("adapt/left_length/frame/tagRoot/collection"), false)
end

function IslandMailScene:closeView()
	self.contextData.onClose()
end

function IslandMailScene:onBackPressed()
	return
end

return IslandMailScene
