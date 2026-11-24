local IslandActivitySpecialOrderS5Page = class("IslandActivitySpecialOrderS5Page", import(".IslandActivitySpecialOrderPage"))

function IslandActivitySpecialOrderS5Page:getTabTipMapList()
	return {
		{
			"island_spoperation_btn_2611_2",
			"island_spoperation_tip_2611_3"
		},
		{
			"island_spoperation_btn_2611_1",
			"island_spoperation_tip_2611_2"
		},
		{
			"island_spoperation_btn_2611_3",
			"island_spoperation_tip_2611_1"
		}
	}
end

function IslandActivitySpecialOrderS5Page:getItemTipPrefix()
	return "island_spoperation_item_2611_"
end

function IslandActivitySpecialOrderS5Page:OnFirstFlush()
	IslandActivitySpecialOrderS5Page.super.OnFirstFlush(self)
	setActive(self.rtTitle:Find("level"), false)
end

function IslandActivitySpecialOrderS5Page:OnShowFlush()
	quickPlayAnimation(self._tf, "Anim_IslandActivitySpecialOrderS5Page_in")
	triggerToggle(self.rtTabs:GetChild((self.index or 1) - 1), true)
end

return IslandActivitySpecialOrderS5Page
