local PreviewTemplatePage = class("PreviewTemplatePage", import("view.base.BaseActivityPage"))

function PreviewTemplatePage:OnInit()
	self.bg = self._tf:Find("AD")
	self.btnList = self.bg:Find("btn_list")
end

function PreviewTemplatePage:OnFirstFlush()
	self:initBtn()
	eachChild(self.btnList, function(arg_3_0)
		self.btnFuncList[arg_3_0.name](arg_3_0)
	end)
end

function PreviewTemplatePage:initBtn()
	local function var_4_0(arg_5_0)
		local var_5_0 = getProxy(ActivityProxy):getActivityById(arg_5_0)

		if not var_5_0 or var_5_0 and var_5_0:isEnd() then
			return true
		else
			return false
		end
	end

	local var_4_1 = self.activity:getConfig("config_client")

	self.btnFuncList = {
		task = function(arg_6_0)
			onButton(self, arg_6_0, function()
				if var_4_1.taskLinkActID and var_4_0(var_4_1.taskLinkActID) then
					pg.TipsMgr.GetInstance():ShowTips(i18n("common_activity_end"))

					return
				end

				self:emit(ActivityMediator.EVENT_GO_SCENE, SCENE.TASK, {
					page = "activity"
				})
			end)
		end,
		shop = function(arg_8_0)
			onButton(self, arg_8_0, function()
				local var_9_0

				if var_4_1.shopLinkActID then
					var_9_0 = getProxy(ActivityProxy):getActivityById(var_4_1.shopLinkActID) or underscore.detect(getProxy(ActivityProxy):getActivitiesByType(ActivityConst.ACTIVITY_TYPE_SHOP), function(arg_10_0)
						return not arg_10_0:isEnd()
					end)

					if not var_9_0 or var_9_0:isEnd() then
						pg.TipsMgr.GetInstance():ShowTips(i18n("common_activity_end"))

						return
					end
				end

				self:emit(ActivityMediator.GO_SHOPS_LAYER, {
					warp = NewShopsScene.TYPE_ACTIVITY,
					actId = var_9_0.id
				})
			end)
		end,
		build = function(arg_11_0)
			onButton(self, arg_11_0, function()
				if var_4_1.buildLinkActID and var_4_0(var_4_1.buildLinkActID) then
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
				if var_4_1.fightLinkActID and var_4_0(var_4_1.fightLinkActID) then
					pg.TipsMgr.GetInstance():ShowTips(i18n("common_activity_end"))

					return
				end

				if var_4_1.fightLinkActID then
					self:emit(ActivityMediator.SKIP_ACTIVITY_MAP, var_4_1.fightLinkActID)
				else
					self:emit(ActivityMediator.BATTLE_OPERA)
				end
			end)
		end,
		lottery = function(arg_15_0)
			onButton(self, arg_15_0, function()
				if var_4_1.lotteryLinkActID and var_4_0(var_4_1.lotteryLinkActID) then
					pg.TipsMgr.GetInstance():ShowTips(i18n("common_activity_end"))

					return
				end

				self:emit(ActivityMediator.GO_LOTTERY)
			end)
		end,
		memory = function(arg_17_0)
			return
		end,
		activity = function(arg_18_0)
			return
		end,
		mountain = function(arg_19_0)
			return
		end,
		skinshop = function(arg_20_0)
			onButton(self, arg_20_0, function()
				self:emit(ActivityMediator.EVENT_GO_SCENE, SCENE.SKINSHOP)
			end)
		end,
		dorm = function(arg_22_0)
			onButton(self, arg_22_0, function()
				self:emit(ActivityMediator.EVENT_GO_SCENE, SCENE.COURTYARD)
			end)
		end
	}
end

return PreviewTemplatePage
