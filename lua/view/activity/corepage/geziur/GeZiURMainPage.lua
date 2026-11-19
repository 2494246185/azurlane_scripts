local GeZiURMainPage = class("GeZiURMainPage", import("view.activity.CorePage.Helena.HelenaMainPage"))

function GeZiURMainPage:OnFirstFlush()
	GeZiURMainPage.super.OnFirstFlush(self)
	onButton(self, self.Manual, function()
		self:emit(ActivityMediator.ON_ADD_SUBLAYER, (Context.New({
			mediator = MedalAlbumTemplateMediator,
			viewComponent = GeZiMedalAlbumView
		})))
	end)
end

return GeZiURMainPage
