local WorldCruiseScene = class("WorldCruiseScene", import("view.base.BaseUI"))

WorldCruiseScene.optionsPath = {
	"top/home"
}
WorldCruiseScene.PAGE_AWARD = "award"
WorldCruiseScene.PAGE_TASK = "task"
WorldCruiseScene.PAGE_SHOP = "shop"

local var_0_1 = WorldCruiseScene.PAGE_AWARD

function WorldCruiseScene:getUIName()
	return "WorldCruiseUI"
end

function WorldCruiseScene:getResource()
	local var_2_0 = getProxy(ActivityProxy):getAliveActivityByType(ActivityConst.ACTIVITY_TYPE_PT_CRUSING)

	local function var_2_1(arg_4_0)
		if not arg_4_0 or arg_4_0.type ~= DROP_TYPE_SKIN then
			return {}
		end

		return ResPathSupport.GetPaintingSquareIconListByPaintingName(pg.ship_skin_template[arg_4_0.id].painting)
	end

	local function var_2_2(arg_5_0)
		if not arg_5_0 or arg_5_0.type ~= DROP_TYPE_SKIN then
			return {}
		end

		return ResPathSupport.MergeLuaArr(ResPathSupport.GetPaintingListByPaintingName(pg.ship_skin_template[arg_5_0.id].painting), (ResPathSupport.GetPaintingFaceListByPaintingName(pg.ship_skin_template[arg_5_0.id].painting)))
	end

	return ResPathSupport.MergeLuaArr(WorldCruiseScene.super.getResource(self), {
		"ui/WorldCruiseUI",
		"ui/WorldCruiseAwardPage",
		"ui/WorldCruiseTaskPage",
		"ui/WorldCruiseShopPage",
		"ui/iconcolorful",
		"ui/worldcruiseui_atlas",
		"ui/item_duang5",
		"weaponframes"
	}, (function()
		local var_3_0 = {}

		if pg.battlepass_event_pt[var_2_0.id] then
			if noEmptyStr(pg.battlepass_event_pt[var_2_0.id].bg) then
				table.insert(var_3_0, ResPathSupport.CombinePath(ResPathSupport.ConstPath.BG.Base, pg.battlepass_event_pt[var_2_0.id].bg))
			end

			if noEmptyStr(pg.battlepass_event_pt[var_2_0.id].bg_tips) then
				table.insert(var_3_0, ResPathSupport.CombinePath(ResPathSupport.ConstPath.BG.Base, pg.battlepass_event_pt[var_2_0.id].bg_tips))
			end
		end

		return var_3_0
	end)(), (function()
		local var_6_0 = {}

		for iter_6_0, iter_6_1 in ipairs(var_2_0:GetCrusingInfo().awardList or {}) do
			for iter_6_2, iter_6_3 in ipairs({
				iter_6_1.award,
				iter_6_1.award_pay
			}) do
				if iter_6_3 then
					local var_6_1 = Drop.Create(iter_6_3)

					if var_6_1.type == DROP_TYPE_SKIN then
						table.insertto(var_6_0, var_2_1(var_6_1))
					end
				end
			end
		end

		return var_6_0
	end)(), (function()
		local var_7_0 = {}

		for iter_7_0, iter_7_1 in ipairs(var_2_0:getConfig("config_data") or {}) do
			if pg.battlepass_task_group[iter_7_1] then
				for iter_7_2, iter_7_3 in ipairs(pg.battlepass_task_group[iter_7_1].task_group or {}) do
					for iter_7_4, iter_7_5 in ipairs(iter_7_3 or {}) do
						local var_7_2

						if pg.task_data_template[iter_7_5] then
							::label_7_0::

							var_7_2 = pg.task_data_template[iter_7_5].award_display and pg.task_data_template[iter_7_5].award_display[1]
						end

						local var_7_3 = Drop.Create(var_7_2)

						if var_7_3.type == DROP_TYPE_SKIN then
							table.insertto(var_7_0, var_2_1(var_7_3))
						end
					end
				end
			end
		end

		return var_7_0
	end)(), (function()
		local var_8_0 = {}
		local var_8_1 = pg.TimeMgr.GetInstance()

		for iter_8_0, iter_8_1 in ipairs({
			ShopArgs.CruiseSkin
		}) do
			for iter_8_2, iter_8_3 in ipairs(pg.shop_template.get_id_list_by_genre[iter_8_1] or {}) do
				if pg.shop_template[iter_8_3] and var_8_1:inTime(pg.shop_template[iter_8_3].time) then
					local var_8_3 = Goods.Create({
						groupCount = 0,
						buy_count = 0,
						shop_id = iter_8_3
					}, Goods.TYPE_CRUISE):getDropInfo()

					if var_8_3 and var_8_3.type == DROP_TYPE_SKIN then
						table.insertto(var_8_0, var_2_2(var_8_3))
					end
				end
			end
		end

		return var_8_0
	end)())
end

function WorldCruiseScene:preload(arg_9_1)
	local var_9_0 = getProxy(ShopsProxy)

	local function var_9_1()
		self.shop = CruiseShop.New(var_9_0:GetNormalList(), (var_9_0:GetNormalGroupList()))

		var_9_0:SetCruiseShop(self.shop)
		arg_9_1()
	end

	if var_9_0:ShouldRefreshChargeList() then
		pg.m02:sendNotification(GAME.GET_CHARGE_LIST, {
			callback = var_9_1
		})
	else
		var_9_1()
	end
end

function WorldCruiseScene:setShop(arg_11_1)
	self.shop = arg_11_1
end

function WorldCruiseScene:setPlayer(arg_12_1)
	self.player = arg_12_1
end

function WorldCruiseScene:setActivity(arg_13_1)
	self.activity = arg_13_1

	for iter_13_0, iter_13_1 in pairs(arg_13_1:GetCrusingInfo()) do
		self[iter_13_0] = iter_13_1
	end

	self.contextData.phase = self.phase
end

function WorldCruiseScene:init()
	self.topUI = self._tf:Find("top")
	self.titleTF = self.topUI:Find("title/Text")
	self.helpBtn = self.topUI:Find("help")
	self.gemResBtn = self.topUI:Find("res/gem")
	self.gemValue = self.gemResBtn:Find("Text"):GetComponent(typeof(Text))
	self.ticketResBtn = self.topUI:Find("res/ticket")
	self.ticketValue = self.ticketResBtn:Find("Text"):GetComponent(typeof(Text))
	self.dayTxt = self.topUI:Find("day/Text"):GetComponent(typeof(Text))
	self.phaseTF = self._tf:Find("frame/phase")

	setText(self.phaseTF:Find("progress"), i18n("cruise_phase_title"))

	self.pages = {
		[WorldCruiseScene.PAGE_AWARD] = WorldCruiseAwardPage.New(self._tf:Find("frame/award_container"), self.event, self.contextData),
		[WorldCruiseScene.PAGE_TASK] = WorldCruiseTaskPage.New(self._tf:Find("frame/task_container"), self.event, self.contextData),
		[WorldCruiseScene.PAGE_SHOP] = WorldCruiseShopPage.New(self._tf:Find("frame/shop_container"), self.event, self.contextData)
	}
	self.togglesTF = self._tf:Find("frame/toggles")

	eachChild(self.togglesTF, function(arg_15_0)
		onButton(self, arg_15_0, function()
			self.contextData.page = arg_15_0.name

			self:SwitchPage()
		end, SFX_PANEL)
	end)

	local var_14_0 = #self.shop:GetCommodities() == 0
	local var_14_1 = self.togglesTF:Find("shop")

	if var_14_0 then
		onButton(self, var_14_1, function()
			pg.TipsMgr.GetInstance():ShowTips(i18n("cruise_shop_no_open"))
		end, SFX_PANEL)
	end

	setActive(var_14_1:Find("lock"), var_14_0)
	setText(var_14_1:Find("lock/Text"), i18n("cruise_shop_no_open"))

	self.contextData.windowForCharge = WorldCruiseChargePage.New(self._tf, self.event)
	self.contextData.prevChargePage = WorldCruiseChargePage4PrevPeriod.New(self._tf, self.event)

	self:Hx4Channel()
end

function WorldCruiseScene:didEnter()
	LoadImageSpriteAtlasAsync("bg/" .. pg.battlepass_event_pt[self.activity.id].bg, "", self._tf:Find("bg/bg_1"), true)

	local var_18_0 = self._tf:Find("bg/bg_2")

	if pg.battlepass_event_pt[self.activity.id].bg_tips ~= "" then
		LoadImageSpriteAtlasAsync("bg/" .. pg.battlepass_event_pt[self.activity.id].bg_tips, "", var_18_0, true)
		setActive(var_18_0, true)
	else
		setActive(var_18_0, false)
	end

	onButton(self, self.topUI:Find("back"), function()
		self:closeView()
	end, SFX_CANCEL)
	onButton(self, self.helpBtn, function()
		pg.NewStyleMsgboxMgr.GetInstance():Show(pg.NewStyleMsgboxMgr.TYPE_COMMON_HELP, {
			helps = i18n("battlepass_main_help_" .. pg.battlepass_event_pt[self.activity.id].map_name)
		})
	end, SFX_PANEL)
	onButton(self, self.gemResBtn, function()
		pg.playerResUI:ClickGem()
	end, SFX_PANEL)
	onButton(self, self.ticketResBtn, function()
		shoppingBatchNewStyle(Goods.CRUISE_QUICK_TASK_TICKET_ID, {
			id = Item.QUICK_TASK_PASS_TICKET_ID
		}, 20, "build_ship_quickly_buy_stone")
	end, SFX_PANEL)

	local var_18_1 = self.activity.stopTime - pg.TimeMgr.GetInstance():GetServerTime()

	self.dayTxt.text = i18n("battlepass_main_time_title") .. i18n("battlepass_main_time", math.floor(var_18_1 / 86400), math.floor(var_18_1 % 86400 / 3600))

	self:UpdateRes()
	self:UpdatePhase()
	self:UpdateAwardTip()
	triggerButton(self.togglesTF:Find(self.contextData.page or var_0_1))
end

function WorldCruiseScene:UpdateRes()
	self.gemValue.text = self.player:getTotalGem()
	self.ticketValue.text = getProxy(BagProxy):getItemCountById(Item.QUICK_TASK_PASS_TICKET_ID)
end

function WorldCruiseScene:UpdatePhase()
	setText(self.phaseTF:Find("Text"), "<size=27>lv.</size>" .. self.phase)

	if self.phase < #self.awardList then
		local var_24_0 = self.pt - (self.phase == 0 and 0 or self.awardList[self.phase].pt)

		setSlider(self.phaseTF:Find("slider"), 0, self.awardList[self.phase + 1].pt - (self.phase == 0 and 0 or self.awardList[self.phase].pt), self.pt - (self.phase == 0 and 0 or self.awardList[self.phase].pt))
		setText(self.phaseTF:Find("progress/Text"), var_24_0 .. "/" .. self.awardList[self.phase + 1].pt - (self.phase == 0 and 0 or self.awardList[self.phase].pt))
	else
		setSlider(self.phaseTF:Find("slider"), 0, 1, 1)
		setText(self.phaseTF:Find("progress/Text"), "MAX")
	end

	self.contextData.phase = self.phase
end

function WorldCruiseScene:OnChargeSuccess(arg_25_1, arg_25_2)
	if self.contextData.prevChargePage:GetLoaded() then
		self.contextData.prevChargePage:ExecuteAction("ShowUnlockWindow", arg_25_1, arg_25_2)
	else
		self.contextData.windowForCharge:ExecuteAction("ShowUnlockWindow", arg_25_1, arg_25_2)
	end
end

function WorldCruiseScene:UpdateAwardTip()
	setActive(self.togglesTF:Find("award/tip"), #self.activity:GetCrusingUnreceiveAward() > 0)
end

function WorldCruiseScene:SwitchPage()
	for iter_27_0, iter_27_1 in pairs(self.pages) do
		if iter_27_0 == self.contextData.page then
			iter_27_1:ExecuteAction("Flush")
		else
			iter_27_1:ExecuteAction("Hide")
		end
	end

	eachChild(self.togglesTF, function(arg_28_0)
		setActive(arg_28_0:Find("unselected"), arg_28_0.name ~= self.contextData.page)
		setActive(arg_28_0:Find("selected"), arg_28_0.name == self.contextData.page)
	end)

	local var_27_0 = self.contextData.page == WorldCruiseScene.PAGE_SHOP

	setActive(self._tf:Find("shop_bg"), self.contextData.page == WorldCruiseScene.PAGE_SHOP)
	setActive(self.phaseTF, not var_27_0)
	setText(self.titleTF, var_27_0 and i18n("cruise_shop_title") or i18n("cruise_title_" .. pg.battlepass_event_pt[self.activity.id].map_name))
end

function WorldCruiseScene:UpdateView()
	self.pages[self.contextData.page]:ExecuteAction("Flush")
end

function WorldCruiseScene:UpdateAwardPage()
	self:UpdateAwardTip()
	self.pages[WorldCruiseScene.PAGE_AWARD]:ExecuteAction("UpdateActivity", self.activity)
end

function WorldCruiseScene:UpdateTaskPage()
	self.pages[WorldCruiseScene.PAGE_TASK]:ExecuteAction("UpdateActivity", self.activity)
end

function WorldCruiseScene:UpdateShopPage()
	self.pages[WorldCruiseScene.PAGE_SHOP]:ExecuteAction("UpdateShop", self.shop)
	self:UpdateView()
end

function WorldCruiseScene:onBackPressed()
	if self.contextData.windowForCharge and self.contextData.windowForCharge:GetLoaded() and self.contextData.windowForCharge:isShowing() then
		self.contextData.windowForCharge:Hide()

		return
	end

	if self.contextData.prevChargePage and self.contextData.prevChargePage:GetLoaded() and self.contextData.prevChargePage:isShowing() then
		self.contextData.prevChargePage:Hide()

		return
	end

	WorldCruiseScene.super.onBackPressed(self)
end

function WorldCruiseScene:willExit()
	if self.contextData.windowForCharge then
		self.contextData.windowForCharge:Destroy()

		self.contextData.windowForCharge = nil
	end

	if self.contextData.prevChargePage then
		self.contextData.prevChargePage:Destroy()

		self.contextData.prevChargePage = nil
	end

	for iter_34_0, iter_34_1 in pairs(self.pages) do
		iter_34_1:Destroy()

		iter_34_1 = nil
	end
end

local function var_0_2(arg_35_0)
	return (arg_35_0._tf:Find("bg/bg_1/hx_ch" .. pg.SdkMgr.GetInstance():GetChannelUIDIncludeHarmony()))
end

function WorldCruiseScene:Hx4Channel()
	local var_36_0 = var_0_2(self)

	if not IsNil(var_36_0) then
		setActive(var_36_0, HXSet.isHx())
	end
end

return WorldCruiseScene
