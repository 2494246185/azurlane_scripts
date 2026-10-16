local DoaMainPage = class("DoaMainPage", import(".TemplatePage.PreviewTemplatePage"))

function DoaMainPage:OnInit()
	DoaMainPage.super.OnInit(self)

	self.charactorTf = self.bg:Find("charactor")
end

function DoaMainPage:OnFirstFlush()
	DoaMainPage.super.OnFirstFlush(self)
	onButton(self, self.bg:Find("btnMiniGame"), function()
		self:emit(ActivityMediator.EVENT_GO_SCENE, SCENE.DOALINK_ISLAND)
	end)
end

function DoaMainPage:OnUpdateFlush()
	local var_4_0 = math.random(1, 9)

	for iter_4_0 = 1, 9 do
		setActive(findTF(self.charactorTf, "charactor" .. iter_4_0), var_4_0 == iter_4_0)
	end
end

return DoaMainPage
