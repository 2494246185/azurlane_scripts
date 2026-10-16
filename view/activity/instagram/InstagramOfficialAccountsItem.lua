local InstagramOfficialAccountsItem = class("InstagramOfficialAccountsItem", import("view.base.BasePanel"))

function InstagramOfficialAccountsItem:Ctor(arg_1_1, arg_1_2)
	self._go = arg_1_1.gameObject

	InstagramOfficialAccountsItem.super.Ctor(self, self._go)

	self._parentClass = arg_1_2

	self:attach(arg_1_2)
	self:Init()
end

function InstagramOfficialAccountsItem:Init()
	self.uiTip = self._tf:Find("tip")
	self.uiNameText = self._tf:Find("name")
end

function InstagramOfficialAccountsItem:SetData(arg_3_1)
	self.id = arg_3_1

	self:RefreshUI()
end

function InstagramOfficialAccountsItem:RefreshUI()
	setText(self.uiNameText, shortenString(getProxy(InstagramProxy):GetOfficialAccounts()[self.id]:getConfig("title"), 26))
	self:RefreshTip()
end

function InstagramOfficialAccountsItem:RefreshTip()
	local var_5_0 = getProxy(InstagramProxy):GetOfficialAccounts()[self.id]

	if var_5_0 then
		setActive(self.uiTip, var_5_0:ShouldShowTip())
	end
end

function InstagramOfficialAccountsItem:willExit()
	self:detach()
end

return InstagramOfficialAccountsItem
