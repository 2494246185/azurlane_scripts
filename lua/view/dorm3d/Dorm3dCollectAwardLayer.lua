local Dorm3dCollectAwardLayer = class("Dorm3dCollectAwardLayer", import("view.base.BaseUI"))

function Dorm3dCollectAwardLayer:getUIName()
	return "Dorm3dCollectAwardUI"
end

function Dorm3dCollectAwardLayer:getResource()
	local var_2_0 = Dorm3dCollectAwardLayer.super.getResource(self)

	table.insert(var_2_0, "dorm3dcollection/" .. pg.dorm3d_collection_template[self.contextData.itemId].icon)

	return var_2_0
end

function Dorm3dCollectAwardLayer:preload(arg_3_1)
	GetSpriteFromAtlasAsync("dorm3dcollection/" .. pg.dorm3d_collection_template[self.contextData.itemId].icon, "", function(arg_4_0)
		self.iconSprite = arg_4_0

		arg_3_1()
	end)
end

function Dorm3dCollectAwardLayer:init()
	onButton(self, self._tf:Find("bg"), function()
		if self.isBlock then
			return
		end

		self:closeView()
	end, SFX_CANCEL)

	self.isBlock = true

	pg.UIMgr.GetInstance():BlurPanel(self._tf)
end

function Dorm3dCollectAwardLayer:onBackPressed()
	if self.isBlock then
		return
	end

	Dorm3dCollectAwardLayer.super.onBackPressed(self)
end

function Dorm3dCollectAwardLayer:didEnter()
	local var_8_0 = pg.dorm3d_collection_template[self.contextData.itemId]

	setText(self._tf:Find("panel/name/Text"), pg.dorm3d_collection_template[self.contextData.itemId].name)
	setText(self._tf:Find("panel/desc/content/desc"), var_8_0.desc)

	if var_8_0.award > 0 then
		setText(self._tf:Find("panel/favor/Text"), i18n("dorm3d_collect_favor_plus") .. pg.dorm3d_favor_trigger[var_8_0.award].num)
		setActive(self._tf:Find("panel/favor"), self.contextData.isNew)
	else
		setActive(self._tf:Find("panel/favor"), false)
	end

	setImageSprite(self._tf:Find("panel/icon"), GetSpriteFromAtlas("dorm3dcollection/" .. var_8_0.icon, ""), true)
	LeanTween.delayedCall(1.5, System.Action(function()
		self.isBlock = false
	end))
end

function Dorm3dCollectAwardLayer:willExit()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)
end

return Dorm3dCollectAwardLayer
