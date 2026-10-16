local AnniversaryIslandStoreHouse2023Window = class("AnniversaryIslandStoreHouse2023Window", import("view.base.BaseUI"))

function AnniversaryIslandStoreHouse2023Window:Ctor()
	AnniversaryIslandStoreHouse2023Window.super.Ctor(self)

	self.loader = AutoLoader.New()
end

function AnniversaryIslandStoreHouse2023Window:getUIName()
	return "AnniversaryIslandStoreHouse2023Window"
end

local var_0_1 = "ui/AtelierCommonUI_atlas"

function AnniversaryIslandStoreHouse2023Window:getResource()
	local var_3_0 = AnniversaryIslandStoreHouse2023Window.super.getResource(self)

	table.insert(var_3_0, var_0_1)

	return var_3_0
end

function AnniversaryIslandStoreHouse2023Window:preload(arg_4_1)
	table.ParallelIpairsAsync({
		var_0_1
	}, function(arg_5_0, arg_5_1, arg_5_2)
		self.loader:LoadBundle(arg_5_1, arg_5_2)
	end, arg_4_1)
end

function AnniversaryIslandStoreHouse2023Window:init()
	self.storehouseRect = self._tf:Find("Window/ScrollView"):GetComponent("LScrollRect")

	setActive(self._tf:Find("Window/ScrollView/Item"), false)
end

function AnniversaryIslandStoreHouse2023Window:SetActivity(arg_7_1)
	self.items = arg_7_1:GetAllVitems()
	self.itemList = {}

	table.Foreach(self.items, function(arg_8_0, arg_8_1)
		if arg_8_1 <= 0 then
			return
		end

		table.insert(self.itemList, WorkBenchItem.New({
			configId = arg_8_0,
			count = arg_8_1
		}))
	end)
	table.sort(self.itemList, function(arg_9_0, arg_9_1)
		return arg_9_0:GetConfigID() < arg_9_1:GetConfigID()
	end)
end

function AnniversaryIslandStoreHouse2023Window:didEnter()
	function self.storehouseRect.onUpdateItem(arg_11_0, arg_11_1)
		arg_11_0 = arg_11_0 + 1

		local var_11_0 = tf(arg_11_1)
		local var_11_1 = self.itemList[arg_11_0]

		self:UpdateItem(var_11_0:Find("IconBG"), self.itemList[arg_11_0])
		setScrollText(var_11_0:Find("NameBG/Rect/Name"), self.itemList[arg_11_0]:GetName())
		onButton(self, var_11_0, function()
			self:emit(WorkBenchItemDetailMediator.SHOW_DETAIL, var_11_1)
		end, SFX_PANEL)
	end

	onButton(self, self._tf:Find("Window/Close"), function()
		self:onBackPressed()
	end, SFX_CANCEL)
	onButton(self, self._tf:Find("BG"), function()
		self:onBackPressed()
	end)
	self:UpdateView()
end

function AnniversaryIslandStoreHouse2023Window:UpdateView()
	setActive(self._tf:Find("Window/Empty"), #self.itemList == 0)
	setActive(self._tf:Find("Window/ScrollView"), #self.itemList > 0)
	self.storehouseRect:SetTotalCount(#self.itemList)
end

function AnniversaryIslandStoreHouse2023Window:UpdateItem(arg_16_1, arg_16_2)
	self.loader:GetSpriteQuiet(var_0_1, "icon_frame_" .. arg_16_2:GetRarity(), arg_16_1)
	self.loader:GetSpriteQuiet(arg_16_2:GetIconPath(), "", arg_16_1:Find("Icon"))

	if not IsNil(arg_16_1:Find("Text")) then
		setText(arg_16_1:Find("Text"), arg_16_2.count)
	end
end

function AnniversaryIslandStoreHouse2023Window:willExit()
	self.loader:Clear()
end

return AnniversaryIslandStoreHouse2023Window
