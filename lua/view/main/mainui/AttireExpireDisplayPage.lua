local AttireExpireDisplayPage = class("AttireExpireDisplayPage", import("...base.BaseSubView"))

function AttireExpireDisplayPage:getUIName()
	return "AttireOverDueUI"
end

function AttireExpireDisplayPage:OnLoaded()
	self.uilist = UIItemList.New(self._tf:Find("window/sliders/scrollrect/content"), self._tf:Find("window/sliders/scrollrect/content/tpl"))
end

function AttireExpireDisplayPage:OnInit()
	onButton(self, self._tf:Find("window/confirm_btn"), function()
		self:Hide()
	end, SFX_CANCEL)
	onButton(self, self._tf, function()
		self:Hide()
	end, SFX_CANCEL)
	onButton(self, self._tf:Find("window/top/btnBack"), function()
		self:Hide()
	end, SFX_CANCEL)
end

function AttireExpireDisplayPage:Show(arg_7_1)
	AttireExpireDisplayPage.super.Show(self)
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
	self:Display(arg_7_1)
end

function AttireExpireDisplayPage:Display(arg_8_1)
	self.uilist:make(function(arg_9_0, arg_9_1, arg_9_2)
		if arg_9_0 == UIItemList.EventUpdate then
			updateDrop(arg_9_2, {
				count = 1,
				id = arg_8_1[arg_9_1 + 1]:getConfig("id"),
				type = arg_8_1[arg_9_1 + 1]:getDropType()
			})
		end
	end)
	self.uilist:align(#arg_8_1)
end

function AttireExpireDisplayPage:OnDestroy()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, pg.UIMgr.GetInstance()._normalUIMain)
end

return AttireExpireDisplayPage
