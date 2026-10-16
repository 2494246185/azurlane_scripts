local LevelStrategyView = class("LevelStrategyView", import("..base.BaseSubView"))

function LevelStrategyView:getUIName()
	return "LevelStrategyView"
end

function LevelStrategyView:downloadLevelStrategyRes(arg_2_1, arg_2_2)
	local var_2_0 = pg.strategy_data_template[arg_2_1.id]
	local var_2_1 = {}

	if pg.strategy_data_template[arg_2_1.id] and noEmptyStr(pg.strategy_data_template[arg_2_1.id].icon) then
		table.insert(var_2_1, (ResPathSupport.CombinePath(ResPathSupport.ConstPath.StrategyIcon, pg.strategy_data_template[arg_2_1.id].icon)))
	end

	SplitPackConst.DownloadByLuaArr(var_2_1, function()
		if self._state == LevelStrategyView.STATES.DESTROY then
			return
		end

		arg_2_2(var_2_0)
	end)
end

function LevelStrategyView:OnInit()
	self:InitUI()
	setActive(self._tf, true)
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
end

function LevelStrategyView:OnDestroy()
	self.onConfirm = nil
	self.onCancel = nil

	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, self._parentTf)
end

function LevelStrategyView:setCBFunc(arg_6_1, arg_6_2)
	self.onConfirm = arg_6_1
	self.onCancel = arg_6_2
end

function LevelStrategyView:InitUI()
	self.icon = self._tf:Find("window/panel/item/icon_bg/icon")
	self.count = self._tf:Find("window/panel/item/icon_bg/count")
	self.name = self._tf:Find("window/panel/item/name")
	self.desc = self._tf:Find("window/panel/item/desc")
	self.btnCancel = self._tf:Find("window/panel/actions/cancel_button")
	self.btnUse = self._tf:Find("window/panel/actions/use_button")
	self.btnBack = self._tf:Find("top/btnBack")
	self.tips = self._tf:Find("window/panel/tips")
	self.txSwitch = findTF(self.btnUse, "switch")
	self.txUse = findTF(self.btnUse, "use")
end

function LevelStrategyView:set(arg_8_1)
	self.strategy = arg_8_1

	self:downloadLevelStrategyRes(arg_8_1, function(arg_9_0)
		self:setAfterDownload(arg_8_1, arg_9_0)
	end)
end

function LevelStrategyView:setAfterDownload(arg_10_1, arg_10_2)
	GetImageSpriteFromAtlasAsync("strategyicon/" .. arg_10_2.icon, "", self.icon)

	if arg_10_2.type == 1 then
		setText(self.count, "")
		setActive(self.tips, true)
		setActive(self.txSwitch, true)
		setActive(self.txUse, false)
	else
		setText(self.count, arg_10_1.count)
		setActive(self.tips, false)
		setActive(self.txSwitch, false)
		setActive(self.txUse, true)
	end

	setText(self.name, arg_10_2.name)
	setText(self.desc, arg_10_2.desc)
	onButton(self, self.btnBack, function()
		if self.onCancel then
			self.onCancel()
		end
	end, SFX_CANCEL)
	onButton(self, self.btnCancel, function()
		if self.onCancel then
			self.onCancel()
		end
	end, SFX_CANCEL)
	onButton(self, self.btnUse, function()
		if self.onConfirm then
			self.onConfirm()
		end
	end, SFX_CONFIRM)
end

return LevelStrategyView
