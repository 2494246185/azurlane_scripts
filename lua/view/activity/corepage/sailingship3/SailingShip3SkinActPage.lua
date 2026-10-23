local SailingShip3SkinActPage = class("SailingShip3SkinActPage", import("view.activity.CorePage.CorePreviewTemplatePage"))

function SailingShip3SkinActPage:OnFirstFlush()
	self.super.OnFirstFlush(self)
	onButton(self, self.btnList:Find("activity"), function()
		self:emit(ActivityMediator.OPEN_LAYER, Context.New({
			mediator = SailingShip3SkinMediator,
			viewComponent = SailingShip3SkinLayer
		}))
	end)
end

function SailingShip3SkinActPage:OnUpdateFlush()
	setActive(self._tf:Find("AD/redDot"), SailingShip3SkinLayer.ShouldShowTip())
end

return SailingShip3SkinActPage
