local PrayPoolHomeView = class("PrayPoolHomeView", import("..base.BaseSubView"))

function PrayPoolHomeView:getUIName()
	return "PrayPoolHomeView"
end

function PrayPoolHomeView:OnInit()
	self:initData()
	self:initUI()
	self:Show()
end

function PrayPoolHomeView:OnDestroy()
	return
end

function PrayPoolHomeView:OnBackPress()
	return
end

function PrayPoolHomeView:initData()
	self.prayProxy = getProxy(PrayProxy)
end

function PrayPoolHomeView:initUI()
	self.startBtn = self._tf:Find("StartBtn")

	onButton(self, self.startBtn, function()
		self.prayProxy:updatePageState(PrayProxy.STATE_SELECT_POOL)
		self:emit(PrayPoolConst.SWITCH_TO_SELECT_POOL_PAGE, PrayProxy.STATE_SELECT_POOL)
	end, SFX_PANEL)
end

return PrayPoolHomeView
