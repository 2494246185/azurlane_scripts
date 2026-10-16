local CombatPreviewLayer = class("CombatPreviewLayer", import("view.base.BaseSubView"))
local var_0_3 = Vector3(0, 1, 40)

function CombatPreviewLayer:getUIName()
	return "CombatPreviewUI"
end

function CombatPreviewLayer.PushAllResource()
	local var_2_0 = {}

	local function var_2_1(arg_3_0)
		if noEmptyStr(arg_3_0) and not table.contains(var_2_0, arg_3_0) then
			table.insert(var_2_0, arg_3_0)
		end
	end

	for iter_2_0, iter_2_1 in ipairs(pg.item_data_battleui.all) do
		if pg.item_data_battleui[iter_2_1] and noEmptyStr(pg.item_data_battleui[iter_2_1].key) then
			var_2_1("ui/CombatUI" .. pg.item_data_battleui[iter_2_1].key)
			var_2_1("ui/CombatHPBar" .. pg.item_data_battleui[iter_2_1].key)
			var_2_1(ys.Battle.BattleResourceManager.GetUIPath("CombatHPPop" .. pg.item_data_battleui[iter_2_1].key))
		end
	end

	return var_2_0
end

function CombatPreviewLayer:OnInit()
	self.OverlayMain = pg.UIMgr.GetInstance().OverlayMain

	setParent(self._go, self.OverlayMain)
	pg.UIMgr.GetInstance():BlurPanel(self._tf)

	self.preview = self._tf:Find("preview")
	self.uiLayer = self._tf:Find("preview/ui")
	self.sea = self._tf:Find("preview/sea")
	self.rawImage = self.sea:GetComponent("RawImage")

	setText(self.preview:Find("bg/title/Image"), i18n("word_preview"))
	onButton(self, self.preview, function()
		self.callBack()
	end, SFX_PANEL)
end

function CombatPreviewLayer:Show(arg_6_1, arg_6_2)
	self.callBack = arg_6_2

	local var_6_0 = pg.item_data_battleui[arg_6_1].key
	local var_6_1 = "CombatUI" .. pg.item_data_battleui[arg_6_1].key
	local var_6_2 = "CombatHPBar" .. pg.item_data_battleui[arg_6_1].key
	local var_6_3
	local var_6_4
	local var_6_5

	seriesAsync({
		function(arg_7_0)
			PoolMgr.GetInstance():GetUI(var_6_2, true, function(arg_8_0)
				var_6_4 = arg_8_0

				arg_7_0()
			end)
		end,
		function(arg_9_0)
			PoolMgr.GetInstance():GetUI(var_6_2, true, function(arg_10_0)
				var_6_5 = arg_10_0

				arg_9_0()
			end)
		end,
		function(arg_11_0)
			PoolMgr.GetInstance():GetUI(var_6_1, true, function(arg_12_0)
				var_6_3 = arg_12_0

				arg_11_0()
			end)
		end
	}, function()
		var_6_3.transform:SetParent(self.uiLayer, false)
		var_6_4.transform:SetParent(self.uiLayer, false)
		var_6_5.transform:SetParent(self.uiLayer, false)

		var_6_3.transform.localScale = Vector3(self.sea.rect.width / 1920, self.sea.rect.height / 1080, 1)
		self.previewer = CombatUIPreviewer.New(self.rawImage)

		self.previewer:setDisplayWeapon({
			100
		})
		self.previewer:setCombatUI(var_6_3, var_6_4, var_6_5, var_6_0)
		self.previewer:load(40000, Ship.New({
			id = 100001,
			configId = 100001,
			skin_id = 100000
		}), Ship.New({
			id = 100011,
			configId = 100011,
			skin_id = 100010
		}), {}, function()
			return
		end)
	end)
end

function CombatPreviewLayer:OnDestroy()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)

	if self.previewer then
		self.previewer:clear()

		self.previewer = nil
	end
end

return CombatPreviewLayer
