local WorkBenchItemDetailLayer = class("WorkBenchItemDetailLayer", import("view.base.BaseUI"))

function WorkBenchItemDetailLayer:getUIName()
	return "WorkBenchItemDetailLayer"
end

function WorkBenchItemDetailLayer:init()
	self.loader = AutoLoader.New()
end

function WorkBenchItemDetailLayer:didEnter()
	onButton(self, self._tf:Find("BG"), function()
		self:onBackPressed()
	end, SFX_CANCEL)
	onButton(self, self._tf:Find("Window/Close"), function()
		self:onBackPressed()
	end, SFX_CANCEL)
	self:UpdateItemDetail()
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
end

function WorkBenchItemDetailLayer:UpdateItemDetail()
	local var_6_0 = self.contextData.material

	self:UpdateItem(self._tf:Find("Window/IconBG"), self.contextData.material)
	setText(self._tf:Find("Window/Name"), var_6_0:GetName())
	setText(self._tf:Find("Window/Description/Text"), var_6_0:GetDesc())
	setText(self._tf:Find("Window/Source"), var_6_0:GetSource()[1] or "")
	onButton(self, self._tf:Find("Window/Go"), function()
		self:emit(GAME.WORKBENCH_ITEM_GO, var_6_0:GetConfigID())
	end, SFX_PANEL)
	setActive(self._tf:Find("Window/Go"), table.getCount(var_6_0:GetSource()) > 1)
end

local var_0_1 = "ui/AtelierCommonUI_atlas"

function WorkBenchItemDetailLayer:UpdateItem(arg_8_1, arg_8_2)
	self.loader:GetSpriteQuiet(var_0_1, "icon_frame_" .. arg_8_2:GetRarity(), arg_8_1)
	self.loader:GetSpriteQuiet(arg_8_2:GetIconPath(), "", arg_8_1:Find("Icon"))

	if not IsNil(arg_8_1:Find("Text")) then
		setText(arg_8_1:Find("Text"), arg_8_2.count)
	end
end

function WorkBenchItemDetailLayer:willExit()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)
	self.loader:Clear()
end

return WorkBenchItemDetailLayer
