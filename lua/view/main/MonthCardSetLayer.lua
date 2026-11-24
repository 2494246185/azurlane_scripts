local MonthCardSetLayer = class("MonthCardSetLayer", import("..base.BaseUI"))

MonthCardSetLayer.PIECES = 100

function MonthCardSetLayer:getUIName()
	return "MonthCardSetUI"
end

function MonthCardSetLayer:setPlayer(arg_2_1)
	self.player = arg_2_1
end

function MonthCardSetLayer:setRatio(arg_3_1)
	self.ratio = math.clamp(arg_3_1, 0, MonthCardSetLayer.PIECES)
end

function MonthCardSetLayer:init()
	self.name = self._tf:Find("window/bg/name")
	self.desc = self._tf:Find("window/bg/desc")
	self.oil = self._tf:Find("window/black/oil/icon_bg/count")
	self.gold = self._tf:Find("window/black/gold/icon_bg/count")
	self.slider = self._tf:Find("window/black/slider")
	self.rate = self._tf:Find("window/black/misc/rate")
	self.confirm = self._tf:Find("window/confirm")
	self.cancel = self._tf:Find("window/cancel")
end

function MonthCardSetLayer:didEnter()
	onButton(self, self._tf, function()
		self:emit(MonthCardSetLayer.ON_CLOSE)
	end, SFX_CANCEL)
	onButton(self, self.cancel, function()
		self:emit(MonthCardSetLayer.ON_CLOSE)
	end, SFX_CANCEL)
	onButton(self, self.confirm, function()
		self:emit(MonthCardSetMediator.ON_SET_RATIO, self.ratio)
	end, SFX_CANCEL)
	onSlider(self, self.slider, function(arg_9_0)
		self:setRatio(arg_9_0)
		self:updateRatioView()
	end)
	self:updateView()
	self:updateRatioView()
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
end

function MonthCardSetLayer:updateView()
	setText(self.name, string.format("贸易许可证（剩余%s天）", (math.floor((self.player:getCardById(VipCard.MONTH):getLeftDate() - pg.TimeMgr.GetInstance():GetServerTime()) / 86400))))
	setText(self.rate, "1 : 5")
end

function MonthCardSetLayer:updateRatioView()
	setSlider(self.slider, 0, MonthCardSetLayer.PIECES, self.ratio)
	setText(self.oil, 400 * self.ratio / MonthCardSetLayer.PIECES)
	setText(self.gold, 2000 * (MonthCardSetLayer.PIECES - self.ratio) / MonthCardSetLayer.PIECES)
end

function MonthCardSetLayer:willExit()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)
end

return MonthCardSetLayer
