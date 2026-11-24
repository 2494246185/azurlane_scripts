local BossRushVeritasAcademyMediator = class("BossRushVeritasAcademyMediator", import("view.base.ContextMediator"))

BossRushVeritasAcademyMediator.ON_FLEET_SELECT = "BossRushVeritasAcademyMediator.ON_FLEET_SELECT"
BossRushVeritasAcademyMediator.ON_EXTRA_RANK = "BossRushVeritasAcademyMediator.ON_EXTRA_RANK"
BossRushVeritasAcademyMediator.ON_PT_RANK = "BossRushVeritasAcademyMediator.ON_PT_RANK"
BossRushVeritasAcademyMediator.ON_TASK_SUBMIT = "BossRushVeritasAcademyMediator.ON_TASK_SUBMIT"
BossRushVeritasAcademyMediator.ON_PERFORM_COMBAT = "BossRushVeritasAcademyMediator.ON_PERFORM_COMBAT"
BossRushVeritasAcademyMediator.GO_SUBLAYER = "BossRushVeritasAcademyMediator.GO_SUBLAYER"
BossRushVeritasAcademyMediator.GO_SCENE = "BossRushVeritasAcademyMediator.GO_SCENE"

function BossRushVeritasAcademyMediator:register()
	self:bind(BossRushVeritasAcademyMediator.GO_SUBLAYER, function(arg_2_0, arg_2_1, arg_2_2)
		self:addSubLayers(arg_2_1, nil, arg_2_2)
	end)
	self:bind(BossRushVeritasAcademyMediator.GO_SCENE, function(arg_3_0, arg_3_1, ...)
		self:sendNotification(GAME.GO_SCENE, arg_3_1, ...)
	end)
	self:bind(BossRushVeritasAcademyMediator.ON_FLEET_SELECT, function(arg_4_0, arg_4_1)
		local var_4_0 = getProxy(ChapterAutoProxy):GetCommissionDoingType()

		if var_4_0 and var_4_0 ~= ChapterAutoProxy.TYPE.WORLD then
			self.viewComponent:CheckChapterAutoOccupied(var_4_0)

			return
		end

		BossRushVeritasAcademyPassedLayer.seriesId = arg_4_1.configId

		self:addSubLayers(Context.New({
			mediator = BossRushFleetSelectMediator,
			viewComponent = BossRushVeritasAcademyFleetSelectView,
			data = {
				seriesData = arg_4_1
			}
		}))
	end)
	self:bind(BossRushVeritasAcademyMediator.ON_EXTRA_RANK, function(arg_5_0)
		self:sendNotification(GAME.GO_SCENE, SCENE.BILLBOARD, {
			page = PowerRank.TYPE_BOSSRUSH
		})
	end)
	self:bind(BossRushVeritasAcademyMediator.ON_PT_RANK, function(arg_6_0)
		self:sendNotification(GAME.GO_SCENE, SCENE.BILLBOARD, {
			page = PowerRank.TYPE_PT
		})
	end)
	self:bind(BossRushVeritasAcademyMediator.ON_PERFORM_COMBAT, function(arg_7_0, arg_7_1, arg_7_2)
		self:sendNotification(GAME.BEGIN_STAGE, {
			system = SYSTEM_PERFORM,
			stageId = arg_7_1,
			exitCallback = arg_7_2
		})
	end)
	self:bind(BossRushVeritasAcademyMediator.ON_TASK_SUBMIT, function(arg_8_0, arg_8_1)
		self:sendNotification(GAME.SUBMIT_TASK, arg_8_1.id)
	end)
	assert(self.contextData.activityID, "activityID is required by BossRushVeritasAcademyMediator")
	self.viewComponent:SetActivity((getProxy(ActivityProxy):getActivityById(self.contextData.activityID)))
	self.viewComponent:SetPtActivity((getProxy(ActivityProxy):getActivityById(ActivityConst.VERITASACADEMY_BOSS_RUSH_PT_ACT_ID)))
	self.viewComponent:addbubbleMsgBox(function(arg_9_0)
		if getProxy(ContextProxy):getCurrentContext():getContextByMediator(BossRushTotalRewardPanelMediator) then
			return
		end

		arg_9_0()
	end)
	self.viewComponent:addbubbleMsgBox(function(arg_10_0)
		pg.GuildMsgBoxMgr.GetInstance():NotificationForBattle(arg_10_0)
	end)
end

function BossRushVeritasAcademyMediator:listNotificationInterests()
	return {
		ActivityProxy.ACTIVITY_UPDATED,
		GAME.SUBMIT_TASK_AWARD_DOWN,
		GAME.BEGIN_STAGE_DONE,
		BossRushTotalRewardPanelMediator.ON_WILL_EXIT,
		GAME.START_CHAPTER_AUTO_DONE,
		GAME.END_CHAPTER_AUTO_DONE
	}
end

function BossRushVeritasAcademyMediator:handleNotification(arg_12_1)
	local var_12_0 = arg_12_1:getName()
	local var_12_1 = arg_12_1:getBody()
	local var_12_2 = arg_12_1:getType()

	if var_12_0 == nil then
		-- block empty
	elseif var_12_0 == GAME.BEGIN_STAGE_DONE then
		if not getProxy(ContextProxy):getContextByMediator(BossRushPreCombatMediator) then
			self:sendNotification(GAME.GO_SCENE, SCENE.COMBATLOAD, var_12_1)
		end
	elseif var_12_0 == ActivityProxy.ACTIVITY_UPDATED then
		if var_12_1 then
			if var_12_1:getConfig("type") == ActivityConst.ACTIVITY_TYPE_BOSSRUSH then
				self.viewComponent:SetActivity(var_12_1)
				self.viewComponent:UpdateView()
			elseif var_12_1.id == ActivityConst.VERITASACADEMY_BOSS_RUSH_PT_ACT_ID then
				self.viewComponent:SetPtActivity(var_12_1)
				self.viewComponent:UpdateView()
			end
		end
	elseif var_12_0 == GAME.SUBMIT_TASK_AWARD_DOWN then
		local var_12_3 = {}

		if #var_12_1.awards > 0 then
			table.insert(var_12_3, function(arg_13_0)
				self.viewComponent:emit(BaseUI.ON_ACHIEVE, var_12_1.awards, arg_13_0)
			end)
		end

		seriesAsync(var_12_3, function()
			self.viewComponent:UpdateView()
		end)
	elseif var_12_0 == BossRushTotalRewardPanelMediator.ON_WILL_EXIT then
		self.viewComponent:resumeBubble()
		self.viewComponent:UpdateView()
	elseif var_12_0 == GAME.START_CHAPTER_AUTO_DONE then
		self.viewComponent:OnStartChapterAuto(var_12_1)
	elseif var_12_0 == GAME.END_CHAPTER_AUTO_DONE then
		self.viewComponent:OnEndChapterAuto(var_12_1)
		self:addSubLayers(Context.New({
			viewComponent = ChapterAutoTotalRewardLayer,
			mediator = ChapterAutoTotalRewardMediator,
			data = {
				rewards = var_12_1.awards,
				totalTimes = var_12_1.allCnt,
				finishTimes = var_12_1.finishCnt,
				proficiency = var_12_1.proficiency
			}
		}), true)
	end
end

function BossRushVeritasAcademyMediator:remove()
	return
end

return BossRushVeritasAcademyMediator
