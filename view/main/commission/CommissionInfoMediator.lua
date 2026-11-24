local CommissionInfoMediator = class("CommissionInfoMediator", import("...base.ContextMediator"))

CommissionInfoMediator.FINISH_EVENT = "CommissionInfoMediator.FINISH_EVENT"
CommissionInfoMediator.FINISH_CLASS = "CommissionInfoMediator.FINISH_CLASS"
CommissionInfoMediator.GET_OIL_RES = "CommissionInfoMediator.GET_OIL_RES"
CommissionInfoMediator.GET_GOLD_RES = "CommissionInfoMediator.GET_GOLD_RES"
CommissionInfoMediator.ON_ACTIVE_EVENT = "CommissionInfoMediator.ON_ACTIVE_EVENT"
CommissionInfoMediator.ON_ACTIVE_CLASS = "CommissionInfoMediator.ON_ACTIVE_CLASS"
CommissionInfoMediator.ON_ACTIVE_TECH = "CommissionInfoMediator.ON_ACTIVE_TECH"
CommissionInfoMediator.ON_TECH_FINISHED = "CommissionInfoMediator.ON_TECH_FINISHED"
CommissionInfoMediator.ON_TECH_QUEUE_FINISH = "CommissionInfoMediator.ON_TECH_QUEUE_FINISH"
CommissionInfoMediator.ON_INS = "CommissionInfoMediator.ON_INS"
CommissionInfoMediator.ON_UR_ACTIVITY = "CommissionInfoMediator:ON_UR_ACTIVITY"
CommissionInfoMediator.ON_CRUSING = "CommissionInfoMediator.ON_CRUSING"
CommissionInfoMediator.GET_CLASS_RES = "CommissionInfoMediator:GET_CLASS_RES"
CommissionInfoMediator.FINISH_CLASS_ALL = "CommissionInfoMediator:FINISH_CLASS_ALL"
CommissionInfoMediator.GO_META_BOSS = "CommissionInfoMediator:GO_META_BOSS"
CommissionInfoMediator.GO_BATTLE = "CommissionInfoMediator.GO_BATTLE"
CommissionInfoMediator.ON_END_CHAPTER_AUTO = "CommissionInfoMediator.ON_END_CHAPTER_AUTO"
CommissionInfoMediator.GO_WORLD = "CommissionInfoMediator.GO_WORLD"
CommissionInfoMediator.GO_ACT_BOSS = "CommissionInfoMediator.GO_ACT_BOSS"

function CommissionInfoMediator:register()
	self.viewComponent:setPlayer(getProxy(PlayerProxy):getData())
	self:bind(CommissionInfoMediator.GO_ACT_BOSS, function(arg_2_0)
		self:sendNotification(GAME.GO_SCENE, SCENE.ACT_BOSS_BATTLE)
	end)
	self:bind(CommissionInfoMediator.GO_WORLD, function(arg_3_0)
		self:sendNotification(GAME.GO_SCENE, SCENE.WORLD)
	end)
	self:bind(LevelMediator2.GET_CHAPTER_DROP_SHIP_LIST, function(arg_4_0, arg_4_1, arg_4_2)
		self:sendNotification(GAME.GET_CHAPTER_DROP_SHIP_LIST, {
			chapterId = arg_4_1,
			callback = arg_4_2
		})
	end)
	self:bind(CommissionInfoMediator.ON_END_CHAPTER_AUTO, function(arg_5_0)
		self:sendNotification(GAME.END_CHAPTER_AUTO, {
			num = getProxy(ChapterAutoProxy):GetFinishedCnt()
		})
	end)
	self:bind(CommissionInfoMediator.GO_BATTLE, function(arg_6_0)
		local var_6_0 = getProxy(ChapterProxy):getActiveChapter()

		self:sendNotification(GAME.GO_SCENE, SCENE.LEVEL, {
			chapterId = var_6_0 and var_6_0.id,
			mapIdx = var_6_0 and var_6_0:getConfig("map")
		})
	end)
	self:bind(CommissionInfoMediator.GO_META_BOSS, function(arg_7_0)
		self:sendNotification(GAME.GO_SCENE, SCENE.WORLDBOSS)
	end)
	self:bind(CommissionInfoMediator.ON_UR_ACTIVITY, function(arg_8_0)
		self:sendNotification(GAME.GO_SCENE, SCENE.ACTIVITY, {
			id = ActivityConst.UR_ITEM_ACT_ID
		})
	end)
	self:bind(CommissionInfoMediator.ON_CRUSING, function(arg_9_0)
		self:sendNotification(GAME.GO_SCENE, SCENE.CRUSING)
	end)
	self:bind(CommissionInfoMediator.GET_CLASS_RES, function(arg_10_0)
		self:sendNotification(GAME.HARVEST_CLASS_RES)
	end)
	self:bind(CommissionInfoMediator.ON_TECH_QUEUE_FINISH, function(arg_11_0)
		self:sendNotification(GAME.FINISH_QUEUE_TECHNOLOGY)
	end)
	self:bind(CommissionInfoMediator.ON_TECH_FINISHED, function(arg_12_0, arg_12_1)
		self:sendNotification(GAME.FINISH_TECHNOLOGY, {
			id = arg_12_1.id,
			pool_id = arg_12_1.pool_id
		})
	end)
	self:bind(CommissionInfoMediator.FINISH_EVENT, function(arg_13_0, arg_13_1, arg_13_2, arg_13_3)
		self.contextData.oneStepFinishEventCount = arg_13_2
		self.contextData.inFinished = true

		self:sendNotification(GAME.EVENT_FINISH, {
			id = arg_13_1.id,
			callback = function()
				self.contextData.inFinished = nil
			end,
			onConfirm = function()
				if arg_13_3 then
					arg_13_3()
				end

				if self.contextData.oneStepFinishEventCount then
					self.contextData.oneStepFinishEventCount = self.contextData.oneStepFinishEventCount - 1

					if self.contextData.oneStepFinishEventCount <= 0 then
						MainMetaSkillSequence.New():Execute()
					end
				else
					MainMetaSkillSequence.New():Execute()
				end
			end
		})
	end)
	self:bind(CommissionInfoMediator.FINISH_CLASS, function(arg_16_0, arg_16_1, arg_16_2, arg_16_3)
		self:sendNotification(GAME.CANCEL_LEARN_TACTICS, {
			shipId = arg_16_1,
			type = arg_16_2,
			onConfirm = arg_16_3
		})
	end)
	self:bind(CommissionInfoMediator.ON_ACTIVE_EVENT, function(arg_17_0)
		self:sendNotification(GAME.GO_SCENE, SCENE.EVENT)
	end)
	self:bind(CommissionInfoMediator.ON_ACTIVE_CLASS, function(arg_18_0)
		self:sendNotification(GAME.GO_SCENE, SCENE.NAVALTACTICS)
	end)
	self:bind(CommissionInfoMediator.ON_ACTIVE_TECH, function(arg_19_0)
		self:sendNotification(GAME.GO_SCENE, SCENE.TECHNOLOGY)
	end)
	self:bind(CommissionInfoMediator.GET_OIL_RES, function(arg_20_0)
		self:sendNotification(GAME.HARVEST_RES, PlayerConst.ResOil)
	end)
	self:bind(CommissionInfoMediator.GET_GOLD_RES, function(arg_21_0)
		self:sendNotification(GAME.HARVEST_RES, PlayerConst.ResGold)
	end)
	self:bind(CommissionInfoMediator.ON_INS, function(arg_22_0)
		self:sendNotification(GAME.ON_OPEN_INS_LAYER)
		self.viewComponent:emit(BaseUI.ON_CLOSE)
	end)
	self:bind(CommissionInfoMediator.FINISH_CLASS_ALL, function()
		self:sendNotification(GAME.GO_SCENE, SCENE.NAVALTACTICS)
	end)
	self:Notify()
	getProxy(EventProxy):FlushIfDirty()
end

function CommissionInfoMediator:Notify()
	self.viewComponent:NotifyIns()
	self.viewComponent:UpdateLinkPanel()
end

function CommissionInfoMediator:continueClass(arg_25_1, arg_25_2, arg_25_3)
	if table.getCount(getProxy(BagProxy):getItemsByType(Item.LESSON_TYPE) or {}) <= 0 then
		pg.TipsMgr.GetInstance():ShowTips(i18n("tactics_no_lesson"))

		return
	end

	self:sendNotification(GAME.GO_SCENE, SCENE.NAVALTACTICS, {
		shipToLesson = {
			shipId = arg_25_1,
			skillIndex = getProxy(BayProxy):getShipById(arg_25_1):getSkillIndex(arg_25_2),
			index = arg_25_3
		}
	})
end

function CommissionInfoMediator:listNotificationInterests()
	return {
		PlayerProxy.UPDATED,
		GAME.HARVEST_RES_DONE,
		GAME.EVENT_LIST_UPDATE,
		GAME.EVENT_FINISH_UPDATE,
		GAME.EVENT_SHOW_AWARDS,
		GAME.CANCEL_LEARN_TACTICS_DONE,
		GAME.FINISH_TECHNOLOGY_DONE,
		GAME.FINISH_QUEUE_TECHNOLOGY_DONE,
		GAME.START_CHAPTER_AUTO_DONE,
		GAME.END_CHAPTER_AUTO_DONE,
		GAME.ZERO_HOUR_OP_DONE,
		GAME.ON_RECONNECTION
	}
end

function CommissionInfoMediator:handleNotification(arg_27_1)
	local var_27_0 = arg_27_1:getName()
	local var_27_1 = arg_27_1:getBody()

	if var_27_0 == PlayerProxy.UPDATED then
		self.viewComponent:OnPlayerUpdate(var_27_1)
	elseif var_27_0 == GAME.HARVEST_RES_DONE then
		local var_27_2

		if var_27_1.type == 2 then
			var_27_2 = i18n("word_oil")
		elseif var_27_1.type == 1 then
			var_27_2 = i18n("word_gold")
		end

		pg.TipsMgr.GetInstance():ShowTips(i18n("commission_get_award", var_27_2, var_27_1.outPut))
	elseif var_27_0 == GAME.EVENT_LIST_UPDATE or var_27_0 == GAME.EVENT_FINISH_UPDATE then
		local var_27_3 = getProxy(EventProxy)

		self.viewComponent:OnUpdateEventInfo()
	elseif var_27_0 == GAME.ON_RECONNECTION then
		getProxy(EventProxy):FlushIfDirty()
	elseif var_27_0 == GAME.EVENT_SHOW_AWARDS then
		local var_27_4

		var_27_4 = coroutine.wrap(function()
			if #var_27_1.oldShips > 0 then
				self.viewComponent:emit(BaseUI.ON_SHIP_EXP, {
					title = pg.collection_template[var_27_1.eventId].title,
					oldShips = var_27_1.oldShips,
					newShips = var_27_1.newShips,
					isCri = var_27_1.isCri
				}, var_27_4)
				coroutine.yield()
			end

			self.viewComponent:emit(BaseUI.ON_ACHIEVE, var_27_1.awards, function()
				if var_27_1.onConfirm then
					var_27_1.onConfirm()
				end
			end)
		end)

		;(nil)()
	elseif var_27_0 == GAME.CANCEL_LEARN_TACTICS_DONE then
		self.viewComponent:OnUpdateClass()

		local var_27_5 = var_27_1.totalExp
		local var_27_6 = var_27_1.newSkill
		local var_27_7 = getProxy(BayProxy):getShipById(var_27_1.shipId)
		local var_27_8 = var_27_1.newSkill.id
		local var_27_9 = var_27_1.newSkill.level > var_27_1.oldSkill.level and i18n("tactics_end_to_learn", var_27_7:getName(), getSkillName(var_27_8), var_27_5) .. i18n("tactics_skill_level_up", var_27_1.oldSkill.level, var_27_6.level) or i18n("tactics_end_to_learn", var_27_7:getName(), getSkillName(var_27_8), var_27_5)

		if pg.skill_data_template[var_27_8].max_level <= var_27_6.level then
			self:HandleClassMaxLevel(var_27_7, var_27_1, var_27_8, var_27_5)
		else
			local var_27_10 = {
				modal = true,
				hideNo = false,
				hideClose = true
			}

			var_27_10.content = var_27_9 .. i18n("tactics_continue_to_learn")

			function var_27_10.onYes()
				self.openMsgBox = false

				self:continueClass(var_27_1.shipId, var_27_8, var_27_1.id)
			end

			function var_27_10.onNo()
				self.openMsgBox = false
			end

			pg.MsgboxMgr.GetInstance():ShowMsgBox(var_27_10)
		end
	elseif var_27_0 == GAME.FINISH_TECHNOLOGY_DONE then
		self.viewComponent:OnUpdateTechnology()

		if #var_27_1.items > 0 then
			self.viewComponent:emit(BaseUI.ON_AWARD, {
				animation = true,
				items = var_27_1.items
			})
		end
	elseif var_27_0 == GAME.FINISH_QUEUE_TECHNOLOGY_DONE then
		self.viewComponent:OnUpdateTechnology()

		local var_27_11 = {}

		for iter_27_0, iter_27_1 in ipairs(var_27_1.dropInfos) do
			if #iter_27_1 > 0 then
				table.insert(var_27_11, function(arg_32_0)
					self.viewComponent:emit(BaseUI.ON_AWARD, {
						animation = true,
						items = iter_27_1,
						removeFunc = arg_32_0
					})
				end)
			end
		end

		seriesAsync(var_27_11, function()
			local var_33_0 = getProxy(TechnologyProxy):getActivateTechnology()

			if var_33_0 and var_33_0:isCompleted() then
				self:sendNotification(GAME.FINISH_TECHNOLOGY, {
					id = var_33_0.id,
					pool_id = var_33_0.poolId
				})
			end
		end)
	elseif var_27_0 == GAME.END_CHAPTER_AUTO_DONE then
		self:HandleChapterAutoDone(var_27_1)
	elseif var_27_0 == START_CHAPTER_AUTO_DONE then
		self.viewComponent:OnUpdateChapterAuto()
	elseif var_27_0 == GAME.ZERO_HOUR_OP_DONE then
		self.viewComponent:OnUpdateChapterAuto()
	end
end

function CommissionInfoMediator:HandleClassMaxLevel(arg_34_1, arg_34_2, arg_34_3, arg_34_4)
	local var_34_0 = i18n("tactics_end_to_learn", arg_34_1:getName(), getSkillName(arg_34_3), arg_34_4)

	if _.all(arg_34_1:getSkillList(), function(arg_35_0)
		return ShipSkill.New(arg_34_1.skills[arg_35_0]):IsMaxLevel()
	end) then
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			modal = true,
			hideClose = true,
			content = var_34_0 .. i18n("tactics_continue_to_learn_other_ship_skill"),
			onYes = function()
				self:sendNotification(GAME.GO_SCENE, SCENE.NAVALTACTICS)
			end
		})
	else
		local var_34_1 = {
			modal = true,
			hideClose = true
		}

		var_34_1.content = var_34_0 .. i18n("tactics_continue_to_learn_other_skill")

		function var_34_1.onYes()
			self:sendNotification(GAME.GO_SCENE, SCENE.NAVALTACTICS, {
				shipToLesson = {
					shipId = arg_34_2.shipId,
					index = arg_34_2.id
				}
			})
		end

		pg.MsgboxMgr.GetInstance():ShowMsgBox(var_34_1)
	end
end

function CommissionInfoMediator:HandleChapterAutoDone(arg_38_1)
	local function var_38_0()
		self:addSubLayers(Context.New({
			viewComponent = ChapterAutoTotalRewardLayer,
			mediator = ChapterAutoTotalRewardMediator,
			data = {
				rewards = arg_38_1.awards,
				totalTimes = arg_38_1.allCnt,
				finishTimes = arg_38_1.finishCnt,
				proficiency = arg_38_1.proficiency,
				onClose = function()
					self.viewComponent:OnUpdateChapterAuto()
				end
			}
		}), true)
	end

	switch(arg_38_1.type, {
		[ChapterAutoProxy.TYPE.SLG] = function()
			var_38_0()
		end,
		[ChapterAutoProxy.TYPE.WORLD] = function()
			local var_42_0 = nowWorld()
			local var_42_1 = var_42_0:GetAtlas()
			local var_42_2 = {}

			for iter_42_0, iter_42_1 in ipairs(arg_38_1.mapList) do
				if var_42_0.pressingAwardDic[iter_42_1].flag then
					var_42_0:FlagMapPressingAward(iter_42_1)
					var_42_1:MarkMapTransport(iter_42_1)

					if #pg.world_event_complete[var_42_0.pressingAwardDic[iter_42_1].id].event_reward_slgbuff > 0 then
						var_42_2[pg.world_event_complete[var_42_0.pressingAwardDic[iter_42_1].id].event_reward_slgbuff[1]] = defaultValue(var_42_2[pg.world_event_complete[var_42_0.pressingAwardDic[iter_42_1].id].event_reward_slgbuff[1]], 0) + pg.world_event_complete[var_42_0.pressingAwardDic[iter_42_1].id].event_reward_slgbuff[2]
					end
				end
			end

			local var_42_3 = {}

			for iter_42_2, iter_42_3 in pairs(var_42_2) do
				local var_42_4 = {
					id = iter_42_2,
					floor = iter_42_3
				}

				var_42_4.before = var_42_0:GetGlobalBuff(iter_42_2):GetFloor()

				table.insert(var_42_3, var_42_4)
				var_42_0:AddGlobalBuff(iter_42_2, iter_42_3)
			end

			self:addSubLayers(Context.New({
				viewComponent = WorldChapterAutoRewardLayer,
				mediator = WorldChapterAutoRewardMediator,
				data = {
					awards = arg_38_1.awards,
					buffInfos = var_42_3,
					proficiency = arg_38_1.proficiency,
					onClose = function()
						self.viewComponent:OnUpdateChapterAuto()
					end
				}
			}), true)
		end,
		[ChapterAutoProxy.TYPE.BOSS] = function()
			var_38_0()
		end,
		[ChapterAutoProxy.TYPE.RUSH] = function()
			var_38_0()
		end
	}, function()
		assert(false, "Unknown commission type: " .. arg_38_1.type)
	end)
end

return CommissionInfoMediator
