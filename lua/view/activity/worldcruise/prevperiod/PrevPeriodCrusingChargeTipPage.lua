local PrevPeriodCrusingChargeTipPage = class("PrevPeriodCrusingChargeTipPage", import("view.base.BaseSubView"))

function PrevPeriodCrusingChargeTipPage:getUIName()
	return "PrevPeriodCrusingChargeTipPage"
end

function PrevPeriodCrusingChargeTipPage:OnLoaded()
	self.closeBtn = self._tf:Find("close")
	self.shopBtn = self._tf:Find("shop")
	self.awardPage = WorldCruiseAwardPage4PrevPeriod.New(self._tf)
	self.chargePage = WorldCruiseChargePage4PrevPeriod.New(self._tf)
end

function PrevPeriodCrusingChargeTipPage:OnInit()
	onButton(self, self.closeBtn, function()
		self:Destroy()
	end, SFX_CANCEL)
	onButton(self, self.shopBtn, function()
		self.onClose = nil

		self.chargePage:ExecuteAction("ShowBuyWindow")
	end, SFX_CONFIRM)
end

function PrevPeriodCrusingChargeTipPage:Show(arg_6_1)
	pg.UIMgr.GetInstance():BlurPanel(self._tf)

	self.onClose = arg_6_1

	self.awardPage:ExecuteAction("Flush")
end

function PrevPeriodCrusingChargeTipPage:OnChargeScene(arg_7_1, arg_7_2)
	self.chargePage:ExecuteAction("ShowUnlockWindow", arg_7_1, arg_7_2)
end

function PrevPeriodCrusingChargeTipPage:Hide()
	PrevPeriodCrusingChargeTipPage.super.Hide(self)
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)

	if self.awardPage and self.awardPage:GetLoaded() then
		self.awardPage:OnDestroy()
	end

	self.awardPage = nil

	if self.chargePage and self.chargePage:GetLoaded() then
		self.chargePage:OnDestroy()
	end

	self.chargePage = nil

	if self.onClose then
		self.onClose()

		self.onClose = nil
	end
end

function PrevPeriodCrusingChargeTipPage:OnDestroy()
	if self:isShowing() then
		self:Hide()
	end
end

return PrevPeriodCrusingChargeTipPage
