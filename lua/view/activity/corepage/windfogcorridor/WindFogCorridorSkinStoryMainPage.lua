local WindFogCorridorSkinStoryMainPage = class("WindFogCorridorSkinStoryMainPage", import("view.activity.CorePage.CoreActivityPage"))

function WindFogCorridorSkinStoryMainPage:OnInit()
	self.AD = self._tf:Find("AD")
	self.btnGo = self.AD:Find("go")
	self.redPoint = self.btnGo:Find("red")
	self.btnShop = self.AD:Find("shop")
end

function WindFogCorridorSkinStoryMainPage:OnFirstFlush()
	onButton(self, self.btnGo, function()
		self:emit(ActivityMediator.EVENT_GO_SCENE, SCENE.WINDFOGSKINPAGE)
	end)
	onButton(self, self.btnShop, function()
		self:emit(ActivityMediator.GO_CHANGE_SHOP)
	end)
	self:refreshRed()
end

function WindFogCorridorSkinStoryMainPage:OnUpdateFlush()
	self:refreshRed()
end

function WindFogCorridorSkinStoryMainPage:refreshRed()
	setActive(self.redPoint, self.activity:readyToAchieve())
end

return WindFogCorridorSkinStoryMainPage
