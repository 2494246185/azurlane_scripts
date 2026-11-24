local VeritasAcademyMainPage = class("VeritasAcademyMainPage", import("view.activity.CorePage.Helena.HelenaMainPage"))

function VeritasAcademyMainPage:OnInit()
	self.super.OnInit(self)

	self.rpManual = self.Manual:Find("tip")
end

function VeritasAcademyMainPage:OnFirstFlush()
	VeritasAcademyMainPage.super.OnFirstFlush(self)
	removeOnButton(self.Manual)
	onButton(self, self.Manual, function()
		self:emit(ActivityMediator.ON_ADD_SUBLAYER, (Context.New({
			mediator = MedalAlbumTemplateMediator,
			viewComponent = self:GetMedalAlbumView()
		})))
	end)
end

function VeritasAcademyMainPage:updateUI()
	VeritasAcademyMainPage.super.updateUI(self)
	removeOnButton(self.fight)
	onButton(self, self.fight, function()
		self:emit(ActivityMediator.ON_BOSSRUSH_MAP)
	end)
end

function VeritasAcademyMainPage:GetMedalAlbumView()
	return VeritasAcademyMedalAlbumView
end

return VeritasAcademyMainPage
