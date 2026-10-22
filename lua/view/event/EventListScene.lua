EventConst = require("view/event/EventConst")
EventListItem = require("view/event/EventListItem")
EventDetailPanel = require("view/event/EventDetailPanel")

local EventListScene = class("EventListScene", import("..base.BaseUI"))
local var_0_1 = {
	{
		0,
		1,
		3,
		4,
		6
	},
	{
		2,
		5
	}
}

function EventListScene:getUIName()
	return "EventUI"
end

function EventListScene:getResource()
	local var_2_0 = {
		"weaponframes",
		"shiptype",
		"ui/iconcolorful"
	}

	local function var_2_1(arg_3_0)
		if noEmptyStr(arg_3_0) and not table.contains(var_2_0, arg_3_0) then
			table.insert(var_2_0, arg_3_0)
		end
	end

	local function var_2_2(arg_4_0)
		if not arg_4_0 or not arg_4_0.type or not arg_4_0.id then
			return
		end

		local var_4_0 = {
			arg_4_0.type,
			arg_4_0.id
		}

		var_4_0[3] = arg_4_0.nums or arg_4_0.count or 1

		local var_4_1 = Drop.Create(var_4_0)

		var_2_1(var_4_1:getIcon())
		var_2_1(var_4_1:getDefaultIcon())
	end

	local var_2_3 = getProxy(EventProxy):getEventList()

	var_2_3 = var_2_3 or {}

	local var_2_4 = getProxy(BayProxy)

	for iter_2_0, iter_2_1 in ipairs(var_2_3) do
		var_2_1("eventtype/" .. iter_2_1.template.icon)

		for iter_2_2, iter_2_3 in ipairs(iter_2_1.template.drop_display or {}) do
			var_2_2(iter_2_3)
		end

		var_2_2(iter_2_1.template.special_drop)

		for iter_2_4, iter_2_5 in ipairs(iter_2_1.shipIds or {}) do
			local var_2_5 = var_2_4:RawGetShipById(iter_2_5)

			if var_2_5 then
				var_2_1("SquareIcon/" .. var_2_5:getPainting())
			end
		end
	end

	return table.insertto(var_2_0, EventListScene.super.getResource(self))
end

function EventListScene:init()
	function self.dispatch(...)
		self:emit(...)
	end

	self.blurPanel = self._tf:Find("blur_panel")
	self.lay = self.blurPanel:Find("adapt/left_length")
	self.topPanel = self._tf:Find("blur_panel/adapt/top").gameObject
	self.btnBack = self._tf:Find("blur_panel/adapt/top/back_btn").gameObject
	self.topLeft = self._tf:Find("blur_panel/adapt/top/topLeftBg$")
	self.topLeftBg = self._tf:Find("blur_panel/adapt/top/topLeftBg$").gameObject
	self.labelShipNums = self._tf:Find("blur_panel/adapt/top/topLeftBg$/labelShipNums$"):GetComponent("Text")
	self.mask = self._tf:Find("mask$"):GetComponent("Image")
	self.scrollItem = EventListItem.New(self._tf:Find("blur_panel/scrollItem").gameObject, self.dispatch)

	self.scrollItem.go:SetActive(false)

	self.detailPanel = EventDetailPanel.New(self._tf:Find("detailPanel").gameObject, self.dispatch)

	self.detailPanel.go:SetActive(false)

	self.scrollRectObj = self._tf:Find("scrollRect$")
	self.scrollRect = self.scrollRectObj:GetComponent("LScrollRect")

	function self.scrollRect.onInitItem(arg_7_0)
		self:onInitItem(arg_7_0)
	end

	function self.scrollRect.onUpdateItem(arg_8_0, arg_8_1)
		self:onUpdateItem(arg_8_0, arg_8_1)
	end

	function self.scrollRect.onReturnItem(arg_9_0, arg_9_1)
		self:onReturnItem(arg_9_0, arg_9_1)
	end

	self.scrollItems = {}
	self.selectedItem = nil
	self.rawLayouts = {}

	setImageAlpha(self.mask, 0)

	self.scrollRect.decelerationRate = 0.07
	self.listEmptyTF = self._tf:Find("empty")

	setActive(self.listEmptyTF, false)

	self.listEmptyTxt = self.listEmptyTF:Find("Text")

	setText(self.listEmptyTxt, i18n("list_empty_tip_eventui"))
end

local var_0_2 = {
	"daily",
	"urgency"
}

function EventListScene:didEnter()
	onButton(self, self.btnBack, function()
		if self.selectedItem then
			self:easeOut(function()
				self:emit(EventListScene.ON_BACK)
			end)
		else
			self:emit(EventListScene.ON_BACK)
		end
	end, SFX_CANCEL)
	setActive(self._tf:Find("stamp"), getProxy(TaskProxy):mingshiTouchFlagEnabled())

	if LOCK_CLICK_MINGSHI then
		setActive(self._tf:Find("stamp"), false)
	end

	onButton(self, self._tf:Find("stamp"), function()
		getProxy(TaskProxy):dealMingshiTouchFlag(9)
	end, SFX_CONFIRM)

	self.toggles = {}
	self.toggleIndex = -1

	for iter_10_0, iter_10_1 in ipairs(var_0_2) do
		self.toggles[iter_10_0] = self.lay:Find("frame/scroll_rect/tagRoot/" .. iter_10_1 .. "_btn")

		onToggle(self, self.toggles[iter_10_0], function(arg_14_0)
			if arg_14_0 and self.toggleIndex ~= iter_10_0 then
				self.toggleIndex = iter_10_0

				if self.selectedItem then
					pg.UIMgr.GetInstance():UnOverlayPanel(self.blurPanel, self._tf)

					local var_14_0 = 1000000

					for iter_14_0 = 0, self.scrollRect.content.childCount - 1 do
						local var_14_1 = self.scrollRect.content:GetChild(iter_14_0)

						if var_14_1 == self.selectedItem.tr then
							var_14_0 = iter_14_0
						elseif var_14_0 < iter_14_0 then
							if not self.rawLayouts[var_14_1] then
								var_14_1:GetComponent(typeof(LayoutElement)).ignoreLayout = false
							end
						end
					end

					self.rawLayouts = {}

					self.mask.gameObject:SetActive(false)
					self.scrollItem.go:SetActive(false)
					self.detailPanel.go:SetActive(false)

					self.scrollRect.enabled = true
					self.selectedItem = nil
					self.contextData.selectedEventId = nil
				end

				self.contextData.index = iter_10_0

				self:Flush(not (self.toggleIndex == -1))
			end
		end)
	end

	triggerToggle(self.toggles[self.contextData.index or 1], true)

	local function var_10_0()
		if self.scrollItem.event:GetState() == EventInfo.StateFinish then
			self.dispatch(EventConst.EVENT_FINISH, self.scrollItem.event)
		else
			self:easeOut()
		end
	end

	onButton(self, self.scrollItem.bgNormal, var_10_0, SFX_PANEL)
	onButton(self, self.scrollItem.bgEmergence, var_10_0, SFX_PANEL)
	onButton(self, self.mask.gameObject, function()
		self:easeOut()
	end, SFX_CANCEL)
	self:ctimer()
	self:updateBtnTip()
end

function EventListScene:onBackPressed()
	pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_CANCEL)
	triggerButton(self.btnBack)
end

function EventListScene:setEventList(arg_18_1)
	self.eventList = arg_18_1
end

function EventListScene:updateAll()
	if self.selectedItem then
		local var_19_0 = underscore.detect(self.eventList, function(arg_20_0)
			return arg_20_0.id == self.selectedItem.event.id
		end)

		if var_19_0 then
			local var_19_1 = getProxy(EventProxy)

			self.labelShipNums.text = var_19_1.maxFleetNums - var_19_1:countBusyFleetNums() .. "/" .. var_19_1.maxFleetNums

			self.scrollItem:Update(self.selectedItem.index, var_19_0)
			self.detailPanel:Update(self.selectedItem.index, var_19_0)
		else
			self:easeOut()
		end

		self.invalide = true
	else
		self:Flush()
	end

	self:updateBtnTip()
end

function EventListScene:Flush(arg_21_1)
	local var_21_0 = getProxy(EventProxy)

	if var_21_0:checkZeroHourEvent() then
		self.dispatch(EventConst.EVENT_FLUSH_ALL)

		return
	elseif var_0_2[self.contextData.index] == "urgency" and var_21_0:checkNightEvent() then
		self.dispatch(EventConst.EVENT_FLUSH_ALL)

		return
	end

	if not false then
		self.labelShipNums.text = var_21_0.maxFleetNums - var_21_0:countBusyFleetNums() .. "/" .. var_21_0.maxFleetNums

		if self.contextData.selectedEventId then
			pg.UIMgr.GetInstance():LoadingOn()
			seriesAsync({
				function(arg_22_0)
					if self.scrollRect.isStart then
						arg_22_0()
					else
						self.scrollRect.onStart = arg_22_0
					end
				end,
				function(arg_23_0)
					local var_23_0 = 1

					for iter_23_0, iter_23_1 in ipairs(self.filterEventList) do
						if iter_23_1.id == self.contextData.selectedEventId then
							var_23_0 = iter_23_0

							break
						end
					end

					self.scrollRect:ScrollTo((self.scrollRect:HeadIndexToValue(var_23_0 - 1)))

					for iter_23_2, iter_23_3 in pairs(self.scrollItems) do
						if iter_23_3.event and iter_23_3.event.id == self.contextData.selectedEventId then
							self.selectedItem = iter_23_3

							self:showDetail()

							break
						end
					end

					arg_23_0()
				end
			}, function()
				pg.UIMgr.GetInstance():LoadingOff()
			end)
		end
	end

	self:filter()
	self.scrollRect:SetTotalCount(#self.filterEventList, false and 0 or self.scrollRect.value)
	setActive(self.listEmptyTF, #self.filterEventList <= 0)
end

function EventListScene:filter()
	self.filterEventList = {}

	for iter_25_0, iter_25_1 in ipairs(self.eventList) do
		for iter_25_2, iter_25_3 in ipairs(var_0_1[self.contextData.index]) do
			if iter_25_1.template.type == iter_25_3 then
				table.insert(self.filterEventList, iter_25_1)

				break
			end
		end
	end

	table.sort(self.filterEventList, CompareFuncs({
		function(arg_26_0)
			return arg_26_0:IsActivityType() and 0 or 1
		end,
		function(arg_27_0)
			return -arg_27_0:GetState()
		end,
		function(arg_28_0)
			return arg_28_0.template.type == 3 and 0 or 1
		end,
		function(arg_29_0)
			return arg_29_0.overTime == 0 and 0 or 1
		end,
		function(arg_30_0)
			return arg_30_0.id
		end
	}))
end

function EventListScene:onInitItem(arg_31_1)
	local var_31_0 = EventListItem.New(arg_31_1, self.dispatch)

	local function var_31_1()
		if var_31_0.event:GetState() == EventInfo.StateFinish then
			self.dispatch(EventConst.EVENT_FINISH, var_31_0.event)
		else
			self:easeIn(var_31_0)
		end
	end

	onButton(self, var_31_0.bgNormal, var_31_1, SFX_PANEL)
	onButton(self, var_31_0.bgEmergence, var_31_1, SFX_PANEL)

	self.scrollItems[arg_31_1] = var_31_0
end

function EventListScene:onUpdateItem(arg_33_1, arg_33_2)
	GetComponent(tf(arg_33_2), "CanvasGroup").alpha = 1

	local var_33_0 = self.scrollItems[arg_33_2]

	if not self.scrollItems[arg_33_2] then
		self:onInitItem(arg_33_2)

		var_33_0 = self.scrollItems[arg_33_2]
	end

	if self.filterEventList[arg_33_1 + 1] then
		var_33_0:Update(arg_33_1, self.filterEventList[arg_33_1 + 1])
		var_33_0:UpdateTime()
	end
end

function EventListScene:onReturnItem(arg_34_1, arg_34_2)
	if self.scrollItems and self.scrollItems[arg_34_2] then
		self.scrollItems[arg_34_2]:Clear()
	end
end

function EventListScene:easeIn(arg_35_1)
	if not self.easing then
		self.easing = true
		self.selectedItem = arg_35_1

		self:setOpEnabled(false)
		self:easeInDetail(function()
			pg.UIMgr.GetInstance():BlurPanel(self.blurPanel)

			self.easing = false

			self:setOpEnabled(true)
		end)
	end
end

function EventListScene:easeOut(arg_37_1)
	if not self.easing then
		self.easing = true

		self:setOpEnabled(false)
		self:easeOutDetail(function()
			pg.UIMgr.GetInstance():UnOverlayPanel(self.blurPanel, self._tf)

			self.easing = false
			self.selectedItem = nil
			self.contextData.selectedEventId = nil

			self:setOpEnabled(true)

			if self.invalide then
				self.invalide = false

				self:Flush()
			end

			if arg_37_1 then
				arg_37_1()
			end
		end)
	end
end

function EventListScene:easeInDetail(arg_39_1)
	local var_39_0 = 0.3

	self.mask.gameObject:SetActive(true)

	self.scrollRect.enabled = false

	local var_39_1 = self.scrollRect.transform
	local var_39_2 = self.scrollRect.content
	local var_39_3 = self.scrollRect.transform.rect.yMax

	LeanTween.value(self.scrollRect.content.gameObject, self.scrollRect.value, self.scrollRect:HeadIndexToValue(self.selectedItem.index), 0.3 * math.abs(self.scrollRect.transform.rect.yMax - self.scrollRect.content.localPosition.y - self.selectedItem.tr.localPosition.y) / self.scrollRect.transform.rect.height):setEase(LeanTweenType.easeInOutCirc):setOnUpdate(System.Action_float(function(arg_40_0)
		self.scrollRect:SetNormalizedPosition(arg_40_0, 1)
	end)):setOnComplete(System.Action(function()
		self.scrollItem.tr.localPosition.y = var_39_3 + var_39_1.localPosition.y
		self.scrollItem.tr.localPosition = self.scrollItem.tr.localPosition

		self.scrollItem.go:SetActive(true)
		self.scrollItem:Update(self.selectedItem.index, self.selectedItem.event)
		self.scrollItem:UpdateTime()
		self.detailPanel.tr:SetParent(self.scrollItem.tr:Find("maskDetail"), true)

		self.detailPanel.tr.localPosition = Vector3.zero

		self.detailPanel.go:SetActive(true)
		self.detailPanel:Update(self.selectedItem.index, self.selectedItem.event)

		self.contextData.selectedEventId = self.selectedItem.event.id

		shiftPanel(self.detailPanel.go, nil, -155, var_39_0, 0, true):setEase(LeanTweenType.easeInOutCirc):setOnComplete(System.Action(arg_39_1))

		local var_41_0 = 100000
		local var_41_1 = {}

		for iter_41_0 = 0, var_39_2.childCount - 1 do
			local var_41_2 = var_39_2:GetChild(iter_41_0)

			if var_41_2 == self.selectedItem.tr then
				var_41_0 = iter_41_0
			elseif var_41_0 < iter_41_0 then
				table.insert(var_41_1, var_41_2)
			end
		end

		self.rawLayouts = {}

		for iter_41_1, iter_41_2 in ipairs(var_41_1) do
			local var_41_3 = iter_41_2:GetComponent(typeof(LayoutElement))

			self.rawLayouts[iter_41_2] = var_41_3.ignoreLayout
			var_41_3.ignoreLayout = true

			shiftPanel(iter_41_2, nil, iter_41_2.localPosition.y + -347, var_39_0, 0, true):setEase(LeanTweenType.easeInOutCirc)
		end
	end))
end

function EventListScene:easeOutDetail(arg_42_1)
	local var_42_0 = 100000
	local var_42_1 = {}

	for iter_42_0 = 0, self.scrollRect.content.childCount - 1 do
		local var_42_2 = self.scrollRect.content:GetChild(iter_42_0)

		if var_42_2 == self.selectedItem.tr then
			var_42_0 = iter_42_0
		elseif var_42_0 < iter_42_0 then
			table.insert(var_42_1, var_42_2)
		end
	end

	for iter_42_1, iter_42_2 in ipairs(var_42_1) do
		shiftPanel(iter_42_2, nil, iter_42_2.localPosition.y + 268, 0.2, 0, true):setEase(LeanTweenType.easeInOutCirc)
	end

	shiftPanel(self.detailPanel.go, nil, 129, 0.2, 0, true):setEase(LeanTweenType.easeInOutCirc):setOnComplete(System.Action(function()
		for iter_43_0, iter_43_1 in ipairs(var_42_1) do
			if not self.rawLayouts[iter_43_1] then
				iter_43_1:GetComponent(typeof(LayoutElement)).ignoreLayout = false
			end
		end

		self.rawLayouts = {}

		self.mask.gameObject:SetActive(false)
		self.scrollItem.go:SetActive(false)
		self.detailPanel.go:SetActive(false)

		self.scrollRect.enabled = true

		arg_42_1()
	end))
end

function EventListScene:showDetail()
	self.scrollRect.enabled = false

	self.mask.gameObject:SetActive(true)

	self.scrollItem.tr.localPosition.y = self.scrollRect.transform.rect.yMax + self.scrollRect.transform.localPosition.y
	self.scrollItem.tr.localPosition = self.scrollItem.tr.localPosition

	self.scrollItem.go:SetActive(true)
	self.scrollItem:Update(self.selectedItem.index, self.selectedItem.event)
	self.scrollItem:UpdateTime()
	self.detailPanel.tr:SetParent(self.scrollItem.tr:Find("maskDetail"), true)

	self.detailPanel.tr.anchoredPosition = Vector3.New(-1, -155, 0)

	self.detailPanel.go:SetActive(true)
	self.detailPanel:Update(self.selectedItem.index, self.selectedItem.event)

	self.contextData.selectedEventId = self.selectedItem.event.id

	local var_44_0 = 100000

	self.rawLayouts = {}

	for iter_44_0 = 0, self.scrollRect.content.childCount - 1 do
		local var_44_1 = self.scrollRect.content:GetChild(iter_44_0)
		local var_44_2 = var_44_1:GetComponent(typeof(LayoutElement))

		if var_44_2.ignoreLayout or not var_44_1.gameObject.activeSelf then
			self.rawLayouts[var_44_1] = var_44_2.ignoreLayout
		elseif var_44_1 == self.selectedItem.tr then
			var_44_0 = iter_44_0
		elseif var_44_0 < iter_44_0 then
			self.rawLayouts[var_44_1] = var_44_2.ignoreLayout
			var_44_2.ignoreLayout = true
			var_44_1.localPosition = var_44_1.localPosition + Vector3.New(-1, -347, 0)
		end
	end

	pg.UIMgr.GetInstance():BlurPanel(self.blurPanel)
end

function EventListScene:ctimer()
	self.timer = Timer.New(function()
		if self.selectedItem then
			self.scrollItem:UpdateTime()
		end

		local var_46_0 = pg.TimeMgr.GetInstance()
		local var_46_1 = var_46_0:GetServerTime()

		if var_46_0:STimeDescS(var_46_1, "%Y/%m/%d") ~= var_46_0:STimeDescS(var_46_1 - 1, "%Y/%m/%d") then
			self.dispatch(EventConst.EVENT_FLUSH_ALL)

			return
		end

		local var_46_2 = false

		for iter_46_0, iter_46_1 in pairs(self.scrollItems) do
			if iter_46_1.go.name ~= "-1" then
				iter_46_1:UpdateTime()

				local var_46_3 = iter_46_1.event:GetCountDownTime()

				if var_46_3 and var_46_3 < 0 then
					var_46_2 = true
				end
			end
		end

		if var_46_2 then
			self.dispatch(EventConst.EVENT_LIST_UPDATE)
		end
	end, 1, -1, true)

	self.timer:Start()
end

function EventListScene:ktimer()
	if self.timer then
		self.timer:Stop()

		self.timer = nil
	end
end

function EventListScene:setOpEnabled(arg_48_1)
	_.each(self.toggles, function(arg_49_0)
		setToggleEnabled(arg_49_0, arg_48_1)
	end)
	setButtonEnabled(self.btnBack, arg_48_1)
end

function EventListScene:updateBtnTip()
	local var_50_0 = {
		false
	}

	var_50_0[2] = getProxy(EventProxy):checkNightEvent()

	for iter_50_0, iter_50_1 in ipairs(self.eventList) do
		if iter_50_1:GetState() == EventInfo.StateFinish then
			var_50_0[iter_50_1.template.type] = true
		end
	end

	for iter_50_2, iter_50_3 in ipairs(self.toggles) do
		setActive(findTF(iter_50_3, "tip"), var_50_0[iter_50_2])
	end
end

function EventListScene:willExit()
	if self.tweens then
		cancelTweens(self.tweens)
	end

	pg.UIMgr.GetInstance():UnOverlayPanel(self.blurPanel, self._tf)
	self:ktimer()

	for iter_51_0, iter_51_1 in pairs(self.scrollItems) do
		iter_51_1:Clear()
	end

	self.scrollItem:Clear()
	self.detailPanel:Clear()
end

return EventListScene
