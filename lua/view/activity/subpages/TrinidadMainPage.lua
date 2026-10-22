local TrinidadMainPage = class("TrinidadMainPage", import("...base.BaseActivityPage"))
local var_0_1 = 71136

function TrinidadMainPage:OnInit()
	self.bg = self:findTF("AD")
	self.btn_list = self.bg:Find("btn_list")
	self.buildbtn = self:findTF("build", self.btn_list)
	self.build_bgtime = self:findTF("build_bgtime", self.buildbtn)
	self.build_time = self:findTF("time", self.build_bgtime)
	self.fightbtn = self:findTF("fight", self.btn_list)
	self.shopbtn = self:findTF("shop", self.btn_list)
	self.shop_bgtime = self:findTF("shop_bgtime", self.shopbtn)
	self.shop_time = self:findTF("time", self.shop_bgtime)
	self.Manual = self:findTF("Manual", self.bg)

	SetActive(self.build_bgtime, false)
	SetActive(self.shop_bgtime, false)
end

function TrinidadMainPage:findTF(arg_2_1, arg_2_2)
	return findTF(arg_2_2 or self._tf, arg_2_1)
end

function TrinidadMainPage:OnDataSetting()
	self.timeMgr = pg.TimeMgr.GetInstance()
end

function TrinidadMainPage:OnFirstFlush()
	onButton(self, self.Manual, function()
		self:emit(ActivityMediator.ON_ADD_SUBLAYER, (Context.New({
			mediator = MedalAlbumTemplateMediator,
			viewComponent = TowerRoseMedalAlbumView
		})))
	end)
	self:updateUI()
end

function TrinidadMainPage:OnUpdateFlush()
	self:updateUI()
end

function TrinidadMainPage:updateUI()
	local var_7_0, var_7_1 = self.timeMgr:inTime(ShopConst.GetShopConfig(var_0_1).time)
	local var_7_2

	if var_7_1 then
		var_7_2 = TrinidadMainPage:TimeStamps((self.timeMgr:Table2ServerTime(var_7_1)))
	end

	if var_7_2 and var_7_2 ~= 0 then
		setActive(self.shop_bgtime, true)
		setText(self.shop_time, var_7_2)
	else
		setActive(self.shop_bgtime, false)
	end

	onButton(self, self.shopbtn, function()
		if var_7_2 == nil then
			pg.TipsMgr.GetInstance():ShowTips(i18n("common_activity_end"))

			return
		end

		self:emit(ActivityMediator.GO_CHANGE_SHOP)
	end)

	buildLastTime = TrinidadMainPage:skinCommdityTimeStamps(self.activity.stopTime)

	setActive(self.build_bgtime, buildLastTime and buildLastTime ~= 0)
	setText(self.build_time, i18n("tolovemainpage_build_countdown"))
	onButton(self, self.buildbtn, function()
		if buildLastTime == nil then
			pg.TipsMgr.GetInstance():ShowTips(i18n("common_activity_end"))

			return
		end

		self:emit(ActivityMediator.EVENT_GO_SCENE, SCENE.GETBOAT, {
			page = BuildShipScene.PAGE_BUILD,
			projectName = BuildShipScene.PROJECTS.ACTIVITY
		})
	end)
	onButton(self, self.fightbtn, function()
		self:emit(ActivityMediator.BATTLE_OPERA)
	end)
end

function TrinidadMainPage:skinCommdityTimeStamps(arg_11_1)
	local var_11_0 = math.max(arg_11_1 - pg.TimeMgr.GetInstance():GetServerTime(), 0)

	if math.floor(var_11_0 / 86400) > 0 then
		return 0
	else
		local var_11_1 = math.floor(var_11_0 / 3600)

		if var_11_1 > 0 then
			return i18n("shop_new_during_hour", var_11_1)
		else
			local var_11_2 = math.floor(var_11_0 / 60)

			if var_11_2 > 0 then
				return i18n("shop_new_during_minite", var_11_2)
			end
		end
	end
end

function TrinidadMainPage:TimeStamps(arg_12_1)
	local var_12_0 = math.max(arg_12_1 - pg.TimeMgr.GetInstance():GetServerTime(), 0)

	if math.floor(var_12_0 / 86400) > 0 then
		return 0
	else
		local var_12_1 = math.floor(var_12_0 / 3600)

		if var_12_1 > 0 then
			return i18n("time_remaining_tip") .. var_12_1 .. i18n("word_hour")
		else
			local var_12_2 = math.floor(var_12_0 / 60)

			if var_12_2 > 0 then
				return i18n("time_remaining_tip") .. var_12_2 .. i18n("word_minute")
			else
				return i18n("time_remaining_tip") .. var_12_0 .. i18n("word_second")
			end
		end
	end
end

return TrinidadMainPage
