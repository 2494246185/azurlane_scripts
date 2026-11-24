local HeLanMainPage = class("HeLanMainPage", import("...base.BaseActivityPage"))
local var_0_1 = 71132
local var_0_3 = 5901

function HeLanMainPage:OnInit()
	HeLanMainPage.super.OnInit(self)

	self.bg = self:findTF("AD")
	self.btnList = self.bg:Find("btn_list")
	self.build_bgtime = self.bg:Find("btn_list/build/build_bgtime")
	self.build_time = self.bg:Find("btn_list/build/build_bgtime/time")
	self.shop_bgtime = self.bg:Find("btn_list/shop/shop_bgtime")
	self.shop_time = self.bg:Find("btn_list/shop/shop_bgtime/time")
	self.Manual = self.bg:Find("Manual")

	SetActive(self.build_bgtime, false)
	SetActive(self.shop_bgtime, false)
end

function HeLanMainPage:findTF(arg_2_1, arg_2_2)
	return findTF(arg_2_2 or self._tf, arg_2_1)
end

function HeLanMainPage:OnDataSetting()
	self.timeMgr = pg.TimeMgr.GetInstance()
end

function HeLanMainPage:OnFirstFlush()
	onButton(self, self.Manual, function()
		self:emit(ActivityMediator.EVENT_GO_SCENE, SCENE.WORLD_COLLECTION, {
			page = WorldMediaCollectionScene.PAGE_ALBUM
		})
	end)
	self:updateUI()
	eachChild(self.btnList, function(arg_6_0)
		self.btnFuncList[arg_6_0.name](arg_6_0)
	end)
end

function HeLanMainPage:OnUpdateFlush()
	self:updateUI()
end

function HeLanMainPage:updateUI()
	local var_8_1, var_8_2 = self.timeMgr:inTime(ShopConst.GetShopConfig(var_0_1).time)
	local var_8_3

	if var_8_2 then
		var_8_3 = HeLanMainPage:skinCommdityTimeStamps((self.timeMgr:Table2ServerTime(var_8_2)))
	end

	local var_8_4, var_8_5 = self.timeMgr:inTime(pg.activity_template[var_0_3].time)
	local var_8_6 = 0

	if var_8_5 then
		var_8_6 = HeLanMainPage:skinCommdityTimeStamps((self.timeMgr:Table2ServerTime(var_8_5)))
	end

	if var_8_3 and var_8_3 ~= 0 then
		setActive(self.shop_bgtime, true)
		setText(self.shop_time, var_8_3)
	else
		setActive(self.shop_bgtime, false)
	end

	if var_8_6 and var_8_6 ~= 0 then
		setActive(self.build_bgtime, true)
		setText(self.build_time, i18n("tolovemainpage_build_countdown"))
	else
		setActive(self.build_bgtime, false)
	end

	local var_8_7 = self.activity:getConfig("config_client")

	self.btnFuncList = {
		shop = function(arg_9_0)
			onButton(self, arg_9_0, function()
				if var_8_3 == nil then
					pg.TipsMgr.GetInstance():ShowTips(i18n("common_activity_end"))

					return
				end

				self:emit(ActivityMediator.GO_CHANGE_SHOP)
			end)
		end,
		build = function(arg_11_0)
			onButton(self, arg_11_0, function()
				if var_8_6 == nil then
					pg.TipsMgr.GetInstance():ShowTips(i18n("common_activity_end"))

					return
				end

				self:emit(ActivityMediator.EVENT_GO_SCENE, SCENE.GETBOAT, {
					page = BuildShipScene.PAGE_BUILD,
					projectName = BuildShipScene.PROJECTS.ACTIVITY
				})
			end)
		end,
		fight = function(arg_13_0)
			onButton(self, arg_13_0, function()
				self:emit(ActivityMediator.BATTLE_OPERA)
			end)
		end
	}
end

function HeLanMainPage:skinCommdityTimeStamps(arg_15_1)
	local var_15_0 = math.max(arg_15_1 - pg.TimeMgr.GetInstance():GetServerTime(), 0)

	if math.floor(var_15_0 / 86400) > 0 then
		return 0
	else
		local var_15_1 = math.floor(var_15_0 / 3600)

		if var_15_1 > 0 then
			return i18n("time_remaining_tip") .. var_15_1 .. i18n("word_hour")
		else
			local var_15_2 = math.floor(var_15_0 / 60)

			if var_15_2 > 0 then
				return i18n("time_remaining_tip") .. var_15_2 .. i18n("word_minute")
			else
				return i18n("time_remaining_tip") .. var_15_0 .. i18n("word_second")
			end
		end
	end
end

return HeLanMainPage
