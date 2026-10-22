local PrayPoolSelectPoolView = class("PrayPoolSelectPoolView", import("..base.BaseSubView"))

function PrayPoolSelectPoolView:getResource()
	return table.insertto({
		"ui/prayselectpoolpage_atlas"
	}, PrayPoolSelectPoolView.super.getResource(self))
end

function PrayPoolSelectPoolView:getUIName()
	return "PrayPoolSelectPoolView"
end

function PrayPoolSelectPoolView:OnInit()
	self:initData()
	self:initUI()
	self:updateUI()
end

function PrayPoolSelectPoolView:OnDestroy()
	return
end

function PrayPoolSelectPoolView:OnBackPress()
	return
end

function PrayPoolSelectPoolView:initData()
	self.prayProxy = getProxy(PrayProxy)
	self.poolToggleList = {}
	self.selectedPoolType = nil
end

function PrayPoolSelectPoolView:initUI()
	self.poolListContainer = self._tf:Find("PoolList")
	self.poolTpl = self._tf:Find("PoolTpl")
	self.preBtn = self._tf:Find("PreBtn")
	self.nextBtn = self._tf:Find("NextBtn")
	self.nextBtnCom = GetComponent(self.nextBtn, "Button")
	self.poolList = UIItemList.New(self.poolListContainer, self.poolTpl)

	self.poolList:make(function(arg_8_0, arg_8_1, arg_8_2)
		if arg_8_0 == UIItemList.EventUpdate then
			local var_8_0 = arg_8_1 + 1

			setImageSprite(arg_8_2:Find("PoolImg"), GetSpriteFromAtlas("ui/prayselectpoolpage_atlas", "pool" .. arg_8_1 + 1))
			onToggle(self, arg_8_2, function(arg_9_0)
				if arg_9_0 then
					self.nextBtnCom.interactable = true
					self.selectedPoolType = var_8_0

					self.prayProxy:setSelectedPoolNum(var_8_0)
				else
					self.nextBtnCom.interactable = false
					self.selectedPoolType = nil

					self.prayProxy:setSelectedPoolNum(nil)
				end
			end, SFX_PANEL)

			self.poolToggleList[arg_8_1 + 1] = arg_8_2
		end
	end)
	self.poolList:align(#pg.activity_ship_create.all)

	self.nextBtnCom.interactable = false

	onButton(self, self.preBtn, function()
		self.prayProxy:updatePageState(PrayProxy.STATE_HOME)
		self:emit(PrayPoolConst.SWITCH_TO_HOME_PAGE, PrayProxy.STATE_HOME)
	end, SFX_PANEL)
	onButton(self, self.nextBtn, function()
		self.prayProxy:updateSelectedPool(self.selectedPoolType)
		self.prayProxy:updatePageState(PrayProxy.STAGE_SELECT_SHIP)
		self:emit(PrayPoolConst.SWITCH_TO_SELECT_SHIP_PAGE, PrayProxy.STAGE_SELECT_SHIP)
	end, SFX_PANEL)
	self:Show()
end

function PrayPoolSelectPoolView:updateUI()
	local var_12_0 = self.prayProxy:getSelectedPoolType()

	if var_12_0 then
		triggerToggle(self.poolToggleList[var_12_0], true)
	else
		return
	end
end

return PrayPoolSelectPoolView
