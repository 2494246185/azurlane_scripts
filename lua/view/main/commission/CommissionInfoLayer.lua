local CommissionInfoLayer = class("CommissionInfoLayer", import("...base.BaseUI"))

function CommissionInfoLayer:getUIName()
	if getProxy(SettingsProxy):IsMellowStyle() then
		return "CommissionInfoUI4Mellow"
	else
		return "CommissionInfoUI"
	end
end

function CommissionInfoLayer:getResource()
	local function var_2_0(arg_3_0, arg_3_1)
		if noEmptyStr(arg_3_1) and not table.contains(arg_3_0, arg_3_1) then
			table.insert(arg_3_0, arg_3_1)
		end
	end

	return ResPathSupport.MergeLuaArr({
		"ui/commissioninfoui4mellow",
		"ui/commissioninfoui",
		"ui/CommissionInfoUI4Mellow_atlas",
		"ui/commissioninfoui_atlas"
	}, (function()
		local var_4_0 = {}

		table.insert(var_4_0, Item.getConfigData((getProxy(NavalAcademyProxy):GetClassVO():GetResourceType())).icon)

		return var_4_0
	end)(), ((function()
		local var_5_0 = {}
		local var_5_1 = {}

		local function var_5_2(arg_6_0)
			var_2_0(var_5_0, arg_6_0)
		end

		local function var_5_3(arg_7_0)
			for iter_7_0, iter_7_1 in ipairs(arg_7_0 or {}) do
				var_5_2(iter_7_1)
			end
		end

		local function var_5_4(arg_8_0)
			var_5_3(ResPathSupport.GetPaintingSquareIconListByPaintingName(arg_8_0:getPainting()))
			var_5_3(ResPathSupport.GetPaintingShipYardIconListByPaintingName(arg_8_0:getPainting()))
			var_5_2(string.format(ResPathSupport.ConstPath.BG.ShipCard, arg_8_0:rarity2bgPrint()))

			local var_8_0, var_8_1 = arg_8_0:GetFrameAndEffect()

			var_5_2(ResPathSupport.CombinePath(ResPathSupport.ConstPath.UI.Effect, var_8_1))
		end

		local function var_5_5(arg_9_0)
			Drop.Change(arg_9_0)

			if arg_9_0.type == DROP_TYPE_SHIP then
				var_5_4(Ship.New({
					configId = arg_9_0.id,
					skin_id = arg_9_0.skinId,
					propose = arg_9_0.propose
				}))
			else
				var_5_2(arg_9_0:getIcon())
			end
		end

		local function var_5_6(arg_10_0)
			var_5_2("eventtype/" .. arg_10_0.template.icon)

			for iter_10_0, iter_10_1 in ipairs(arg_10_0.template.ship_type or {}) do
				var_5_1[iter_10_1] = true
			end

			for iter_10_2, iter_10_3 in ipairs(arg_10_0.template.drop_display or {}) do
				var_5_5({
					type = iter_10_3.type,
					id = iter_10_3.id,
					count = iter_10_3.nums
				})
			end

			local var_10_0

			if arg_10_0.template.special_drop and arg_10_0.template.special_drop.type then
				var_5_5({
					type = arg_10_0.template.special_drop.type,
					id = arg_10_0.template.special_drop.id,
					count = arg_10_0.template.special_drop.nums
				})

				var_10_0 = arg_10_0:getShipList() or {}
			end

			for iter_10_4, iter_10_5 in ipairs(var_10_0) do
				var_5_4(iter_10_5)
			end
		end

		var_5_2("ui/EventUI")
		var_5_2("ui/eventui_atlas")
		var_5_2("ui/ShipExpUI")
		var_5_2("ui/proposeshipcard")
		var_5_2("battlescore/grade_label_task_complete")

		local var_5_7 = getProxy(EventProxy)

		for iter_5_0, iter_5_1 in ipairs(var_5_7:getEventList() or {}) do
			var_5_6(iter_5_1)
		end

		local var_5_8 = getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_COLLECTION_EVENT)

		if var_5_8 and not var_5_8:isEnd() then
			var_5_6(var_5_7:GetEventByActivityId(var_5_8.id))
		end

		for iter_5_2, iter_5_3 in pairs(getProxy(BayProxy):getRawData() or {}) do
			if var_5_1[iter_5_3:getShipType()] and not iter_5_3:isActivityNpc() then
				var_5_4(iter_5_3)
			end
		end

		return var_5_0
	end)()))
end

function CommissionInfoLayer:init()
	self.frame = self._tf:Find("frame")
	self.parentTr = self._tf.parent
	self.resourcesTF = self.frame:Find("resources")
	self.oilTF = self.resourcesTF:Find("canteen/bubble/Text"):GetComponent(typeof(Text))
	self.goldTF = self.resourcesTF:Find("merchant/bubble/Text"):GetComponent(typeof(Text))
	self.classTF = self.resourcesTF:Find("class/bubble/Text"):GetComponent(typeof(Text))
	self.classLockTF = self.resourcesTF:Find("class/lock")
	self.oilbubbleTF = self.resourcesTF:Find("canteen/bubble")
	self.goldbubbleTF = self.resourcesTF:Find("merchant/bubble")
	self.classbubbleTF = self.resourcesTF:Find("class/bubble")
	self.oilbubbleCG = GetOrAddComponent(self.oilbubbleTF, typeof(CanvasGroup))
	self.goldbubbleCG = GetOrAddComponent(self.goldbubbleTF, typeof(CanvasGroup))
	self.classbubbleCG = GetOrAddComponent(self.classbubbleTF, typeof(CanvasGroup))

	local var_11_0 = getProxy(NavalAcademyProxy):GetClassVO()

	self.classbubbleTF:Find("icon").GetComponent(var_11_0, typeof(Image)).sprite = LoadSprite(Item.getConfigData((var_11_0:GetResourceType())).icon)
	self.projectContainer = self.frame:Find("main/content")
	self.items = {
		CommissionInfoEventItem.New(self._tf:Find("frame/main/content/event"), self),
		CommissionInfoClassItem.New(self._tf:Find("frame/main/content/class"), self),
		CommissionInfoTechnologyItem.New(self._tf:Find("frame/main/content/technology"), self),
		CommissionInfoChapterAutoItem.New(self._tf:Find("frame/main/content/chapterauto"), self)
	}

	self:BlurPanel()

	self.linkBtnPanel = self._tf:Find("frame/link_btns/btns")
	self.activityInsBtn = self._tf:Find("frame/link_btns/btns/ins")
	self.activtyUrExchangeBtn = self._tf:Find("frame/link_btns/btns/urEx")
	self.activtyUrExchangeTxt = self._tf:Find("frame/link_btns/btns/urEx/Text"):GetComponent(typeof(Text))
	self.activtyUrExchangeCG = self.activtyUrExchangeBtn:GetComponent(typeof(CanvasGroup))
	self.activtyUrExchangeTip = self._tf:Find("frame/link_btns/btns/urEx/tip")
	self.activityCrusingBtn = self._tf:Find("frame/link_btns/btns/crusing")
	self.metaBossBtn = CommissionMetaBossBtn.New(self._tf:Find("frame/link_btns/btns/meta_boss"), self.event)
end

function CommissionInfoLayer:BlurPanel()
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
end

function CommissionInfoLayer:UnBlurPanel()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf, self.parentTr)
end

function CommissionInfoLayer:UpdataClassUnlock()
	setActive(self.classLockTF, not pg.SystemOpenMgr.GetInstance():isOpenSystem(self.playerVO.level, "ClassMediator"))
end

function CommissionInfoLayer:UpdateUrItemEntrance()
	if pg.SystemOpenMgr.GetInstance():isOpenSystem(self.playerVO.level, "FragmentShop") and not LOCK_UR_SHIP then
		local var_15_0 = pg.gameset.urpt_chapter_max.description[2]
		local var_15_1 = getProxy(BagProxy):GetLimitCntById(pg.gameset.urpt_chapter_max.description[1])

		self.activtyUrExchangeTxt.text = var_15_1 .. "/" .. pg.gameset.urpt_chapter_max.description[2]
		self.activtyUrExchangeCG.alpha = var_15_1 == var_15_0 and 0.6 or 1

		setActive(self.activtyUrExchangeTip, NotifyTipHelper.ShouldShowUrTip())
		onButton(self, self.activtyUrExchangeBtn, function()
			self:emit(CommissionInfoMediator.ON_UR_ACTIVITY)
		end, SFX_PANEL)
	else
		setActive(self.activtyUrExchangeBtn, false)
	end
end

function CommissionInfoLayer:updateCrusingEntrance()
	local var_17_0 = getProxy(ActivityProxy):getAliveActivityByType(ActivityConst.ACTIVITY_TYPE_PT_CRUSING)

	if var_17_0 and not var_17_0:isEnd() then
		setActive(self.activityCrusingBtn, true)

		local var_17_1 = var_17_0:GetCrusingInfo()
		local var_17_2 = math.floor((var_17_0.stopTime - pg.TimeMgr.GetInstance():GetServerTime()) / 86400)

		if var_17_2 <= pg.gameset.world_cruise_due_days.key_value then
			setActive(self.activityCrusingBtn:Find("LastDay"), true)
			setText(self.activityCrusingBtn:Find("LastDay/text"), i18n("guild_left_supply_day", var_17_2))
		else
			setActive(self.activityCrusingBtn:Find("LastDay"), false)
		end

		setText(self.activityCrusingBtn:Find("Text"), var_17_1.phase .. "/" .. #var_17_1.awardList)
		setActive(self.activityCrusingBtn:Find("tip"), #var_17_0:GetCrusingUnreceiveAward() > 0)
	else
		setActive(self.activityCrusingBtn, false)
	end

	onButton(self, self.activityCrusingBtn, function()
		self:emit(CommissionInfoMediator.ON_CRUSING)
	end, SFX_PANEL)
end

function CommissionInfoLayer:NotifyIns()
	setActive(self.activityInsBtn, false)
end

function CommissionInfoLayer:UpdateLinkPanel()
	local var_20_0 = false

	for iter_20_0 = 1, self.linkBtnPanel.childCount do
		if isActive(self.linkBtnPanel:GetChild(iter_20_0 - 1)) then
			var_20_0 = true

			break
		end
	end

	setActive(self.linkBtnPanel.parent, var_20_0)
end

function CommissionInfoLayer:didEnter()
	onButton(self, self.oilbubbleTF, function()
		if not getProxy(PlayerProxy):getRawData():CanGetResource(PlayerConst.ResOil) then
			pg.TipsMgr.GetInstance():ShowTips(i18n("player_harvestResource_error_fullBag"))

			return
		end

		self:PlayGetResAnimation(self.oilbubbleTF, function()
			self:emit(CommissionInfoMediator.GET_OIL_RES)
		end)
	end, SFX_PANEL)
	onButton(self, self.goldbubbleTF, function()
		if not getProxy(PlayerProxy):getRawData():CanGetResource(PlayerConst.ResGold) then
			pg.TipsMgr.GetInstance():ShowTips(i18n("player_harvestResource_error_fullBag"))

			return
		end

		self:PlayGetResAnimation(self.goldbubbleTF, function()
			self:emit(CommissionInfoMediator.GET_GOLD_RES)
		end)
	end, SFX_PANEL)
	onButton(self, self.classbubbleTF, function()
		if not getProxy(NavalAcademyProxy):GetClassVO():CanGetRes() then
			pg.TipsMgr.GetInstance():ShowTips(i18n("player_harvestResource_error_fullBag"))

			return
		end

		self:PlayGetResAnimation(self.classbubbleTF, function()
			self:emit(CommissionInfoMediator.GET_CLASS_RES)
		end)
	end, SFX_PANEL)
	onButton(self, self._tf, function()
		if self.contextData.inFinished then
			return
		end

		self.isPaying = true

		self:PlayUIAnimation(self._tf, "exit", function()
			self:emit(CommissionInfoLayer.ON_CLOSE)

			self.isPaying = false
		end)
	end, SOUND_BACK)
	onButton(self, self.classLockTF, function()
		pg.TipsMgr.GetInstance():ShowTips(i18n("no_open_system_tip", pg.open_systems_limited[9].name, pg.open_systems_limited[9].level))
	end, SFX_PANEL)
	self:InitItems()
	self:UpdataClassUnlock()
	self:UpdateUrItemEntrance()
	self:updateCrusingEntrance()
	self.metaBossBtn:Flush()
end

function CommissionInfoLayer:PlayGetResAnimation(arg_31_1, arg_31_2)
	self.isPaying = true

	local var_31_0 = arg_31_1:GetComponent(typeof(DftAniEvent))

	var_31_0:SetEndEvent(nil)
	var_31_0:SetEndEvent(function()
		var_31_0:SetEndEvent(nil)
		arg_31_2()

		self.isPaying = false
	end)
	arg_31_1:GetComponent(typeof(Animation)):Play("anim_commission_bubble_get")
end

function CommissionInfoLayer:InitItems()
	for iter_33_0, iter_33_1 in ipairs(self.items) do
		iter_33_1:Init()
	end
end

function CommissionInfoLayer:OnUpdateEventInfo()
	self.items[1]:Update()
end

function CommissionInfoLayer:OnUpdateClass()
	self.items[2]:Update()
end

function CommissionInfoLayer:OnUpdateTechnology()
	self.items[3]:Update()
end

function CommissionInfoLayer:OnUpdateChapterAuto()
	self.items[4]:Update()
end

function CommissionInfoLayer:setPlayer(arg_38_1)
	self.playerVO = arg_38_1

	self:UpdateOilRes(arg_38_1)
	self:UpdateGoldRes(arg_38_1)
	self:UpdateClassRes()
end

function CommissionInfoLayer:OnPlayerUpdate(arg_39_1)
	if arg_39_1.oilField ~= self.playerVO.oilField then
		self:UpdateOilRes(arg_39_1)
	end

	if arg_39_1.goldField ~= self.playerVO.goldField then
		self:UpdateGoldRes(arg_39_1)
	end

	if arg_39_1.expField ~= self.playerVO.expField then
		self:UpdateClassRes()
	end

	self.playerVO = arg_39_1
end

function CommissionInfoLayer:UpdateOilRes(arg_40_1)
	self.oilbubbleCG.alpha = 1
	self.oilbubbleTF.localScale = Vector3.one

	setActive(self.oilbubbleTF, arg_40_1.oilField ~= 0)

	self.oilTF.text = arg_40_1.oilField
end

function CommissionInfoLayer:UpdateGoldRes(arg_41_1)
	self.goldbubbleCG.alpha = 1
	self.goldbubbleTF.localScale = Vector3.one

	setActive(self.goldbubbleTF, arg_41_1.goldField ~= 0)

	self.goldTF.text = arg_41_1.goldField
end

function CommissionInfoLayer:UpdateClassRes()
	local var_42_0 = getProxy(NavalAcademyProxy):GetClassVO():GetGenResCnt()

	self.classbubbleCG.alpha = 1
	self.classbubbleTF.localScale = Vector3.one

	setActive(self.classbubbleTF, var_42_0 > 0)

	self.classTF.text = var_42_0
end

function CommissionInfoLayer:onBackPressed()
	pg.CriMgr.GetInstance():PlaySoundEffect_V3(SFX_CANCEL)
	triggerButton(self._tf)
end

function CommissionInfoLayer:willExit()
	self:UnBlurPanel()

	for iter_44_0, iter_44_1 in ipairs(self.items) do
		iter_44_1:Dispose()
	end

	self.items = nil

	self.metaBossBtn:Dispose()

	self.metaBossBtn = nil
end

return CommissionInfoLayer
