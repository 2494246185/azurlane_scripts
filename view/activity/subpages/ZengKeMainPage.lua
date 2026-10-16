local ZengKeMainPage = class("ZengKeMainPage", import("...base.BaseActivityPage"))
local var_0_1 = 71151
local var_0_3 = 50013

function ZengKeMainPage:OnInit()
	ZengKeMainPage.super.OnInit(self)

	self.bg = self:findTF("AD")
	self.btnList = self:findTF("btn_list", self.bg)
	self.build_bgtime = self.bg:Find("btn_list/build/build_bgtime")
	self.build_time = self.bg:Find("btn_list/build/build_bgtime/time")
	self.shop_bgtime = self.bg:Find("btn_list/shop/shop_bgtime")
	self.shop_time = self.bg:Find("btn_list/shop/shop_bgtime/time")
	self.Manual = self.bg:Find("Manual")

	SetActive(self.build_bgtime, false)
	SetActive(self.shop_bgtime, false)
end

function ZengKeMainPage:findTF(arg_2_1, arg_2_2)
	return findTF(arg_2_2 or self._tf, arg_2_1)
end

function ZengKeMainPage:OnDataSetting()
	self.timeMgr = pg.TimeMgr.GetInstance()
end

function ZengKeMainPage:OnFirstFlush()
	onButton(self, self.Manual, function()
		self:emit(ActivityMediator.ON_ADD_SUBLAYER, (Context.New({
			mediator = MedalAlbumTemplateMediator,
			viewComponent = CamouflageCityMedalAlbumView
		})))
	end)
	self:updateUI()
	eachChild(self.btnList, function(arg_6_0)
		self.btnFuncList[arg_6_0.name](arg_6_0)
	end)
end

function ZengKeMainPage:OnUpdateFlush()
	self:updateUI()
end

function ZengKeMainPage:updateUI()
	local var_8_0, var_8_1 = self.timeMgr:inTime(ShopConst.GetShopConfig(var_0_1).time)
	local var_8_2

	if var_8_1 then
		var_8_2 = ZengKeMainPage:skinCommdityTimeStamps((self.timeMgr:Table2ServerTime(var_8_1)))
	end

	setActive(self.shop_bgtime, var_8_2 and var_8_2 ~= 0)
	setText(self.shop_time, var_8_2)

	local var_8_3, var_8_4 = self.timeMgr:inTime(pg.activity_template[var_0_3].time)
	local var_8_5

	if var_8_4 then
		var_8_5 = ZengKeMainPage:skinCommdityTimeStamps((self.timeMgr:Table2ServerTime(var_8_4)))
	end

	setActive(self.build_bgtime, var_8_5 and var_8_5 ~= 0)
	setText(self.build_time, i18n("tolovemainpage_build_countdown"))

	local var_8_6 = self.activity:getConfig("config_client")

	self.btnFuncList = {
		shop = function(arg_9_0)
			onButton(self, arg_9_0, function()
				if var_8_2 == nil then
					pg.TipsMgr.GetInstance():ShowTips(i18n("common_activity_end"))

					return
				end

				self:emit(ActivityMediator.GO_CHANGE_SHOP)
			end)
		end,
		build = function(arg_11_0)
			onButton(self, arg_11_0, function()
				if var_8_5 == nil then
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
				self:emit(ActivityMediator.ON_BOSSRUSH_MAP)
			end)
		end
	}
end

function ZengKeMainPage:skinCommdityTimeStamps(arg_15_1)
	local var_15_0 = math.max(arg_15_1 - pg.TimeMgr.GetInstance():GetServerTime(), 0)

	if math.floor(var_15_0 / 86400) > 0 then
		return 0
	else
		local var_15_1 = math.floor(var_15_0 / 3600)

		if var_15_1 > 0 then
			return var_15_1 .. i18n("word_hour")
		else
			local var_15_2 = math.floor(var_15_0 / 60)

			if var_15_2 > 0 then
				return var_15_2 .. i18n("word_minute")
			else
				return var_15_0 .. i18n("word_second")
			end
		end
	end
end

return ZengKeMainPage
