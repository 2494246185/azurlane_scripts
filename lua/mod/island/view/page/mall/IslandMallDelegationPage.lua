local IslandMallDelegationPage = class("IslandMallDelegationPage", import("Mod.Island.View.page.building.IslandRoleDelegationPage"))

function IslandMallDelegationPage:getUIName()
	return "IslandMallDelegationUI"
end

function IslandMallDelegationPage:OnInit()
	IslandMallDelegationPage.super.OnInit(self)
	onButton(self, self._tf:Find("adapt/handbookBtn"), function()
		self:OpenPage(IslandSetMealHandbookPage)
	end)
	setActive(self._tf:Find("adapt/handbookBtn"), getProxy(IslandProxy):GetIsland():GetAblityAgency():HasAbility(29001))
end

return IslandMallDelegationPage
