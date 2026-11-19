local BossRushDALCollabMediator = class("BossRushDALCollabMediator", import("view.base.ContextMediator"))

BossRushDALCollabMediator.ON_FLEET_SELECT = "BossRushDALCollabMediator:ON_FLEET_SELECT"
BossRushDALCollabMediator.ON_PERFORM_COMBAT = "BossRushDALCollabMediator:ON_PERFORM_COMBAT"
BossRushDALCollabMediator.ON_UPGRADE = "BossRushDALCollabMediator:ON_UPGRADE"
BossRushDALCollabMediator.GO_SHOPS_LAYER = "BossRushDALCollabMediator:GO_SHOPS_LAYER"

function BossRushDALCollabMediator:register()
	self:bind(BossRushDALCollabMediator.ON_FLEET_SELECT, function(arg_2_0, arg_2_1)
		self:addSubLayers(Context.New({
			mediator = BossRushFleetSelectMediator,
			viewComponent = BossRushDALFleetSelectView,
			data = {
				seriesData = arg_2_1
			}
		}))
	end)
	self:bind(BossRushDALCollabMediator.GO_SHOPS_LAYER, function(arg_3_0, arg_3_1)
		if not getProxy(ActivityProxy):getActivityById(arg_3_1.actId) then
			pg.TipsMgr.GetInstance():ShowTips(i18n("common_activity_end"))

			return
		end

		self:sendNotification(GAME.GO_SCENE, SCENE.SHOP, arg_3_1 or {
			warp = NewShopsScene.TYPE_ACTIVITY
		})
	end)

	local var_1_0 = getProxy(ActivityProxy)
	local var_1_1 = var_1_0:getActivityByType(ActivityConst.ACTIVITY_TYPE_BOSS_RUSH_DAL_COLLAB)

	self.viewComponent:SetActivity(var_1_1)
	self.viewComponent:SetUpgradeActvity((var_1_0:getActivityByType(ActivityConst.ACTIVITY_TYPE_BUILDING_BUFF)))
	self.viewComponent:SetPTActivity((var_1_1:GetConfigClientPTActivity()))
	self:sendNotification(GAME.COLLABRATE_BOSS_RUSH_REQUEST_DATA, {
		actId = var_1_1.id
	})
	self.viewComponent:addbubbleMsgBox(function(arg_4_0)
		if getProxy(ContextProxy):getCurrentContext():getContextByMediator(BossRushTotalRewardPanelMediator) then
			return
		end

		arg_4_0()
	end)
	self.viewComponent:addbubbleMsgBox(function(arg_5_0)
		pg.GuildMsgBoxMgr.GetInstance():NotificationForBattle(arg_5_0)
	end)
	self:bind(BossRushDALCollabMediator.ON_UPGRADE, function(arg_6_0, arg_6_1)
		self:sendNotification(GAME.ACTIVITY_OPERATION, arg_6_1)
	end)
end

function BossRushDALCollabMediator:listNotificationInterests()
	return {
		ActivityProxy.ACTIVITY_UPDATED,
		GAME.SUBMIT_TASK_DONE,
		GAME.SUBMIT_ACTIVITY_TASK_DONE,
		GAME.BEGIN_STAGE_DONE,
		BossRushTotalRewardPanelMediator.ON_WILL_EXIT,
		GAME.COLLABRATE_BOSS_RUSH_REQUEST_DATA_DONE
	}
end

function BossRushDALCollabMediator:handleNotification(arg_8_1)
	local var_8_0 = arg_8_1:getName()
	local var_8_1 = arg_8_1:getBody()
	local var_8_2 = arg_8_1:getType()

	if var_8_0 == nil then
		-- block empty
	elseif var_8_0 == GAME.BEGIN_STAGE_DONE then
		if not getProxy(ContextProxy):getContextByMediator(BossRushPreCombatMediator) then
			self:sendNotification(GAME.GO_SCENE, SCENE.COMBATLOAD, var_8_1)
		end
	elseif var_8_0 == ActivityProxy.ACTIVITY_UPDATED then
		if var_8_1 then
			if var_8_1.id == self.viewComponent.activity.id then
				self.viewComponent:SetActivity(var_8_1)
				self.viewComponent:UpdateView()
			end

			if var_8_1:getConfig("type") == ActivityConst.ACTIVITY_TYPE_BUILDING_BUFF then
				self.viewComponent.upgradeView:SetData(var_8_1)
				self.viewComponent.upgradeView:UpdateView()
			end
		end
	elseif var_8_0 == GAME.SUBMIT_ACTIVITY_TASK_DONE then
		self.viewComponent:emit(BaseUI.ON_ACHIEVE, var_8_1.awards, function()
			self.viewComponent:UpdateTasks(var_8_2)
		end)
	elseif var_8_0 == BossRushTotalRewardPanelMediator.ON_WILL_EXIT then
		self.viewComponent:resumeBubble()
		self.viewComponent:UpdateView()
	elseif var_8_0 == GAME.COLLABRATE_BOSS_RUSH_REQUEST_DATA_DONE then
		self.viewComponent:SetActivity((getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_BOSS_RUSH_DAL_COLLAB)))
		self.viewComponent:UpdateView()
	end
end

function BossRushDALCollabMediator:remove()
	return
end

return BossRushDALCollabMediator
