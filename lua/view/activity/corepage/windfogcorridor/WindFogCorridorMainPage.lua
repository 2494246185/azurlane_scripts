local WindFogCorridorMainPage = class("WindFogCorridorMainPage", import("view.activity.CorePage.CoreActivityPage"))

function WindFogCorridorMainPage:OnInit()
	self.AD = self._tf:Find("AD")
	self.btnManual = self.AD:Find("TopPage/top/manual")
	self.Txtmanual = self.btnManual:Find("Text")
	self.redMalPoint = self.btnManual:Find("tip")
	self.btnGroup = self.AD:Find("btn_list")
	self.btnBuild = self.btnGroup:Find("build")
	self.btnFight = self.btnGroup:Find("fight_bg/fight")
	self.btnShop = self.btnGroup:Find("shop")
	self.resTimeBuild = self.btnBuild:Find("resTime/Text")
	self.resTimeShop = self.btnShop:Find("resTime/Text")
end

function WindFogCorridorMainPage:OnFirstFlush()
	local var_2_0 = self.activity:getConfig("config_client")
	local var_2_1

	if var_2_0.is_showMedal then
		var_2_1 = var_2_0.medal_group_id
	end

	var_2_0 = type(var_2_0) == "table" and var_2_0 or {}

	local function var_2_2(arg_3_0)
		if not arg_3_0 then
			return false
		end

		local var_3_0 = getProxy(ActivityProxy):getActivityById(arg_3_0)

		return not var_3_0 or var_3_0:isEnd()
	end

	onButton(self, self.btnBuild, function()
		if var_2_2(var_2_0.buildLinkActID) then
			pg.TipsMgr.GetInstance():ShowTips(i18n("common_activity_end"))

			return
		end

		self:emit(ActivityMediator.EVENT_GO_SCENE, SCENE.GETBOAT, {
			page = BuildShipScene.PAGE_BUILD,
			projectName = BuildShipScene.PROJECTS.ACTIVITY
		})
	end, SFX_PANEL)
	onButton(self, self.btnFight, function()
		if var_2_0.fightLinkActID and var_2_2(var_2_0.fightLinkActID) then
			pg.TipsMgr.GetInstance():ShowTips(i18n("common_activity_end"))

			return
		end

		if var_2_0.fightLinkActID then
			self:emit(ActivityMediator.SKIP_ACTIVITY_MAP, var_2_0.fightLinkActID)
		else
			self:emit(ActivityMediator.BATTLE_OPERA)
		end
	end, SFX_PANEL)
	onButton(self, self.btnShop, function()
		self:emit(ActivityMediator.GO_CHANGE_SHOP)
	end, SFX_PANEL)
	onButton(self, self.btnManual, function()
		self:emit(ActivityMediator.ON_ADD_SUBLAYER, (Context.New({
			mediator = MedalAlbumTemplateMediator,
			viewComponent = self:GetMedalGropClassById(var_2_1)
		})))
	end, SFX_PANEL)
	setText(self.Txtmanual, i18n("anniversary_nine_main_page"))
	self:refreshBtnResTime()
	self:refreshRed()
end

function WindFogCorridorMainPage:refreshBtnResTime()
	local var_8_0 = self.activity:getConfig("config_client")

	var_8_0 = type(var_8_0) == "table" and var_8_0 or {}

	local var_8_1 = pg.TimeMgr.GetInstance():GetServerTime()

	local function var_8_2(arg_9_0, arg_9_1, arg_9_2)
		if not arg_9_0 or not arg_9_1 then
			return
		end

		local var_9_1 = 0
		local var_9_2 = false

		if arg_9_2 == 1 then
			local var_9_3

			if arg_9_1 then
				var_9_3 = getProxy(ActivityProxy):getActivityById(arg_9_1) or nil
			end

			var_9_2 = var_9_3 and not var_9_3:isEnd() and var_9_3.stopTime and var_9_3.stopTime > var_8_1
			var_9_1 = math.floor((var_9_3.stopTime - var_8_1) / 3600)
		else
			local var_9_4 = pg.TimeMgr.GetInstance():parseTimeFromConfig(pg.shop_template[arg_9_1].time[2]) - var_8_1

			var_9_1 = math.floor(var_9_4 / 3600)
			var_9_2 = var_9_4 > 0
		end

		if var_9_2 and var_9_1 <= 24 then
			setActive(arg_9_0.parent, true)

			if arg_9_2 == 1 then
				setText(arg_9_0, i18n("StarsCityMainPage_no_time"))
			else
				setText(arg_9_0, i18n("StarsCityMainPage_res_day_time", var_9_1))
			end
		else
			setActive(arg_9_0.parent, false)
			setText(arg_9_0, "")
		end
	end

	var_8_2(self.resTimeBuild, var_8_0.buildLinkActID, 1)
	var_8_2(self.resTimeShop, var_8_0.shopItemID, 2)
end

function WindFogCorridorMainPage:OnUpdateFlush()
	self:refreshRed()
	self:refreshBtnResTime()
end

function WindFogCorridorMainPage:refreshRed()
	local var_11_0 = self.activity:getConfig("config_client")

	if var_11_0.is_showMedal then
		setActive(self.redMalPoint, ActivityMedalGroup.showTip(var_11_0.medal_group_id))
	end
end

function WindFogCorridorMainPage:GetMedalGropClassById(arg_12_1)
	if arg_12_1 == nil then
		return nil
	end

	return _G[pg.activity_medal_group[arg_12_1].ui_prefab.scene]
end

return WindFogCorridorMainPage
