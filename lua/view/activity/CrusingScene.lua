local CrusingScene = class("CrusingScene", import("view.base.BaseUI"))

CrusingScene.optionsPath = {
	"top/home"
}
CrusingScene.FrameSpeed = 10
CrusingScene.PlaySpeed = 1.5

function CrusingScene:getUIName()
	return "CrusingUI"
end

function CrusingScene:preload(arg_2_1)
	local var_2_0 = getProxy(ActivityProxy)
	local var_2_1 = var_2_0:getAliveActivityByType(ActivityConst.ACTIVITY_TYPE_PT_CRUSING)
	local var_2_2 = PoolMgr.GetInstance()
	local var_2_3 = {}

	table.insert(var_2_0, function(arg_3_0)
		local var_3_0 = pg.battlepass_event_pt[var_2_1.id].crusing_map

		var_2_2:GetPrefab("crusingmap/" .. pg.battlepass_event_pt[var_2_1.id].crusing_map, "", true, function(arg_4_0)
			self.rtMap = tf(arg_4_0)
			self.PhaseFrame, self.AllFrameCount = CrusingMapInfo.GetPhaseFrame(var_3_0)

			arg_3_0()
		end)
	end)
	table.insert(var_2_3, function(arg_5_0)
		var_2_2:GetSpineChar(pg.battlepass_event_pt[var_2_1.id].spine_name, true, function(arg_6_0)
			self.rtModel = tf(arg_6_0)

			arg_5_0()
		end)
	end)
	parallelAsync(var_2_3, function()
		setParent(self.rtModel, self.rtMap:Find("icon/model"))

		self.rtModel.localScale = Vector3.one

		arg_2_1()
	end)
end

function CrusingScene:getResource()
	local var_8_0 = CrusingScene.super.getResource(self)
	local var_8_1 = getProxy(ActivityProxy):getAliveActivityByType(ActivityConst.ACTIVITY_TYPE_PT_CRUSING)

	if var_8_1 then
		local var_8_2 = {}

		var_8_2[1] = pg.battlepass_event_pt[var_8_1.id].crusing_map and "crusingmap/" .. pg.battlepass_event_pt[var_8_1.id].crusing_map
		var_8_2[2] = pg.battlepass_event_pt[var_8_1.id].spine_name and "char/" .. pg.battlepass_event_pt[var_8_1.id].spine_name

		for iter_8_0, iter_8_1 in ipairs(var_8_2) do
			if noEmptyStr(iter_8_1) and not table.contains(var_8_0, iter_8_1) then
				table.insert(var_8_0, iter_8_1)
			end
		end
	end

	return var_8_0
end

function CrusingScene:init()
	self.rtBg = self._tf:Find("bg")
	self.scrollMap = self.rtBg:Find("map_scroll")
	self.btnTask = self.rtBg:Find("task_btn")
	self.textTip = self.rtBg:Find("tip")
	self.rtAward = self._tf:Find("award_panel")
	self.textPhase = self.rtAward:Find("phase/Text")
	self.sliderPt = self.rtAward:Find("Slider")
	self.comScroll = GetComponent(self.rtAward:Find("view/content"), "LScrollRect")

	function self.comScroll.onUpdateItem(arg_10_0, arg_10_1)
		self:updateAwardInfo(tf(arg_10_1), self.awardList[arg_10_0 + 1])
	end

	self.rtNextAward = self.rtAward:Find("next")
	self.btnAll = self.rtAward:Find("btn_all")
	self.btnPay = self.rtAward:Find("btn_pay")
	self.btnAfter = self.rtAward:Find("btn_after")
	self.btnFinish = self.rtAward:Find("btn_finish")
	self.rtTop = self._tf:Find("top")
	self.btnBack = self.rtTop:Find("back")
	self.btnHelp = self.rtTop:Find("help")
	self.textDay = self.rtTop:Find("day/Text")
	self.chargeTipWindow = ChargeTipWindow.New(self._tf, self.event)
	self.LTDic = {}
end

function CrusingScene:didEnter()
	onButton(self, self.btnBack, function()
		self:closeView()
	end, SFX_CANCEL)
	onButton(self, self.btnTask, function()
		if self.phase < #self.awardList then
			self:emit(CrusingMediator.EVENT_OPEN_TASK)
		else
			pg.TipsMgr.GetInstance():ShowTips(i18n("battlepass_complete"))
		end
	end, SFX_PANEL)
	onButton(self, self.btnAll, function()
		local var_14_0 = self.activity:GetCrusingUnreceiveAward()

		if #var_14_0 > 0 then
			local var_14_1 = {}

			if self:checkLimitMax(var_14_0) then
				table.insert(var_14_1, function(arg_15_0)
					pg.MsgboxMgr.GetInstance():ShowMsgBox({
						content = i18n("player_expResource_mail_fullBag"),
						onYes = arg_15_0
					})
				end)
			end

			seriesAsync(var_14_1, function()
				self:emit(CrusingMediator.EVENT_GET_AWARD_ALL)
			end)
		end
	end, SFX_CONFIRM)
	onButton(self, self.btnPay, function()
		self:openBuyPanel()
	end, SFX_CONFIRM)
	onButton(self, self.btnAfter, function()
		local var_18_0 = self.activity:GetCrusingUnreceiveAward()

		if #var_18_0 > 0 then
			local var_18_1 = {}

			if self:checkLimitMax(var_18_0) then
				table.insert(var_18_1, function(arg_19_0)
					pg.MsgboxMgr.GetInstance():ShowMsgBox({
						content = i18n("player_expResource_mail_fullBag"),
						onYes = arg_19_0
					})
				end)
			end

			seriesAsync(var_18_1, function()
				self:emit(CrusingMediator.EVENT_GET_AWARD_ALL)
			end)
		end
	end, SFX_CONFIRM)
	onButton(self, self.btnHelp, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = i18n("battlepass_main_help_" .. pg.battlepass_event_pt[self.activity.id].map_name)
		})
	end, SFX_PANEL)

	local function var_11_0(arg_22_0)
		local var_22_0 = {
			_tf = arg_22_0,
			rtLine = arg_22_0:Find("line"),
			rtIcon = arg_22_0:Find("icon"),
			rtSimple = arg_22_0:Find("simple")
		}

		setParent(arg_22_0, self.scrollMap)
		SetCompomentEnabled(arg_22_0, typeof(Image), false)

		arg_22_0.name = "map_tpl"

		SetAction(var_22_0.rtIcon:Find("model"):GetChild(0), "normal")

		return var_22_0
	end

	self.maps = {
		var_11_0(self.rtMap)
	}

	while #self.maps < 3 do
		table.insert(self.maps, var_11_0(tf(Instantiate(self.rtMap))))
	end

	Canvas.ForceUpdateCanvases()

	for iter_11_0, iter_11_1 in ipairs(self.maps) do
		setParent(iter_11_1.rtLine, self.scrollMap:Find("bg"), true)
	end

	GetComponent(self.textTip, "RichText"):AddSprite("pt", GetSpriteFromAtlas(Drop.New({
		type = DROP_TYPE_VITEM,
		id = self.ptId
	}):getIcon(), ""))
	setText(self.textTip, i18n("battlepass_main_tip_" .. pg.battlepass_event_pt[self.activity.id].map_name))

	local var_11_1 = self.activity.stopTime - pg.TimeMgr.GetInstance():GetServerTime()

	setText(self.textDay, i18n("battlepass_main_time", math.floor(var_11_1 / 86400), math.floor(var_11_1 % 86400 / 3600)))

	local var_11_2 = GetComponent(self.scrollMap, typeof(ScrollRect))
	local var_11_3 = var_11_2.content.rect.width / 3 / (var_11_2.content.rect.width - var_11_2.viewport.rect.width)

	onScroll(self, self.scrollMap, function(arg_23_0)
		if arg_23_0.x < 0.1 then
			var_11_2.normalizedPosition.x = arg_23_0.x + var_11_3
			var_11_2.normalizedPosition = var_11_2.normalizedPosition
			var_11_2.velocity = var_11_2.velocity
		elseif arg_23_0.x > 0.9 then
			var_11_2.normalizedPosition.x = arg_23_0.x - var_11_3
			var_11_2.normalizedPosition = var_11_2.normalizedPosition
			var_11_2.velocity = var_11_2.velocity
		end
	end)
	self:onScroll(self.comScroll, function(arg_24_0)
		self:updateNextAward(arg_24_0.y)
	end)
	self:updateAwardPanel()
	self:buildPhaseAwardScrollPos()

	if self.phase == 0 then
		self.comScroll:ScrollTo(0)
	elseif self.phase == #self.awardList then
		self.comScroll:ScrollTo(1)
	else
		self.comScroll:ScrollTo(math.clamp(self.phasePos[self.phase], 0, 1))
	end

	self:updateMapStatus()
	LoadImageSpriteAtlasAsync(Drop.New({
		type = DROP_TYPE_VITEM,
		id = self.ptId
	}):getIcon(), "", self.sliderPt:Find("Text/icon"), true)
	self:updateMapWay()
end

function CrusingScene:willExit()
	for iter_25_0, iter_25_1 in pairs(self.LTDic) do
		if iter_25_1 then
			LeanTween.cancel(iter_25_0)
		end
	end

	local var_25_0 = PoolMgr.GetInstance()

	for iter_25_2, iter_25_3 in ipairs(self.maps) do
		setParent(iter_25_3.rtLine, iter_25_3._tf, true)
		var_25_0:ReturnSpineChar(pg.battlepass_event_pt[self.activity.id].spine_name, go(iter_25_3.rtIcon:Find("model"):GetChild(0)))
		var_25_0:ReturnPrefab("crusingmap/" .. pg.battlepass_event_pt[self.activity.id].crusing_map, "", go(iter_25_3._tf))
	end

	if self.chargeTipWindow then
		self.chargeTipWindow:Destroy()

		self.chargeTipWindow = nil
	end
end

function CrusingScene:setActivity(arg_26_1)
	self.activity = arg_26_1

	for iter_26_0, iter_26_1 in pairs(arg_26_1:GetCrusingInfo()) do
		self[iter_26_0] = iter_26_1
	end
end

function CrusingScene:setPlayer(arg_27_1)
	self.player = arg_27_1
end

function CrusingScene:updateAwardInfo(arg_28_1, arg_28_2)
	local var_28_0 = arg_28_2.pt <= self.pt

	if arg_28_1:Find("mask") then
		setActive(arg_28_1:Find("mask"), not var_28_0)
	end

	setText(arg_28_1:Find("Text"), arg_28_2.id)

	local var_28_1 = Drop.Create(arg_28_2.award)

	updateDrop(arg_28_1:Find("award"), var_28_1)
	setActive(arg_28_1:Find("award/get"), var_28_0 and not self.awardDic[arg_28_2.pt])
	setActive(arg_28_1:Find("award/got"), self.awardDic[arg_28_2.pt])
	setActive(arg_28_1:Find("award/mask"), self.awardDic[arg_28_2.pt])
	onButton(self, arg_28_1:Find("award"), function()
		self:emit(CrusingScene.ON_DROP, var_28_1)
	end, SFX_CONFIRM)

	local var_28_2 = Drop.Create(arg_28_2.award_pay)

	updateDrop(arg_28_1:Find("award_pay"), var_28_2)
	setActive(arg_28_1:Find("award_pay/lock"), not self.isPay)
	setActive(arg_28_1:Find("award_pay/get"), self.isPay and var_28_0 and not self.awardPayDic[arg_28_2.pt])
	setActive(arg_28_1:Find("award_pay/got"), self.awardPayDic[arg_28_2.pt])
	setActive(arg_28_1:Find("award_pay/mask"), not self.isPay or self.awardPayDic[arg_28_2.pt])
	onButton(self, arg_28_1:Find("award_pay"), function()
		self:emit(CrusingScene.ON_DROP, var_28_2)
	end, SFX_CONFIRM)
end

function CrusingScene:updateAwardPanel()
	setText(self.textPhase, self.phase)

	if self.phase < #self.awardList then
		local var_31_0 = self.pt - (self.phase == 0 and 0 or self.awardList[self.phase].pt)

		setSlider(self.sliderPt, 0, self.awardList[self.phase + 1].pt - (self.phase == 0 and 0 or self.awardList[self.phase].pt), self.pt - (self.phase == 0 and 0 or self.awardList[self.phase].pt))
		setText(self.sliderPt:Find("Text"), var_31_0 .. "/" .. self.awardList[self.phase + 1].pt - (self.phase == 0 and 0 or self.awardList[self.phase].pt))
	else
		setSlider(self.sliderPt, 0, 1, 1)
		setText(self.sliderPt:Find("Text"), "MAX")
	end

	self.nextAward = nil

	self.comScroll:SetTotalCount(#self.awardList - 1)
	self:updateNextAward(self.comScroll.value)

	local var_31_1 = #self.activity:GetCrusingUnreceiveAward() > 0

	setActive(self.btnAll, not self.isPay and var_31_1)
	setActive(self.btnPay, not self.isPay)
	setActive(self.rtAward:Find("text_image_3"), not self.isPay)
	setActive(self.btnFinish, self.isPay and self.phase == #self.awardList and not var_31_1)
	setActive(self.btnAfter, self.isPay and not isActive(self.btnFinish))
	setButtonEnabled(self.btnAfter, var_31_1)
end

function CrusingScene:updateMapStatus()
	for iter_32_0, iter_32_1 in ipairs(self.maps) do
		local var_32_0
		local var_32_1 = {}

		eachChild(iter_32_1.rtLine, function(arg_33_0)
			local var_33_0 = tonumber(arg_33_0.name)

			if var_33_0 > self.phase then
				if not var_32_0 then
					var_32_0 = var_33_0

					table.insert(var_32_1, arg_33_0)
					setActive(arg_33_0, true)
				elseif var_33_0 < var_32_0 then
					while #var_32_1 > 0 do
						setActive(table.remove(var_32_1), false)
					end

					var_32_0 = var_33_0

					table.insert(var_32_1, arg_33_0)
					setActive(arg_33_0, true)
				elseif var_32_0 == var_33_0 then
					table.insert(var_32_1, arg_33_0)
					setActive(arg_33_0, true)
				else
					setActive(arg_33_0, false)
				end
			else
				setActive(arg_33_0, true)
			end

			local var_33_1 = var_33_0 > self.phase

			setGray(arg_33_0, not (var_33_0 > self.phase), false)
			setImageAlpha(arg_33_0, var_33_1 and 1 or 0.9)

			if isActive(arg_33_0) then
				local function var_33_3(arg_34_0, arg_34_1)
					local var_34_0 = getImageSprite(arg_34_0)

					if var_34_0 then
						setImageSprite(arg_34_1, var_34_0)
					end

					eachChild(arg_34_0, function(arg_35_0)
						var_33_3(arg_35_0, arg_34_1:Find(arg_35_0.name))
					end)
				end

				local var_33_4 = iter_32_1.rtSimple:Find(var_33_1 and "active" or "gray")

				eachChild(arg_33_0, function(arg_36_0)
					var_33_3(var_33_4:Find(arg_36_0.name), arg_36_0)
				end)
			end
		end)
	end
end

function CrusingScene:updateMapWay()
	if self.exited or self.contextData.frozenMapUpdate then
		return
	end

	local var_37_0 = PlayerPrefs.GetInt(string.format("crusing_%d_phase_display", self.activity.id), 0)

	PlayerPrefs.SetInt(string.format("crusing_%d_phase_display", self.activity.id), self.phase)

	for iter_37_0, iter_37_1 in ipairs(self.maps) do
		local var_37_1 = GetComponent(iter_37_1.rtIcon, typeof(Animator))

		if var_37_0 < self.phase then
			local var_37_2 = self.PhaseFrame[self.phase]

			var_37_1.speed = CrusingScene.PlaySpeed

			var_37_1:Play("empty")
			var_37_1:Play("mix", 0, self.PhaseFrame[var_37_0] / self.AllFrameCount)

			if iter_37_1.rtIcon:Find("model").childCount > 0 then
				SetAction(iter_37_1.rtIcon:Find("model"):GetChild(0), "move")
			end

			local var_37_3

			var_37_3 = LeanTween.delayedCall((self.PhaseFrame[self.phase] - self.PhaseFrame[var_37_0]) / CrusingScene.FrameSpeed / CrusingScene.PlaySpeed, System.Action(function()
				var_37_1.speed = 0

				var_37_1:Play("empty")
				var_37_1:Play("mix", 0, var_37_2 / self.AllFrameCount)

				self.LTDic[var_37_3] = false

				if iter_37_1.rtIcon:Find("model").childCount > 0 then
					SetAction(iter_37_1.rtIcon:Find("model"):GetChild(0), "normal")
				end
			end)).uniqueId
			self.LTDic[nil] = true
		else
			var_37_1.speed = 0

			var_37_1:Play("empty")
			var_37_1:Play("mix", 0, self.PhaseFrame[self.phase] / self.AllFrameCount)
		end
	end
end

function CrusingScene:buildPhaseAwardScrollPos()
	self.phasePos = {}

	for iter_39_0 = 1, #self.awardList - 1 do
		table.insert(self.phasePos, self.comScroll:HeadIndexToValue(iter_39_0 - 1))
	end
end

function CrusingScene:onScroll(arg_40_1, arg_40_2)
	assert(arg_40_2, "callback should exist")
	arg_40_1.onValueChanged:RemoveAllListeners()
	pg.DelegateInfo.Add(self, arg_40_1.onValueChanged)
	arg_40_1.onValueChanged:AddListener(arg_40_2)
end

function CrusingScene:updateNextAward(arg_41_1)
	if not self.phasePos then
		return
	end

	local var_41_0 = self.phasePos[#self.phasePos] - 1
	local var_41_1 = #self.awardList

	for iter_41_0 = #self.awardList - 1, 1, -1 do
		if self.phasePos[iter_41_0] < arg_41_1 + var_41_0 or self.awardList[iter_41_0].pt <= self.pt then
			break
		elseif self.awardList[iter_41_0].isImportent then
			var_41_1 = iter_41_0
		end
	end

	if self.nextAward ~= var_41_1 then
		self.nextAward = var_41_1

		self:updateAwardInfo(self.rtNextAward, self.awardList[var_41_1])
	end
end

function CrusingScene:checkLimitMax(arg_42_1)
	for iter_42_0, iter_42_1 in ipairs(arg_42_1) do
		if iter_42_1.type == DROP_TYPE_RESOURCE then
			if iter_42_1.id == 1 then
				if self.player:GoldMax(iter_42_1.count) then
					pg.TipsMgr.GetInstance():ShowTips(i18n("gold_max_tip_title"))

					return true
				end
			elseif iter_42_1.id == 2 and self.player:OilMax(iter_42_1.count) then
				pg.TipsMgr.GetInstance():ShowTips(i18n("oil_max_tip_title"))

				return true
			end
		elseif iter_42_1.type == DROP_TYPE_ITEM then
			local var_42_0 = Item.getConfigData(iter_42_1.id)

			if var_42_0.type == Item.EXP_BOOK_TYPE then
				if getProxy(BagProxy):getItemCountById(iter_42_1.id) + iter_42_1.count > var_42_0.max_num then
					return true
				end
			end
		end
	end

	return false
end

function CrusingScene:openBuyPanel()
	local var_43_0 = Goods.Create({
		shop_id = self:getPassID()
	}, Goods.TYPE_CHARGE)
	local var_43_2 = {
		isChargeType = true,
		commodity = var_43_0,
		infoTip = var_43_0:GetInfoTip(),
		icon = "chargeicon/" .. var_43_0:getConfig("picture"),
		name = var_43_0:getConfig("name_display"),
		tipExtra = i18n("battlepass_pay_tip"),
		extraItems = var_43_0:GetExtraServiceItem(),
		price = var_43_0:getConfig("money"),
		isLocalPrice = var_43_0:IsLocalPrice(),
		tagType = var_43_0:getConfig("tag"),
		isMonthCard = var_43_0:isMonthCard()
	}

	var_43_2.tipBonus = nil
	var_43_2.bonusItem = nil
	var_43_2.extraDrop = var_43_0:GetExtraDrop()
	var_43_2.descExtra = var_43_0:getConfig("descrip_extra")

	function var_43_2.onYes()
		if ChargeConst.isNeedSetBirth() then
			self:emit(CrusingMediator.EVENT_OPEN_BIRTHDAY)
		else
			pg.m02:sendNotification(GAME.CHARGE_OPERATION, {
				shopId = var_43_0.id
			})
		end
	end

	self:emit(CrusingMediator.EVENT_GO_CHARGE, var_43_2)
end

function CrusingScene:getPassID()
	local var_45_0 = getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_PT_CRUSING)

	if var_45_0 and not var_45_0:isEnd() then
		for iter_45_0, iter_45_1 in ipairs(pg.pay_data_display.all) do
			if pg.pay_data_display[iter_45_1].sub_display and type(pg.pay_data_display[iter_45_1].sub_display) == "table" and pg.pay_data_display[iter_45_1].sub_display[1] == var_45_0.id then
				return iter_45_1
			end
		end
	end
end

function CrusingScene:OnChargeSuccess(arg_46_1)
	self.chargeTipWindow:ExecuteAction("Show", arg_46_1)
end

return CrusingScene
