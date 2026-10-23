local ShadowCityMainPage = class("ShadowCityMainPage", import("view.activity.CorePage.Helena.HelenaMainPage"))

function ShadowCityMainPage:OnInit()
	ShadowCityMainPage.super.OnInit(self)

	self.rpManual = self.Manual:Find("tip")
end

function ShadowCityMainPage:OnFirstFlush()
	ShadowCityMainPage.super.OnFirstFlush(self)
	onButton(self, self.Manual, function()
		self:emit(ActivityMediator.ON_ADD_SUBLAYER, (Context.New({
			mediator = MedalAlbumTemplateMediator,
			viewComponent = ShadowCityMedalAlbumView
		})))
	end)
end

function ShadowCityMainPage:OnUpdateFlush()
	ShadowCityMainPage.super.OnUpdateFlush(self)
	self:updateTip()
end

function ShadowCityMainPage:updateTip()
	setActive(self.rpManual, (getProxy(ActivityProxy):getActivityById(self.activity:getConfig("config_client").medalGroupId):readyToAchieve()))
end

return ShadowCityMainPage
