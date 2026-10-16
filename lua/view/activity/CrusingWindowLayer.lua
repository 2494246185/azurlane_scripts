local CrusingWindowLayer = class("CrusingWindowLayer", import("view.base.BaseUI"))

function CrusingWindowLayer:getUIName()
	return "CrusingWindowUI"
end

function CrusingWindowLayer:preload(arg_2_1)
	GetSpriteFromAtlasAsync("crusingwindow/map_20" .. pg.battlepass_event_pt[getProxy(ActivityProxy):getAliveActivityByType(ActivityConst.ACTIVITY_TYPE_PT_CRUSING).id].map_name, "", function(arg_3_0)
		self.windowSprite = arg_3_0

		arg_2_1()
	end)
end

function CrusingWindowLayer:getResource()
	local var_4_0 = CrusingWindowLayer.super.getResource(self)

	for iter_4_0, iter_4_1 in ipairs({
		"crusingwindow"
	} or {}) do
		if not table.contains(var_4_0, iter_4_1) then
			table.insert(var_4_0, iter_4_1)
		end
	end

	return var_4_0
end

function CrusingWindowLayer:init()
	setImageSprite(self._tf:Find("panel"), self.windowSprite, true)

	self.rtBg = self._tf:Find("bg")
	self.btnBack = self._tf:Find("panel/btn_back")
	self.btnGo = self._tf:Find("panel/btn_go")
	self.itemContent = self._tf:Find("panel/content")

	local var_5_0 = pg.battlepass_event_pt[getProxy(ActivityProxy):getAliveActivityByType(ActivityConst.ACTIVITY_TYPE_PT_CRUSING).id].equip_skin or {}

	self.itemList = UIItemList.New(self.itemContent, self.itemContent:GetChild(0))

	self.itemList:make(function(arg_6_0, arg_6_1, arg_6_2)
		arg_6_1 = arg_6_1 + 1

		if arg_6_0 == UIItemList.EventUpdate then
			local var_6_0 = {}

			var_6_0.type, var_6_0.id, var_6_0.count = unpack(var_5_0[arg_6_1])

			updateDrop(arg_6_2, var_6_0)
			onButton(self, arg_6_2, function()
				self:emit(CrusingWindowLayer.ON_DROP, var_6_0)
			end, SFX_PANEL)
		end
	end)
	self.itemList:align(#var_5_0)
end

function CrusingWindowLayer:didEnter()
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
	onButton(self, self.rtBg, function()
		self:closeView()
	end, SFX_CANCEL)
	onButton(self, self.btnBack, function()
		self:closeView()
	end, SFX_CANCEL)
	onButton(self, self.btnGo, function()
		self:emit(CrusingWindowMediator.GO_CRUSING)
	end, SFX_CONFIRM)
end

function CrusingWindowLayer:willExit()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)
end

return CrusingWindowLayer
