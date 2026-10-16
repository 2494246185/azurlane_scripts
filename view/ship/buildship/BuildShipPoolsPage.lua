local BuildShipPoolsPage = class("BuildShipPoolsPage", import("...base.BaseSubView"))

function BuildShipPoolsPage:getResource()
	local var_1_0 = {
		"ui/buildshipui_atlas"
	}

	local function var_1_1(arg_2_0)
		if noEmptyStr(arg_2_0) and not table.contains(var_1_0, arg_2_0) then
			table.insert(var_1_0, arg_2_0)
		end
	end

	local function var_1_2(arg_3_0)
		if noEmptyStr(arg_3_0) then
			table.insertto(var_1_0, ResPathSupport.GetPaintingListByPaintingName(arg_3_0))
		end
	end

	local function var_1_3(arg_4_0)
		if noEmptyStr(arg_4_0) then
			var_1_1(ResPathSupport.CombinePath(ResPathSupport.ConstPath.UI.BuildPainting, arg_4_0))
		end
	end

	local var_1_4 = getProxy(ActivityProxy)

	for iter_1_0, iter_1_1 in ipairs(getProxy(BuildShipProxy):GetPools() or {}) do
		local var_1_5 = iter_1_1:getConfigTable()
		local var_1_6 = iter_1_1:IsActivity() and var_1_4:getBuildActivityCfgByID(var_1_5.id) or var_1_4:getNoneActBuildActivityCfgByID(var_1_5.id)

		var_1_1(var_1_6 and var_1_6 and var_1_6.bg or ResPathSupport.CombinePath(ResPathSupport.ConstPath.BG.LoadingBG, "bg_" .. var_1_5.icon))

		local var_1_8 = var_1_4:getBuildPoolActivity(iter_1_1)

		if PLATFORM_CODE == PLATFORM_CH and var_1_8 then
			var_1_3(var_1_8:getConfig("config_client").build_painting)
		end

		if iter_1_1:IsActivity() then
			local var_1_9 = pg.ship_data_create_exchange[iter_1_1:GetActivityId()]

			if var_1_9 and #var_1_9.exchange_ship_id > 0 then
				var_1_2(pg.ship_data_statistics[var_1_9.exchange_ship_id[1]] and pg.ship_skin_template[pg.ship_data_statistics[var_1_9.exchange_ship_id[1]].skin_id] and (pg.ship_data_statistics[var_1_9.exchange_ship_id[1]] and pg.ship_skin_template[pg.ship_data_statistics[var_1_9.exchange_ship_id[1]].skin_id]).painting)
			end
		end
	end

	for iter_1_2, iter_1_3 in ipairs(var_1_4:getActivitiesByType(ActivityConst.ACTIVITY_TYPE_BUILD_FREE)) do
		if not iter_1_3:isEnd() then
			var_1_1(Drop.New({
				type = DROP_TYPE_VITEM,
				id = iter_1_3:getConfig("config_client")[1],
				count = iter_1_3.data1
			}):getConfig("icon"))
		end
	end

	local var_1_10

	if self.contextData then
		var_1_10 = self.contextData.falgShip or getProxy(BayProxy):getShipById(getProxy(PlayerProxy):getData().character)
	end

	var_1_2(var_1_10 and var_1_10:getPainting())

	return table.insertto(var_1_0, BuildShipPoolsPage.super.getResource(self))
end

function BuildShipPoolsPage:getUIName()
	return "BuildShipPoolsPageUI"
end

function BuildShipPoolsPage:RefreshActivityBuildPool(arg_6_1)
	local var_6_0 = underscore.detect(self.pools, function(arg_7_0)
		return arg_7_0:IsActivity() and arg_7_0.activityId == arg_6_1.id
	end)

	if var_6_0 then
		self:UpdateBuildPoolExchange(var_6_0)
		self:UpdateTicket()
	end
end

function BuildShipPoolsPage:RefreshFreeBuildActivity()
	for iter_8_0, iter_8_1 in pairs(self.freeActTimer) do
		iter_8_1:Stop()
	end

	self.freeActTimer = {}

	for iter_8_2, iter_8_3 in ipairs(getProxy(ActivityProxy):getActivitiesByType(ActivityConst.ACTIVITY_TYPE_BUILD_FREE)) do
		if iter_8_3:isEnd() == false then
			self.freeActTimer[iter_8_3.id] = Timer.New(function()
				self:emit(BuildShipMediator.ON_UPDATE_ACT)
			end, iter_8_3.stopTime - pg.TimeMgr.GetInstance():GetServerTime())

			self.freeActTimer[iter_8_3.id]:Start()
		end
	end
end

function BuildShipPoolsPage:RefreshRegularExchangeCount()
	if self.pool then
		self:UpdateRegularBuildPoolExchange(self.pool)
	end
end

function BuildShipPoolsPage:OnLoaded()
	self.quickCount = self._tf:Find("gallery/res_items/item")
	self.useItemTF = self.quickCount:Find("Text")
	self.freeCount = self._tf:Find("gallery/res_items/ticket")
	self.ticketTF = self.freeCount:Find("Text")
	self.patingTF = self._tf:Find("painting")
	self.poolContainer = self._tf:Find("gallery/toggle_bg/bg/toggles")
	self.newTpl = self.poolContainer:Find("new")
	self.newPoolTpls = {
		self.newTpl
	}
	self.specialTpl = self.poolContainer:Find("special")
	self.specialPoolTpls = {
		self.specialTpl
	}
	self.lightTpl = self.poolContainer:Find("light")
	self.lightPoolTpls = {
		self.lightTpl
	}
	self.heavyTpl = self.poolContainer:Find("heavy")
	self.heavyPoolTpls = {
		self.heavyTpl
	}
	self.maskContainer = self._tf:Find("gallery/mask")
	self.buildPoolExchangeTF = self._tf:Find("gallery/exchange_bg")
	self.buildPoolExchangeGetBtn = self.buildPoolExchangeTF:Find("get")
	self.buildPoolExchangeTxt = self.buildPoolExchangeTF:Find("Text"):GetComponent(typeof(Text))
	self.buildPoolExchangeGetBtnMark = self.buildPoolExchangeGetBtn:Find("mark")
	self.buildPoolExchangeGetTxt = self.buildPoolExchangeGetBtn:Find("Text"):GetComponent(typeof(Text))
	self.buildPoolExchangeName = self.buildPoolExchangeTF:Find("name"):GetComponent(typeof(Text))
	self.rtRegularExchange = self._tf:Find("gallery/exchange_ur_bg")

	setText(self.rtRegularExchange:Find("name/Text"), i18n("Normalbuild_URexchange_text1"))
	onButton(self, self.rtRegularExchange:Find("name/icon"), function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = i18n("Normalbuild_URexchange_help")
		})
	end, SFX_PANEL)
	setText(self.rtRegularExchange:Find("count/name"), i18n("Normalbuild_URexchange_text2") .. ":")
	setText(self.rtRegularExchange:Find("show/Text"), i18n("Normalbuild_URexchange_text3"))
	setText(self.rtRegularExchange:Find("get/Text"), i18n("Normalbuild_URexchange_text4"))

	for iter_11_0, iter_11_1 in ipairs({
		self.rtRegularExchange:Find("show"),
		self.rtRegularExchange:Find("get")
	}) do
		onButton(self, iter_11_1, function()
			self:emit(BuildShipMediator.ON_BUILDPOOL_UR_EXCHANGE)
		end, SFX_PANEL)
	end

	self.tipSTxt = self._tf:Find("gallery/bg/type_intro/mask/title"):GetComponent("ScrollText")
	self.tipTime = self._tf:Find("gallery/bg/time_text")
	self.helpBtn = self._tf:Find("gallery/help_btn")
	self.testBtn = self._tf:Find("gallery/test_btn")
	self.prevArr = self._tf:Find("gallery/prev_arr")
	self.nextArr = self._tf:Find("gallery/next_arr")
	self.activityTimer = {}
	self.freeActTimer = {}
end

function BuildShipPoolsPage:OnInit()
	onButton(self, self.quickCount, function()
		shoppingBatch(61008, {
			id = ShopConst.GetShopConfig(61008).effect_args[1]
		}, 9, "build_ship_quickly_buy_stone")
	end)
	onButton(self, self.helpBtn, function()
		self.contextData.helpWindow:ExecuteAction("Show", self.pool:getConfigTable(), nil, self.pool:IsActivity())
	end, SFX_CANCEL)
end

function BuildShipPoolsPage:Flush(arg_17_1, arg_17_2)
	local var_17_0 = getProxy(ActivityProxy)

	self.pools = underscore.filter(arg_17_1, function(arg_18_0)
		local var_18_0 = var_17_0:getBuildPoolActivity(arg_18_0)

		return tobool(arg_17_2) == (var_18_0 and var_18_0:getConfig("type") == ActivityConst.ACTIVITY_TYPE_NEWSERVER_BUILD or false)
	end)

	if #self.pools > 4 then
		self:AdjustToggleContainer()
	end

	local var_17_1 = {}

	self:RemoveAllTimer()
	eachChild(self.poolContainer, function(arg_19_0)
		setActive(arg_19_0, false)
	end)

	for iter_17_0, iter_17_1 in ipairs(self.pools) do
		local var_17_2 = self:GetPoolTpl((iter_17_1:GetMark()))

		setActive(var_17_2, true)

		if iter_17_1:IsActivity() then
			self:AddActivityTimer(iter_17_1)
		end

		local var_17_3 = var_17_2:Find("frame")

		removeOnToggle(var_17_3)
		triggerToggle(var_17_3, false)
		onToggle(self, var_17_3, function(arg_20_0)
			if arg_20_0 then
				self:SwitchPool(iter_17_1)
			end
		end, SFX_PANEL)

		var_17_1[iter_17_1:GetPoolId()] = var_17_2
	end

	table.sort(self.pools, function(arg_21_0, arg_21_1)
		local var_21_0 = arg_21_0:GetSortCode()
		local var_21_1 = arg_21_1:GetSortCode()

		if var_21_0 == var_21_1 then
			return arg_21_0:GetPoolId() > arg_21_1:GetPoolId()
		else
			return var_21_1 < var_21_0
		end
	end)

	for iter_17_2, iter_17_3 in ipairs(self.pools) do
		var_17_1[iter_17_3:GetPoolId()]:SetAsFirstSibling()
	end

	triggerToggle(var_17_1[self:GetActivePool(self:ActivePool(), BuildShipScene.buildShipActPoolId):GetPoolId()]:Find("frame"), true)

	self.contextData.projectName = nil

	scrollTo(self.poolContainer.parent, 0, 1)
	self:RefreshFreeBuildActivity()
	self:UpdateItem(self.contextData.itemVO.count)
	onNextTick(function()
		self:UpdateArr(#self.pools)
	end)
end

local function var_0_1(arg_23_0)
	local var_23_0 = _.select(arg_23_0.pools, function(arg_24_0)
		return arg_24_0:GetMark() == BuildShipPool.BUILD_POOL_MARK_NEW
	end)

	table.sort(var_23_0, function(arg_25_0, arg_25_1)
		return arg_25_0:GetPoolId() < arg_25_1:GetPoolId()
	end)

	return var_23_0[1]
end

function BuildShipPoolsPage:GetActivePool(arg_26_1, arg_26_2)
	if not arg_26_1 then
		return nil
	end

	return arg_26_1 == BuildShipPool.BUILD_POOL_MARK_NEW and (_.detect(self.pools, function(arg_27_0)
		return arg_27_0:GetPoolId() == arg_26_2
	end) or var_0_1(self)) or _.detect(self.pools, function(arg_28_0)
		return arg_28_0:GetMark() == arg_26_1
	end) or self.pools[1]
end

function BuildShipPoolsPage:AdjustToggleContainer()
	if not self.isInit then
		local var_29_0 = self.poolContainer.parent

		SetParent(self.poolContainer.parent, self.maskContainer)

		var_29_0.sizeDelta, var_29_0.localScale = self.poolContainer.parent.sizeDelta * (1 + (1 - 0.85)), Vector3(0.85, 0.85, 1)

		local var_29_1 = self.poolContainer:GetComponent(typeof(HorizontalLayoutGroup))

		var_29_1.padding.left = 60
		var_29_1.padding.right = 60
		var_29_1.padding.top = 0
		self.isInit = true
	end
end

function BuildShipPoolsPage:UpdateArr(arg_30_1)
	if arg_30_1 <= 4 then
		setActive(self.prevArr, false)
		setActive(self.nextArr, false)

		return
	end

	local var_30_0 = getBounds(self.maskContainer)
	local var_30_1 = self.poolContainer:GetChild(0)
	local var_30_2 = self.poolContainer:GetChild(self.poolContainer.childCount - 1)

	onScroll(self, self.poolContainer.parent, function(arg_31_0)
		local var_31_0 = getBounds(var_30_1)
		local var_31_1 = getBounds(var_30_2)

		setActive(self.prevArr, arg_31_0.x > 0.01)
		setActive(self.nextArr, arg_31_0.x < 0.99)
	end)
	onButton(self, self.prevArr, function()
		scrollTo(self.poolContainer.parent, 0, 1)
	end, SFX_PANEL)
	onButton(self, self.nextArr, function()
		scrollTo(self.poolContainer.parent, 1, 1)
	end, SFX_PANEL)
end

function BuildShipPoolsPage:GetPoolTpl(arg_34_1)
	assert(self[arg_34_1 .. "PoolTpls"])

	if #self[arg_34_1 .. "PoolTpls"] <= 0 then
		local var_34_0 = Object.Instantiate(self[arg_34_1 .. "Tpl"], self.poolContainer).transform

		var_34_0:SetSiblingIndex(self[arg_34_1 .. "Tpl"]:GetSiblingIndex() + 1)

		return var_34_0
	else
		return table.remove(self[arg_34_1 .. "PoolTpls"], 1)
	end
end

function BuildShipPoolsPage:ActivePool()
	local var_35_0 = _.any(self.pools, function(arg_36_0)
		return arg_36_0:IsActivity()
	end)
	local var_35_1 = getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_BUILD)

	if self.contextData.activity and self.contextData.activity > 0 then
		self.contextData.projectName = BuildShipPool.BUILD_POOL_MARK_NEW

		local var_35_2 = getProxy(ActivityProxy):getActivityById(self.contextData.activity)

		if var_35_2 and not var_35_2:isEnd() then
			BuildShipScene.buildShipActPoolId = var_35_2:getConfig("config_id")
		end
	end

	local var_35_3

	if self.contextData.projectName then
		var_35_3 = self.contextData.projectName
	elseif BuildShipScene.projectName then
		var_35_3 = BuildShipScene.projectName == BuildShipPool.BUILD_POOL_MARK_NEW and not var_35_0 and BuildShipPool.BUILD_POOL_MARK_HEAVY or BuildShipScene.projectName
	elseif var_35_0 then
		var_35_3 = BuildShipPool.BUILD_POOL_MARK_NEW
	elseif var_35_1 and not var_35_1:isEnd() then
		local var_35_4 = var_35_1:getConfig("config_client").id
		local var_35_5 = _.detect(self.pools, function(arg_37_0)
			return arg_37_0.id == var_35_4
		end)

		var_35_3 = var_35_5 and var_35_5:GetMark() or BuildShipPool.BUILD_POOL_MARK_HEAVY
	else
		var_35_3 = self.contextData.projectName or BuildShipScene.projectName or BuildShipPool.BUILD_POOL_MARK_HEAVY
	end

	if not underscore.any(self.pools, function(arg_38_0)
		return arg_38_0:GetMark() == var_35_3
	end) then
		return self.pools[1]:GetMark()
	else
		return var_35_3
	end
end

function BuildShipPoolsPage:UpdateItem(arg_39_1)
	setText(self.useItemTF, arg_39_1)
	Canvas.ForceUpdateCanvases()
end

function BuildShipPoolsPage:UpdateTicket()
	local var_40_0 = getProxy(ActivityProxy)
	local var_40_1 = var_40_0:getBuildFreeActivityByBuildId(self.pool.id)

	if var_40_1 and not var_40_1:isEnd() then
		local var_40_2 = Drop.New({
			type = DROP_TYPE_VITEM,
			id = var_40_1:getConfig("config_client")[1],
			count = var_40_1.data1
		})

		setActive(self.freeCount:Find("tip"), var_40_1.stopTime - pg.TimeMgr.GetInstance():GetServerTime() < 259200 and var_40_2.count > 0)
		LoadImageSpriteAtlasAsync(var_40_2:getConfig("icon"), "", self.freeCount:Find("icon"))
		setText(self.ticketTF, var_40_1.data1)
		onButton(self, self.freeCount, function()
			self:emit(BaseUI.ON_DROP, var_40_2)
		end, SFX_PANEL)

		local var_40_3 = self._tf:Find("gallery/item_bg/ticket")

		LoadImageSpriteAtlasAsync(var_40_2:getConfig("icon"), "", var_40_3:Find("icon"))
		setText(var_40_3:Find("name"), var_40_2:getConfig("name"))
		setText(var_40_3:Find("tip"), i18n("build_ticket_description"))
	end

	local var_40_4 = checkExist(var_40_0:getBuildPoolActivity(self.pool), {
		"getConfig",
		{
			"type"
		}
	}) == ActivityConst.ACTIVITY_TYPE_NEWSERVER_BUILD

	setText(self._tf:Find("gallery/prints/intro/text"), var_40_4 and i18n("newserver_build_tip") or i18n("build_pools_intro"))
	setActive(self.freeCount, tobool(var_40_1))
	setActive(self.quickCount, not var_40_4)

	self.useTicket = var_40_4 or var_40_1 and var_40_1.data1 > 0

	setActive(self._tf:Find("gallery/item_bg/item"), not self.useTicket)
	setActive(self._tf:Find("gallery/item_bg/gold"), not self.useTicket)
	setActive(self._tf:Find("gallery/item_bg/ticket"), self.useTicket)
end

function BuildShipPoolsPage:SwitchPool(arg_42_1)
	self.pool = arg_42_1
	self.buildPainting = nil

	local var_42_0 = getProxy(ActivityProxy)
	local var_42_1 = var_42_0:getBuildPoolActivity(arg_42_1)

	if PLATFORM_CODE == PLATFORM_CH and var_42_1 then
		self.buildPainting = var_42_1:getConfig("config_client").build_painting
	end

	setActive(self.tipTime, var_42_1 and var_42_1:isVariableTime())

	if isActive(self.tipTime) then
		local var_42_2 = pg.TimeMgr.GetInstance()

		setText(self.tipTime, var_42_2:STimeDescC(var_42_1:getStartTime(), "%Y.%m.%d") .. " - " .. var_42_2:STimeDescC(var_42_1.stopTime, "%m.%d %H:%M"))
	end

	local var_42_3 = arg_42_1:GetMark()

	self._tf:Find("gallery/bg/type"):GetComponent(typeof(Image)).sprite = GetSpriteFromAtlas("ui/BuildShipUI_atlas", "sub_title_" .. var_42_3)

	local var_42_4 = arg_42_1:getConfigTable()
	local var_42_5 = arg_42_1:IsActivity() and var_42_0:getBuildActivityCfgByID(var_42_4.id) or var_42_0:getNoneActBuildActivityCfgByID(var_42_4.id)

	setText(self._tf:Find("gallery/bg/act_time"), arg_42_1:IsActivity() and not arg_42_1:IsNewServerBuild() and arg_42_1:GetActivityTimeStr() or "")

	local var_42_7 = LoadSprite((HXSet.HxPath((var_42_5 or nil) and (var_42_5.bg or "loadingbg/bg_" .. var_42_4.icon))))

	self.tipSTxt:SetText(var_42_5 and var_42_5.buildship_tip and HXSet.hxLan(var_42_5 and var_42_5.buildship_tip) or i18n("buildship_" .. var_42_3 .. "_tip"))

	self._tf:Find("gallery/bg"):GetComponent(typeof(Image)).sprite = var_42_7

	setText(self._tf:Find("gallery/item_bg/item/Text"), var_42_4.number_1)
	setText(self._tf:Find("gallery/item_bg/gold/Text"), var_42_4.use_gold)
	self:UpdateBuildPoolExchange(arg_42_1)
	self:UpdateRegularBuildPoolExchange(arg_42_1)
	self:UpdateTicket()
	self:UpdateTestBtn(arg_42_1)
	self:UpdateBuildPoolPaiting(arg_42_1)

	local var_42_8 = {}

	if arg_42_1:getConfig("exchange_count") > 0 then
		table.insert(var_42_8, function(arg_43_0)
			if getProxy(BuildShipProxy):getRegularExchangeCount() >= pg.ship_data_create_exchange[REGULAR_BUILD_POOL_EXCHANGE_ID].exchange_request then
				if PlayerPrefs.GetString("REGULAR_BUILD_MAX_TIP", "") == pg.TimeMgr.GetInstance():CurrentSTimeDesc("%Y/%m/%d") then
					arg_43_0()

					goto label_43_0
				end
			end

			do
				local var_43_0 = pg.MsgboxMgr.GetInstance()

				local function var_43_1(arg_44_0)
					PlayerPrefs.SetString("REGULAR_BUILD_MAX_TIP", (arg_44_0 or nil) and (pg.TimeMgr.GetInstance():CurrentSTimeDesc("%Y/%m/%d") or ""))
				end

				var_43_0:ShowMsgBox({
					showStopRemind = true,
					content = i18n("Normalbuild_URexchange_warning3"),
					stopRamindContent = i18n("dont_remind_today"),
					onYes = function()
						var_43_1(var_43_0.stopRemindToggle.isOn)
						arg_43_0()
					end,
					onNo = function()
						var_43_1(var_43_0.stopRemindToggle.isOn)
					end
				})
			end

			::label_43_0::
		end)
	end

	onButton(self, self._tf:Find("gallery/start_btn"), function()
		seriesAsync(var_42_8, function()
			local var_48_0 = self.useTicket and var_42_0:getBuildFreeActivityByBuildId(self.pool.id) or nil
			local var_48_1

			if self.useTicket and (not var_48_0 or var_48_0:isEnd()) then
				pg.TipsMgr.GetInstance():ShowTips(i18n("common_activity_end"))

				do return end

				var_48_1 = self.useTicket and {
					buildType = "ticket",
					itemVO = Item.New({
						id = var_48_0:getConfig("config_client")[1],
						count = var_48_0.data1
					}),
					buildPool = var_42_4,
					max = MAX_BUILD_WORK_COUNT - self.contextData.startCount,
					onConfirm = function(arg_49_0)
						if arg_42_1:IsActivity() then
							self:emit(BuildShipMediator.ACT_ON_BUILD, arg_42_1:GetActivityId(), var_42_4.id, arg_49_0, true)
						else
							self:emit(BuildShipMediator.ON_BUILD, var_42_4.id, arg_49_0, true)
						end
					end
				} or {
					buildType = "base",
					player = self.contextData.player,
					itemVO = self.contextData.itemVO,
					buildPool = var_42_4,
					max = MAX_BUILD_WORK_COUNT - self.contextData.startCount,
					onConfirm = function(arg_50_0)
						if arg_42_1:IsActivity() then
							self:emit(BuildShipMediator.ACT_ON_BUILD, arg_42_1:GetActivityId(), var_42_4.id, arg_50_0)
						else
							self:emit(BuildShipMediator.ON_BUILD, var_42_4.id, arg_50_0)
						end
					end
				}
			end

			self.contextData.msgbox:ExecuteAction("Show", var_48_1)
		end)
	end, SFX_UI_BUILDING_STARTBUILDING)

	BuildShipScene.projectName = var_42_3

	if arg_42_1:IsActivity() then
		BuildShipScene.buildShipActPoolId = arg_42_1:GetPoolId()
	end
end

local function var_0_2(arg_51_0)
	if not arg_51_0:IsActivity() then
		return false
	end

	local var_51_0 = pg.ship_data_create_exchange[arg_51_0:GetActivityId()]

	return var_51_0 and #var_51_0.exchange_ship_id > 0
end

function BuildShipPoolsPage:UpdateBuildPoolPaiting(arg_52_1)
	local var_52_0

	if self.buildPainting then
		var_52_0 = self.buildPainting
	elseif var_0_2(arg_52_1) then
		local var_52_1 = pg.ship_data_statistics[pg.ship_data_create_exchange[arg_52_1:GetActivityId()].exchange_ship_id[1]]

		assert(var_52_1)

		var_52_0 = pg.ship_skin_template[var_52_1.skin_id].painting
	else
		var_52_0 = self.contextData.falgShip:getPainting()
	end

	if self.painting ~= var_52_0 then
		local function var_52_2()
			self.painting = var_52_0

			self:Hx4Channel()
		end

		self:RevertHxChannel()

		if self.buildPainting then
			setBuildPaintingPrefabAsync(self.patingTF, var_52_0, "build", var_52_2)
		else
			setPaintingPrefabAsync(self.patingTF, var_52_0, "build", var_52_2)
		end
	end
end

local function var_0_3(arg_54_0)
	local var_54_0 = arg_54_0.patingTF:Find("fitter")

	if var_54_0.childCount <= 0 then
		return nil
	end

	local var_54_1 = var_54_0:GetChild(0)

	if IsNil(var_54_1) then
		return nil
	end

	return (var_54_1:Find("build_hx_ch" .. pg.SdkMgr.GetInstance():GetChannelUIDIncludeHarmony()))
end

function BuildShipPoolsPage:Hx4Channel()
	local var_55_0 = var_0_3(self)

	if not IsNil(var_55_0) then
		setActive(var_55_0, HXSet.isHx())
	end
end

function BuildShipPoolsPage:RevertHxChannel()
	local var_56_0 = var_0_3(self)

	if not IsNil(var_56_0) then
		setActive(var_56_0, false)
	end
end

function BuildShipPoolsPage:UpdateBuildPoolExchange(arg_57_1)
	local var_57_0
	local var_57_1
	local var_57_2

	if arg_57_1:IsActivity() then
		local var_57_3 = pg.ship_data_create_exchange[arg_57_1:GetActivityId()]

		if var_57_3 then
			var_57_0 = var_57_3.exchange_request
			var_57_1 = var_57_3.exchange_available_times
			var_57_2 = var_57_3.exchange_ship_id[1]
		end
	end

	local var_57_4 = var_57_0 and var_57_0 > 0 and var_57_1 and var_57_1 > 0

	if var_57_0 and var_57_0 > 0 and var_57_1 and var_57_1 > 0 then
		local var_57_5 = arg_57_1:GetActivity()
		local var_57_6 = var_57_5.data1
		local var_57_7 = var_57_5.data2
		local var_57_8 = math.min(var_57_1, var_57_5.data2 + 1) * var_57_0

		self.buildPoolExchangeTxt.text = i18n("build_count_tip") .. "<color=#FFDF48>" .. var_57_5.data1 .. "</color>/" .. var_57_8

		local var_57_9 = var_57_7 < var_57_1 and var_57_8 <= var_57_6

		setActive(self.buildPoolExchangeGetBtnMark, var_57_7 < var_57_1 and var_57_8 <= var_57_6)

		self.buildPoolExchangeGetTxt.text = var_57_7 .. "/" .. var_57_1
		self.buildPoolExchangeName.text = SwitchSpecialChar(pg.ship_data_statistics[var_57_2].name, true)

		local var_57_10 = pg.ship_data_statistics[var_57_2].rarity

		eachChild(self.buildPoolExchangeTF:Find("bg"), function(arg_58_0)
			setActive(arg_58_0, arg_58_0.name == tostring(var_57_10))
		end)
		onButton(self, self.buildPoolExchangeTF, function()
			if var_57_9 then
				self:emit(BuildShipMediator.ON_BUILDPOOL_EXCHANGE, var_57_5.id)
			end
		end, SFX_PANEL)
		setGray(self.buildPoolExchangeGetBtn, not var_57_9, true)
		setButtonEnabled(self.buildPoolExchangeTF, var_57_9)
	else
		removeOnButton(self.buildPoolExchangeTF)
	end

	setActive(self.buildPoolExchangeTF, var_57_4)
end

function BuildShipPoolsPage:UpdateRegularBuildPoolExchange(arg_60_1)
	local var_60_0 = arg_60_1:getConfig("exchange_count") > 0

	setActive(self.rtRegularExchange, var_60_0)

	if var_60_0 then
		local var_60_1 = getProxy(BuildShipProxy):getRegularExchangeCount()
		local var_60_2 = pg.ship_data_create_exchange[REGULAR_BUILD_POOL_EXCHANGE_ID]

		setText(self.rtRegularExchange:Find("count/Text"), "<color=#FFDF48>" .. var_60_1 .. "</color>/" .. pg.ship_data_create_exchange[REGULAR_BUILD_POOL_EXCHANGE_ID].exchange_request)
		setActive(self.rtRegularExchange:Find("show"), var_60_1 < var_60_2.exchange_request)
		setActive(self.rtRegularExchange:Find("get"), var_60_1 >= var_60_2.exchange_request)
	end
end

function BuildShipPoolsPage:UpdateTestBtn(arg_61_1)
	local var_61_0 = false

	if PLATFORM_CODE ~= PLATFORM_JP and arg_61_1:IsActivity() and not arg_61_1:IsEnd() then
		local var_61_1 = arg_61_1:GetStageId()

		if var_61_1 then
			var_61_0 = true

			onButton(self, self.testBtn, function()
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					content = i18n("juese_tiyan"),
					onYes = function()
						self:emit(BuildShipMediator.SIMULATION_BATTLE, var_61_1)
					end
				})
			end, SFX_PANEL)
		end
	end

	setActive(self.testBtn, var_61_0)
end

function BuildShipPoolsPage:AddActivityTimer(arg_64_1)
	self:RemoveActivityTimer(arg_64_1)

	if arg_64_1:IsActivity() then
		local var_64_0 = arg_64_1:GetActivity()

		assert(var_64_0)

		self.activityTimer[arg_64_1.id] = Timer.New(function()
			self:RemoveActivityTimer(arg_64_1)
			self:emit(BuildShipMediator.ON_UPDATE_ACT)
		end, var_64_0.stopTime - pg.TimeMgr.GetInstance():GetServerTime(), 1)

		self.activityTimer[arg_64_1.id]:Start()
	end
end

function BuildShipPoolsPage:RemoveActivityTimer(arg_66_1)
	if self.activityTimer[arg_66_1.id] then
		self.activityTimer[arg_66_1.id]:Stop()

		self.activityTimer[arg_66_1.id] = nil
	end
end

function BuildShipPoolsPage:RemoveAllTimer()
	for iter_67_0, iter_67_1 in pairs(self.activityTimer) do
		iter_67_1:Stop()
	end

	self.activityTimer = {}

	for iter_67_2, iter_67_3 in pairs(self.freeActTimer) do
		iter_67_3:Stop()
	end

	self.freeActTimer = {}
end

function BuildShipPoolsPage:ShowOrHide(arg_68_1)
	if arg_68_1 then
		self:Show()
	else
		self:Hide()
	end
end

function BuildShipPoolsPage:OnDestroy()
	self:RevertHxChannel()
	self:RemoveAllTimer()

	self.activityTimer = nil
end

return BuildShipPoolsPage
