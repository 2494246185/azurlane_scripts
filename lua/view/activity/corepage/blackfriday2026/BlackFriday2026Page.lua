local BlackFriday2026Page = class("BlackFriday2026Page", import("view.activity.CorePage.PSS.PSSHei5Page"))

function BlackFriday2026Page:OnFirstFlush()
	BlackFriday2026Page.super.OnFirstFlush(self)
	onButton(self, self.btn, function()
		self:emit(ActivityMediator.OPEN_LAYER, Context.New({
			mediator = BlackFriday2026Mediator,
			viewComponent = BlackFriday2026Scene
		}))
	end, SOUND_BACK)
end

return BlackFriday2026Page
