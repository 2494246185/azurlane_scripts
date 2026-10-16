local AgoraDecorationSortPage = class("AgoraDecorationSortPage", import("view.base.BaseSubView"))

function AgoraDecorationSortPage:getUIName()
	return "IslandAgoraDecSortUI"
end

function AgoraDecorationSortPage:OnLoaded()
	self.sortUIItemList = UIItemList.New(self._tf:Find("frame"), self._tf:Find("frame/tpl"))
end

function AgoraDecorationSortPage:OnInit()
	onButton(self, self._tf, function()
		self:Hide()
	end, SFX_PANEL)
end

function AgoraDecorationSortPage:Show(arg_5_1, arg_5_2)
	AgoraDecorationSortPage.super.Show(self)

	self.indexData = arg_5_1
	self.callback = arg_5_2

	self:InitList()
end

function AgoraDecorationSortPage:InitList()
	self.sortUIItemList:make(function(arg_7_0, arg_7_1, arg_7_2)
		if arg_7_0 == UIItemList.EventUpdate then
			local var_7_0 = AgoraFurnitureType.SORT_LIST[arg_7_1 + 1]

			setText(arg_7_2:Find("Text"), setColorStr(AgoraFurnitureType.Sort2CN(AgoraFurnitureType.SORT_LIST[arg_7_1 + 1]), self.indexData.sortKey == AgoraFurnitureType.SORT_LIST[arg_7_1 + 1] and "#393a3c" or "#7c7e81"))
			onButton(self, arg_7_2, function()
				if self.callback then
					self.callback(var_7_0)
				end

				self:Hide()
			end, SFX_PANEL)
		end
	end)
	self.sortUIItemList:align(#AgoraFurnitureType.SORT_LIST)
end

function AgoraDecorationSortPage:Hide()
	AgoraDecorationSortPage.super.Hide(self)

	self.callback = nil
end

function AgoraDecorationSortPage:OnDestroy()
	if self:isShowing() then
		self:Hide()
	end
end

return AgoraDecorationSortPage
