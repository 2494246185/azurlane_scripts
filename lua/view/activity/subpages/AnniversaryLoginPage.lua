local AnniversaryLoginPage = class("AnniversaryLoginPage", import(".TemplatePage.LoginTemplatePage"))

function AnniversaryLoginPage:OnInit()
	self.bg = self._tf:Find("AD")
	self.item = self.bg:Find("item")
	self.items = self.bg:Find("mask/items")
	self.itemList = UIItemList.New(self.items, self.item)
end

function AnniversaryLoginPage:OnUpdateFlush()
	AnniversaryLoginPage.super.OnUpdateFlush(self)
	eachChild(self.items, function(arg_3_0)
		setText(arg_3_0:Find("day/Text"), arg_3_0:GetSiblingIndex() + 1)
	end)
end

return AnniversaryLoginPage
