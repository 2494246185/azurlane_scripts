local BlackFriday2026Scene = class("BlackFriday2026Scene", import("view.activity.CorePage.PSS.Hei5.PSSHei5Scene"))

function BlackFriday2026Scene:getUIName()
	return "BlackFriday2026UI"
end

function BlackFriday2026Scene:initTplVar()
	BlackFriday2026Scene.super.initTplVar(self)

	self.awardPageCls = BlackFriday2026AwardPage
	self.taskPageCls = BlackFriday2026TaskPage
	self.chargePageCls = BlackFriday2026ChargePage
end

return BlackFriday2026Scene
