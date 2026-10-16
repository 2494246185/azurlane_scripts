local DoaMainRePage = class("DoaMainRePage", import(".TemplatePage.PreviewTemplatePage"))

function DoaMainRePage:OnInit()
	DoaMainRePage.super.OnInit(self)

	self.charactorTf = self.bg:Find("charactor")
end

function DoaMainRePage:OnFirstFlush()
	DoaMainRePage.super.OnFirstFlush(self)
	onButton(self, self.bg:Find("btnMiniGame"), function()
		self:emit(ActivityMediator.EVENT_GO_SCENE, SCENE.LEVEL)
	end)
end

function DoaMainRePage:OnUpdateFlush()
	local var_4_0 = math.random(1, 9)

	for iter_4_0 = 1, 9 do
		setActive(findTF(self.charactorTf, "charactor" .. iter_4_0), var_4_0 == iter_4_0)
	end
end

return DoaMainRePage
