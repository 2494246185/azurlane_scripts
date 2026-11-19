local BossRushKurskMediator = class("BossRushKurskMediator", import("view.base.ContextMediator"))

BossRushKurskMediator.ON_FLEET_SELECT = "BossRushKurskMediator:ON_FLEET_SELECT"
BossRushKurskMediator.ON_EXTRA_RANK = "BossRushKurskMediator:ON_EXTRA_RANK"
BossRushKurskMediator.GO_ACT_SHOP = "BossRushKurskMediator:GO_ACT_SHOP"
BossRushKurskMediator.ON_TASK_SUBMIT = "BossRushKurskMediator:ON_TASK_SUBMIT"
BossRushKurskMediator.ON_PERFORM_COMBAT = "BossRushKurskMediator:ON_PERFORM_COMBAT"

function BossRushKurskMediator:register()
	self:bind(BossRushKurskMediator.ON_FLEET_SELECT, function(arg_2_0, arg_2_1)
		self:addSubLayers(Context.New({
			mediator = BossRushFleetSelectMediator,
			viewComponent = BossRushFleetSelectView,
			data = {
				seriesData = arg_2_1
			}
		}))
	end)
	self:bind(BossRushKurskMediator.ON_EXTRA_RANK, function(arg_3_0)
		self:sendNotification(GAME.GO_SCENE, SCENE.BILLBOARD, {
			page = PowerRank.TYPE_BOSSRUSH
		})
	end)
	self:bind(BossRushKurskMediator.ON_PERFORM_COMBAT, function(arg_4_0, arg_4_1, arg_4_2)
		self:sendNotification(GAME.BEGIN_STAGE, {
			system = SYSTEM_PERFORM,
			stageId = arg_4_1,
			exitCallback = arg_4_2
		})
	end)
	self:bind(BossRushKurskMediator.GO_ACT_SHOP, function(arg_5_0, arg_5_1)
		self:addSubLayers(Context.New({
			mediator = PtAwardMediator,
			viewComponent = PtAwardLayer,
			data = {
				ptData = arg_5_1
			}
		}))
	end)
	self:bind(BossRushKurskMediator.ON_TASK_SUBMIT, function(arg_6_0, arg_6_1)
		self:sendNotification(GAME.SUBMIT_TASK, arg_6_1.id)
	end)
	assert(self.contextData.activityID, "activityID is required by BossRushVerZenkerMediator")

	local var_1_0 = getProxy(ActivityProxy):getActivityById(self.contextData.activityID)

	self.viewComponent:SetActivity(var_1_0)
	self.viewComponent:SetPtActivity((var_1_0:GetConfigClientPTActivity()))
	self.viewComponent:addbubbleMsgBox(function(arg_7_0)
		if getProxy(ContextProxy):getCurrentContext():getContextByMediator(BossRushTotalRewardPanelMediator) then
			return
		end

		arg_7_0()
	end)
	self.viewComponent:addbubbleMsgBox(function(arg_8_0)
		pg.GuildMsgBoxMgr.GetInstance():NotificationForBattle(arg_8_0)
	end)
end

function BossRushKurskMediator:listNotificationInterests()
	return {
		ActivityProxy.ACTIVITY_UPDATED,
		GAME.SUBMIT_TASK_DONE,
		GAME.SUBMIT_ACTIVITY_TASK_DONE,
		GAME.BEGIN_STAGE_DONE,
		BossRushTotalRewardPanelMediator.ON_WILL_EXIT
	}
end

function BossRushKurskMediator:handleNotification(arg_10_1)
	local var_10_0 = arg_10_1:getName()
	local var_10_1 = arg_10_1:getBody()
	local var_10_2 = arg_10_1:getType()

	if var_10_0 == nil then
		-- block empty
	elseif var_10_0 == GAME.BEGIN_STAGE_DONE then
		if not getProxy(ContextProxy):getContextByMediator(BossRushPreCombatMediator) then
			self:sendNotification(GAME.GO_SCENE, SCENE.COMBATLOAD, var_10_1)
		end
	elseif var_10_0 == ActivityProxy.ACTIVITY_UPDATED then
		if var_10_1 then
			if var_10_1.id == self.viewComponent.activity.id then
				self.viewComponent:SetActivity(var_10_1)
				self.viewComponent:UpdateView()
			elseif var_10_1.id == self.viewComponent.ptActivity.id then
				self.viewComponent:SetPtActivity(var_10_1)
				self.viewComponent:UpdateView()
			end
		end
	elseif var_10_0 == GAME.SUBMIT_ACTIVITY_TASK_DONE then
		self.viewComponent:emit(BaseUI.ON_ACHIEVE, var_10_1.awards, function()
			self.viewComponent:UpdateTasks(var_10_2)
		end)
	elseif var_10_0 == BossRushTotalRewardPanelMediator.ON_WILL_EXIT then
		self.viewComponent:resumeBubble()
		self.viewComponent:UpdateView()
	end
end

function BossRushKurskMediator:remove()
	return
end

return BossRushKurskMediator
