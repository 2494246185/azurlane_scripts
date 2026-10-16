local IDOLMMainPage = class("IDOLMMainPage", import(".TemplatePage.PreviewTemplatePage"))

function IDOLMMainPage:OnFirstFlush()
	IDOLMMainPage.super.OnFirstFlush(self)

	self.mountainBtn = self.btnList:Find("mountain")

	onButton(self, self.mountainBtn, function()
		pg.m02:sendNotification(GAME.GO_SCENE, SCENE.IMAS_STAGE)
	end, SFX_PANEL)
end

return IDOLMMainPage
