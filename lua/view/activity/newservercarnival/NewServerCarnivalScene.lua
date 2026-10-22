local NewServerCarnivalScene = class("NewServerCarnivalScene", import("...base.BaseUI"))

NewServerCarnivalScene.TASK_PAGE = 1
NewServerCarnivalScene.SHOP_PAGE = 2
NewServerCarnivalScene.GIFT_PAGE = 3

function NewServerCarnivalScene:getUIName()
	return "NewServerCarnivalUI"
end

function NewServerCarnivalScene:getResource()
	local var_2_0 = {
		"ui/newservershopui_atlas",
		"ui/iconcolorful",
		"weaponframes",
		"chargeicon/1"
	}
	local var_2_1 = {}

	local function var_2_2(arg_3_0)
		if noEmptyStr(arg_3_0) and not table.contains(var_2_1, arg_3_0) then
			table.insert(var_2_1, arg_3_0)
		end
	end

	if pg.newserver_shop_template then
		for iter_2_0, iter_2_1 in ipairs(pg.newserver_shop_template.all or {}) do
			if pg.newserver_shop_template[iter_2_1] then
				var_2_2(pg.newserver_shop_template[iter_2_1].goods_icon)

				if pg.newserver_shop_template[iter_2_1].resource_category and pg.newserver_shop_template[iter_2_1].resource_type then
					var_2_2(Drop.New({
						type = pg.newserver_shop_template[iter_2_1].resource_category,
						id = pg.newserver_shop_template[iter_2_1].resource_type
					}):getIcon())
				end

				var_2_2("chargeicon/" .. (pg.newserver_shop_template[iter_2_1].picture or ""))
			end
		end
	end

	for iter_2_2, iter_2_3 in ipairs(var_2_1) do
		if not table.contains(var_2_0, iter_2_3) then
			table.insert(var_2_0, iter_2_3)
		end
	end

	table.insertto(var_2_0, NewServerCarnivalScene.super.getResource(self))

	return var_2_0
end

function NewServerCarnivalScene:preload(arg_4_1)
	local var_4_0 = {}

	table.insert(var_4_0, function(arg_5_0)
		pg.m02:sendNotification(GAME.GET_NEW_SERVER_SHOP, {
			callback = function(arg_6_0)
				self:SetNewServerShop(arg_6_0)
				arg_5_0()
			end
		})
	end)
	parallelAsync(var_4_0, arg_4_1)
end

function NewServerCarnivalScene:SetNewServerShop(arg_7_1)
	self.newServerShop = arg_7_1
end

function NewServerCarnivalScene:setData()
	local var_8_0 = getProxy(ActivityProxy)
	local var_8_1 = var_8_0:getActivityByType(ActivityConst.ACTIVITY_TYPE_NEWSERVER_TASK)
	local var_8_2 = var_8_0:getActivityByType(ActivityConst.ACTIVITY_TYPE_NEWSERVER_SHOP)
	local var_8_3 = var_8_0:getActivityByType(ActivityConst.ACTIVITY_TYPE_NEWSERVER_GIFT)

	self.taskActivity = var_8_1 and not var_8_1:isEnd() and var_8_1 or nil
	self.shopActivity = var_8_2 and not var_8_2:isEnd() and var_8_2 or nil
	self.giftActivity = var_8_3 and not var_8_3:isEnd() and var_8_3 or nil
	self.player = getProxy(PlayerProxy):getData()
end

function NewServerCarnivalScene:init()
	self.blurPanel = self._tf:Find("blur_panel")
	self.top = self.blurPanel:Find("adapt/top")
	self.resPanel = self.top:Find("res")
	self.backBtn = self.top:Find("back_btn")
	self.helpBtn = self.top:Find("help_btn")
	self.leftPanel = self._tf:Find("left")
	self.timeTF = self.leftPanel:Find("time")
	self.toggles = {
		self.leftPanel:Find("frame/toggle_group/task"),
		self.leftPanel:Find("frame/toggle_group/shop"),
		self.leftPanel:Find("frame/toggle_group/gift")
	}
	self.main = self._tf:Find("main")
	self.pages = {
		self.main:Find("task_container"),
		self.main:Find("shop_container"),
		self.main:Find("gift_container")
	}
	self.newServerTaskPage = NewServerTaskPage.New(self.pages[NewServerCarnivalScene.TASK_PAGE], self.event, self.contextData)
	self.newServerShopPage = NewServerShopPage.New(self.pages[NewServerCarnivalScene.SHOP_PAGE], self.event, self.contextData)

	self.newServerShopPage:SetShop(self.newServerShop)

	self.newServerGiftPage = NewServerGiftPage.New(self.pages[NewServerCarnivalScene.GIFT_PAGE], self.event, self.contextData)
	self.pageDic = {
		[NewServerCarnivalScene.TASK_PAGE] = self.newServerTaskPage,
		[NewServerCarnivalScene.SHOP_PAGE] = self.newServerShopPage,
		[NewServerCarnivalScene.GIFT_PAGE] = self.newServerGiftPage
	}
end

function NewServerCarnivalScene:didEnter()
	onButton(self, self.backBtn, function()
		self:emit(NewServerCarnivalScene.ON_BACK)
	end, SFX_CANCEL)
	onButton(self, self.helpBtn, function()
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			type = MSGBOX_TYPE_HELP,
			helps = pg.gametip.newserver_activity_tip.tip
		})
	end, SFX_PANEL)
	onButton(self, self.resPanel:Find("gem/add_btn"), function()
		local function var_13_0()
			if not pg.m02:hasMediator(NewShopMainMediator.__cname) then
				pg.m02:sendNotification(GAME.GO_SCENE, SCENE.CHARGE, {
					wrap = ChargeScene.TYPE_DIAMOND
				})
			else
				pg.m02:sendNotification(NewServerCarnivalScene.GO_MALL)
			end
		end

		if PLATFORM_CODE == PLATFORM_JP then
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				fontSize = 23,
				yesText = "text_buy",
				content = i18n("word_diamond_tip", self.player:getFreeGem(), self.player:getChargeGem(), self.player:getTotalGem()),
				onYes = var_13_0,
				alignment = TextAnchor.UpperLeft
			})
		else
			var_13_0()
		end
	end, SFX_PANEL)
	self:updateTime()
	setText(self.resPanel:Find("gem/gem_value"), self.player:getTotalGem())

	for iter_10_0, iter_10_1 in ipairs(self.toggles) do
		onToggle(self, iter_10_1, function(arg_15_0)
			self:updateLocalRedDotData(iter_10_0)
			self:updatePages(iter_10_0, arg_15_0)
			setActive(self.resPanel, arg_15_0 and iter_10_0 == NewServerCarnivalScene.GIFT_PAGE)
		end)
	end

	setActive(self.toggles[NewServerCarnivalScene.TASK_PAGE], self.taskActivity)
	setActive(self.toggles[NewServerCarnivalScene.SHOP_PAGE], self.shopActivity)
	setActive(self.toggles[NewServerCarnivalScene.GIFT_PAGE], self.giftActivity)

	local var_10_0 = self.contextData.page

	if not self.contextData.page then
		if self.taskActivity then
			var_10_0 = NewServerCarnivalScene.TASK_PAGE or NewServerCarnivalScene.SHOP_PAGE
		end
	end

	self.page = var_10_0

	triggerToggle(self.toggles[self.page], true)
end

function NewServerCarnivalScene:updateShopDedDot()
	setActive(self.toggles[NewServerCarnivalScene.SHOP_PAGE]:Find("tip"), self.newServerShopPage:isTip())
end

function NewServerCarnivalScene:updatePages(arg_17_1, arg_17_2)
	if self.pageDic[arg_17_1]:isShowing() ~= arg_17_2 then
		if arg_17_2 then
			if arg_17_1 == NewServerCarnivalScene.SHOP_PAGE then
				self.pageDic[arg_17_1]:ExecuteAction("Flush")
			else
				self.pageDic[arg_17_1]:ExecuteAction("Show")
			end
		else
			self.pageDic[arg_17_1]:ExecuteAction("Hide")
		end
	end
end

function NewServerCarnivalScene:updateTips()
	if self.taskActivity then
		setActive(self.toggles[NewServerCarnivalScene.TASK_PAGE]:Find("tip"), self.newServerTaskPage:isTip())
	end

	if self.shopActivity then
		setActive(self.toggles[NewServerCarnivalScene.SHOP_PAGE]:Find("tip"), self.newServerShopPage:isTip())
	end

	if self.giftActivity then
		setActive(self.toggles[NewServerCarnivalScene.GIFT_PAGE]:Find("tip"), self.newServerGiftPage:isTip())
	end
end

function NewServerCarnivalScene:updateLocalRedDotData(arg_19_1)
	if arg_19_1 == NewServerCarnivalScene.SHOP_PAGE then
		if self.newServerShopPage:isTip() and PlayerPrefs.GetInt("newserver_shop_first_" .. self.player.id) == 0 then
			PlayerPrefs.SetInt("newserver_shop_first_" .. self.player.id, 1)
		end
	elseif arg_19_1 == NewServerCarnivalScene.GIFT_PAGE and self.newServerGiftPage:isTip() then
		PlayerPrefs.SetInt("newserver_gift_first_" .. self.player.id, 1)
	end
end

function NewServerCarnivalScene:updateTime()
	local var_20_1 = ((self.taskActivity or nil) and (self.taskActivity.stopTime or self.shopActivity.stopTime)) - pg.TimeMgr.GetInstance():GetServerTime()
	local var_20_2 = math.floor(var_20_1 / 86400)

	setText(self.timeTF, i18n("newserver_time", var_20_2, (math.floor((var_20_1 - var_20_2 * 86400) / 3600))))
	setActive(self.timeTF:Find("title_activity"), self.taskActivity)
	setActive(self.timeTF:Find("title_shop"), not self.taskActivity)
end

function NewServerCarnivalScene:onUpdateTask()
	self.newServerTaskPage:ActionInvoke("onUpdateTask")
	self.newServerShopPage:ActionInvoke("UpdateRes")
	self:updateTips()
end

function NewServerCarnivalScene:onUpdatePlayer(arg_22_1)
	self.player = arg_22_1

	setText(self.resPanel:Find("gem/gem_value"), self.player:getTotalGem())
	self.newServerGiftPage:onUpdatePlayer(arg_22_1)
end

function NewServerCarnivalScene:onUpdateGift()
	self.newServerGiftPage:ActionInvoke("onUpdateGift")
	self:updateTips()
end

function NewServerCarnivalScene:willExit()
	self.newServerTaskPage:Destroy()
	self.newServerShopPage:Destroy()
	self.newServerGiftPage:Destroy()
end

function NewServerCarnivalScene.isShow()
	local var_25_0 = getProxy(ActivityProxy)
	local var_25_1 = var_25_0:getActivityByType(ActivityConst.ACTIVITY_TYPE_NEWSERVER_TASK)
	local var_25_2 = var_25_0:getActivityByType(ActivityConst.ACTIVITY_TYPE_NEWSERVER_SHOP)
	local var_25_3 = var_25_0:getActivityByType(ActivityConst.ACTIVITY_TYPE_NEWSERVER_GIFT)

	return var_25_1 and not var_25_1:isEnd() or var_25_2 and not var_25_2:isEnd() or var_25_3 and not var_25_3:isEnd()
end

function NewServerCarnivalScene.isTip()
	return false
end

return NewServerCarnivalScene
