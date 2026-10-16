local EducateAwardInfoLayer = class("EducateAwardInfoLayer", import("..base.EducateBaseUI"))
local var_0_1 = {
	Vector2(0, 115),
	Vector2(0, 162)
}
local var_0_2 = {
	Vector2(0, -280),
	Vector2(0, -315)
}
local var_0_3 = 0.4

function EducateAwardInfoLayer:getUIName()
	return "EducateAwardInfoUI"
end

function EducateAwardInfoLayer:init()
	pg.UIMgr.GetInstance():BlurPanel(self._tf)

	self.drops = self.contextData.items or {}
	self.awardWindow = self._tf:Find("award_window")
	self.anim = self.awardWindow:GetComponent(typeof(Animation))
	self.animEvent = self.awardWindow:GetComponent(typeof(DftAniEvent))

	self.animEvent:SetEndEvent(function()
		if #self.showPolaroidDrops > 0 then
			setActive(self.awardWindow, false)
			setActive(self.polaroidWindow, true)

			self.polaroidIndex = 1

			self:showPolaroidAnim()
		else
			self:emit(EducateAwardInfoLayer.ON_CLOSE)
		end
	end)

	self.tipTF = self.awardWindow:Find("tip")

	setText(self.tipTF, i18n("child_close_tip"))

	self.itemContent = self.awardWindow:Find("content/items")
	self.itemContainer = self.itemContent:Find("items_scroll/content")
	self.itemTpl = self.awardWindow:Find("item_tpl")

	setActive(self.itemTpl, false)

	self.attrContent = self.awardWindow:Find("content/attrs")
	self.attrContainer = self.attrContent:Find("attrs_scroll/content")
	self.attrTpl = self.awardWindow:Find("attr_tpl")

	setActive(self.attrTpl, false)

	self.polaroidWindow = self._tf:Find("polaroid_window")
	self.polaroidIconTF = self.polaroidWindow:Find("content/mask/icon")
	self.polaroidDescTF = self.polaroidWindow:Find("content/desc")

	setActive(self.awardWindow, false)
	setActive(self.polaroidWindow, false)
	self._tf:SetAsLastSibling()
end

function EducateAwardInfoLayer:didEnter()
	onButton(self, self.awardWindow:Find("close"), function()
		self:_close()
	end, SFX_CANCEL)
	onButton(self, self.polaroidWindow, function()
		if self.playing then
			return
		end

		pg.TipsMgr.GetInstance():ShowTips(i18n("child_polaroid_get_tip"))

		if self.polaroidIndex <= #self.showPolaroidDrops then
			self:showPolaroidAnim()
		else
			self:emit(EducateAwardInfoLayer.ON_CLOSE)
		end
	end, SFX_CANCEL)

	self.showAwardDrops = self:getAwardDrops()
	self.showAttrDrops = self:getAttrDrops()
	self.showPolaroidDrops = self:getPolaroidDrops()

	setActive(self.attrContent, #self.showAttrDrops > 0)
	self:showWindow()
end

function EducateAwardInfoLayer:showWindow()
	if #self.showAwardDrops > 0 then
		self.inAnimPlaying = true

		setActive(self.awardWindow, true)
		self.anim:Play(#self.showAttrDrops > 0 and "anim_educate_awardinfo_awardattr_in" or "anim_educate_awardinfo_award_in")

		local var_7_0 = {}

		table.insert(var_7_0, function(arg_8_0)
			self:managedTween(LeanTween.delayedCall, function()
				arg_8_0()
			end, 0.33, nil)
		end)

		for iter_7_0 = 1, math.max(#self.showAttrDrops, #self.showAwardDrops) do
			table.insert(var_7_0, function(arg_10_0)
				local var_10_0 = self.showAwardDrops[iter_7_0]

				if self.showAwardDrops[iter_7_0] then
					local var_10_1 = cloneTplTo(self.itemTpl, self.itemContainer)

					EducateHelper.UpdateDropShow(var_10_1, self.showAwardDrops[iter_7_0])
					onButton(self, var_10_1, function()
						self:emit(EducateAwardInfoLayer.EDUCATE_ON_ITEM, {
							drop = var_10_0
						})
					end)
				end

				if self.showAttrDrops[iter_7_0] then
					EducateHelper.UpdateDropShowForAttr(cloneTplTo(self.attrTpl, self.attrContainer), self.showAttrDrops[iter_7_0])
				end

				self:managedTween(LeanTween.delayedCall, function()
					arg_10_0()
				end, 0.066, nil)
			end)
		end

		seriesAsync(var_7_0, function()
			self:managedTween(LeanTween.delayedCall, function()
				self.inAnimPlaying = false
			end, 0.066, nil)
		end)
	elseif #self.showPolaroidDrops > 0 then
		setActive(self.polaroidWindow, true)

		self.polaroidIndex = 1

		self:showPolaroidAnim()
	else
		assert(nil, "不合法掉落, award/polaroid都为空, 请检查对应配置~")
	end
end

function EducateAwardInfoLayer:getAwardDrops()
	return EducateHelper.FilterDropByTypes(self.drops, {
		EducateConst.DROP_TYPE_ATTR,
		EducateConst.DROP_TYPE_RES,
		EducateConst.DROP_TYPE_ITEM,
		EducateConst.DROP_TYPE_BUFF
	})
end

function EducateAwardInfoLayer:getAttrDrops()
	local var_16_0 = {}

	underscore.each(EducateHelper.FilterDropByTypes(self.drops, {
		EducateConst.DROP_TYPE_ITEM
	}), function(arg_17_0)
		var_16_0 = table.mergeArray(var_16_0, EducateHelper.GetItemAddDrops(arg_17_0))
	end)

	return var_16_0
end

function EducateAwardInfoLayer:getPolaroidDrops()
	return EducateHelper.FilterDropByTypes(self.drops, {
		EducateConst.DROP_TYPE_POLAROID
	})
end

function EducateAwardInfoLayer:showPolaroidAnim()
	self.playing = true

	setActive(self.polaroidDescTF, false)
	LoadImageSpriteAsync("educatepolaroid/" .. pg.child_polaroid[self.showPolaroidDrops[self.polaroidIndex].id].pic, self.polaroidIconTF)
	setText(self.polaroidDescTF, pg.child_polaroid[self.showPolaroidDrops[self.polaroidIndex].id].title)

	local var_19_0 = {}

	table.insert(var_19_0, function(arg_20_0)
		self:managedTween(LeanTween.delayedCall, function()
			setActive(self.polaroidDescTF, true)
			arg_20_0()
		end, var_0_3, nil)
	end)

	if getProxy(EducateProxy):CheckNewSecretaryTip() then
		table.insert(var_19_0, function(arg_22_0)
			self:emit(EducateAwardInfoLayer.EDUCATE_ON_UNLOCK_TIP, {
				type = EducateUnlockTipLayer.UNLOCK_NEW_SECRETARY,
				onExit = arg_22_0
			})
		end)
	end

	seriesAsync(var_19_0, function()
		self.playing = false
		self.polaroidIndex = self.polaroidIndex + 1
	end)
end

function EducateAwardInfoLayer:_close()
	if pg.NewGuideMgr.GetInstance():IsBusy() then
		self:emit(EducateAwardInfoLayer.ON_CLOSE)

		return
	end

	if self.inAnimPlaying or self.isCloseAnim then
		return
	end

	self.anim:Play("anim_educate_awardinfo_award_out")

	self.isCloseAnim = true
end

function EducateAwardInfoLayer:onBackPressed()
	self:_close()
end

function EducateAwardInfoLayer:willExit()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)

	if self.contextData.removeFunc then
		self.contextData.removeFunc()

		self.contextData.removeFunc = nil
	end
end

return EducateAwardInfoLayer
