local SecretsAbyssMainPage = class("SecretsAbyssMainPage", import("view.activity.CorePage.CoreActivityPage"))
local var_0_1 = 71165

function SecretsAbyssMainPage:OnInit()
	self.AD = self:findTF("bg")
	self.list = self:findTF("list", self.AD)
	self.build = self:findTF("build", self.list)
	self.build_bgtime = self:findTF("time_bg", self.build)
	self.build_time = self:findTF("time", self.build_bgtime)
	self.fight = self:findTF("fight", self.list)
	self.shop = self:findTF("shop", self.list)
	self.shop_bgtime = self:findTF("time_bg", self.shop)
	self.shop_time = self:findTF("time", self.shop_bgtime)
	self.Manual = self:findTF("Manual", self.AD)

	SetActive(self.build_bgtime, false)
	SetActive(self.shop_bgtime, false)
end

function SecretsAbyssMainPage:findTF(arg_2_1, arg_2_2)
	return findTF(arg_2_2 or self._tf, arg_2_1)
end

function SecretsAbyssMainPage:OnDataSetting()
	self.timeMgr = pg.TimeMgr.GetInstance()
end

function SecretsAbyssMainPage:OnFirstFlush()
	onButton(self, self.Manual, function()
		self:emit(ActivityMediator.ON_ADD_SUBLAYER, (Context.New({
			mediator = MedalAlbumTemplateMediator,
			viewComponent = MassenaMedalAlbumView
		})))
	end)
	self:updateUI()
end

function SecretsAbyssMainPage:OnUpdateFlush()
	self:updateUI()
end

function SecretsAbyssMainPage:updateUI()
	local var_7_0, var_7_1 = self.timeMgr:inTime(ShopConst.GetShopConfig(var_0_1).time)
	local var_7_2

	if var_7_1 then
		var_7_2 = SecretsAbyssMainPage:skinCommdityTimeStamps((self.timeMgr:Table2ServerTime(var_7_1)))
	end

	setActive(self.shop_bgtime, var_7_2 and var_7_2 ~= 0)
	setText(self.shop_time, var_7_2)

	buildLastTime = SecretsAbyssMainPage:skinCommdityTimeStamps(self.activity.stopTime)

	setActive(self.build_bgtime, buildLastTime and buildLastTime ~= 0)
	setText(self.build_time, i18n("tolovemainpage_build_countdown"))
	onButton(self, self.shop, function()
		if var_7_2 == nil then
			pg.TipsMgr.GetInstance():ShowTips(i18n("common_activity_end"))

			return
		end

		self:emit(ActivityMediator.GO_CHANGE_SHOP)
	end)
	onButton(self, self.build, function()
		if buildLastTime == nil then
			pg.TipsMgr.GetInstance():ShowTips(i18n("common_activity_end"))

			return
		end

		self:emit(ActivityMediator.EVENT_GO_SCENE, SCENE.GETBOAT, {
			page = BuildShipScene.PAGE_BUILD,
			projectName = BuildShipScene.PROJECTS.ACTIVITY
		})
	end)
	onButton(self, self.fight, function()
		self:emit(ActivityMediator.BATTLE_OPERA)
	end)
end

function SecretsAbyssMainPage:skinCommdityTimeStamps(arg_11_1)
	local var_11_0 = math.max(arg_11_1 - pg.TimeMgr.GetInstance():GetServerTime(), 0)

	if math.floor(var_11_0 / 86400) > 0 then
		return 0
	else
		local var_11_1 = math.floor(var_11_0 / 3600)

		if var_11_1 > 0 then
			return var_11_1 .. i18n("word_hour")
		else
			local var_11_2 = math.floor(var_11_0 / 60)

			if var_11_2 > 0 then
				return var_11_2 .. i18n("word_minute")
			else
				return var_11_0 .. i18n("word_second")
			end
		end
	end
end

function SecretsAbyssMainPage:OnDestroy()
	if self.camEventId then
		pg.CameraFixMgr.GetInstance():disconnect(self.camEventId)

		self.camEventId = nil
	end
end

return SecretsAbyssMainPage
