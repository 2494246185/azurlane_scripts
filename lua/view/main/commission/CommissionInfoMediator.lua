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

function CommissionInfoMediator:register()
	self.viewComponent:setPlayer(getProxy(PlayerProxy):getData())
	self:bind(CommissionInfoMediator.GO_WORLD, function(arg_2_0, arg_2_1, arg_2_2)
		self:sendNotification(GAME.GO_SCENE, SCENE.WORLD)
	end)
	self:bind(LevelMediator2.GET_CHAPTER_DROP_SHIP_LIST, function(arg_3_0, arg_3_1, arg_3_2)
		self:sendNotification(GAME.GET_CHAPTER_DROP_SHIP_LIST, {
			chapterId = arg_3_1,
			callback = arg_3_2
		})
	end)
	self:bind(CommissionInfoMediator.ON_END_CHAPTER_AUTO, function(arg_4_0)
		self:sendNotification(GAME.END_CHAPTER_AUTO, {
			num = getProxy(ChapterAutoProxy):GetFinishedCnt()
		})
	end)
	self:bind(CommissionInfoMediator.GO_BATTLE, function(arg_5_0)
		local var_5_0 = getProxy(ChapterProxy):getActiveChapter()

		self:sendNotification(GAME.GO_SCENE, SCENE.LEVEL, {
			chapterId = var_5_0 and var_5_0.id,
			mapIdx = var_5_0 and var_5_0:getConfig("map")
		})
	end)
	self:bind(CommissionInfoMediator.GO_META_BOSS, function(arg_6_0)
		self:sendNotification(GAME.GO_SCENE, SCENE.WORLDBOSS)
	end)
	self:bind(CommissionInfoMediator.ON_UR_ACTIVITY, function(arg_7_0)
		self:sendNotification(GAME.GO_SCENE, SCENE.ACTIVITY, {
			id = ActivityConst.UR_ITEM_ACT_ID
		})
	end)
	self:bind(CommissionInfoMediator.ON_CRUSING, function(arg_8_0)
		self:sendNotification(GAME.GO_SCENE, SCENE.CRUSING)
	end)
	self:bind(CommissionInfoMediator.GET_CLASS_RES, function(arg_9_0)
		self:sendNotification(GAME.HARVEST_CLASS_RES)
	end)
	self:bind(CommissionInfoMediator.ON_TECH_QUEUE_FINISH, function(arg_10_0)
		self:sendNotification(GAME.FINISH_QUEUE_TECHNOLOGY)
	end)
	self:bind(CommissionInfoMediator.ON_TECH_FINISHED, function(arg_11_0, arg_11_1)
		self:sendNotification(GAME.FINISH_TECHNOLOGY, {
			id = arg_11_1.id,
			pool_id = arg_11_1.pool_id
		})
	end)
	self:bind(CommissionInfoMediator.FINISH_EVENT, function(arg_12_0, arg_12_1, arg_12_2, arg_12_3)
		self.contextData.oneStepFinishEventCount = arg_12_2
		self.contextData.inFinished = true

		self:sendNotification(GAME.EVENT_FINISH, {
			id = arg_12_1.id,
			callback = function()
				self.contextData.inFinished = nil
			end,
			onConfirm = function()
				if arg_12_3 then
					arg_12_3()
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
	self:bind(CommissionInfoMediator.FINISH_CLASS, function(arg_15_0, arg_15_1, arg_15_2, arg_15_3)
		self:sendNotification(GAME.CANCEL_LEARN_TACTICS, {
			shipId = arg_15_1,
			type = arg_15_2,
			onConfirm = arg_15_3
		})
	end)
	self:bind(CommissionInfoMediator.ON_ACTIVE_EVENT, function(arg_16_0)
		self:sendNotification(GAME.GO_SCENE, SCENE.EVENT)
	end)
	self:bind(CommissionInfoMediator.ON_ACTIVE_CLASS, function(arg_17_0)
		self:sendNotification(GAME.GO_SCENE, SCENE.NAVALTACTICS)
	end)
	self:bind(CommissionInfoMediator.ON_ACTIVE_TECH, function(arg_18_0)
		self:sendNotification(GAME.GO_SCENE, SCENE.TECHNOLOGY)
	end)
	self:bind(CommissionInfoMediator.GET_OIL_RES, function(arg_19_0)
		self:sendNotification(GAME.HARVEST_RES, PlayerConst.ResOil)
	end)
	self:bind(CommissionInfoMediator.GET_GOLD_RES, function(arg_20_0)
		self:sendNotification(GAME.HARVEST_RES, PlayerConst.ResGold)
	end)
	self:bind(CommissionInfoMediator.ON_INS, function(arg_21_0)
		self:sendNotification(GAME.ON_OPEN_INS_LAYER)
		self.viewComponent:emit(BaseUI.ON_CLOSE)
	end)
	self:bind(CommissionInfoMediator.FINISH_CLASS_ALL, function()
		self:sendNotification(GAME.GO_SCENE, SCENE.NAVALTACTICS)
	end)
	self:Notify()
end

function CommissionInfoMediator:Notify()
	self.viewComponent:NotifyIns()
	self.viewComponent:UpdateLinkPanel()
end

function CommissionInfoMediator:continueClass(arg_24_1, arg_24_2, arg_24_3)
	if table.getCount(getProxy(BagProxy):getItemsByType(Item.LESSON_TYPE) or {}) <= 0 then
		pg.TipsMgr.GetInstance():ShowTips(i18n("tactics_no_lesson"))

		return
	end

	self:sendNotification(GAME.GO_SCENE, SCENE.NAVALTACTICS, {
		shipToLesson = {
			shipId = arg_24_1,
			skillIndex = getProxy(BayProxy):getShipById(arg_24_1):getSkillIndex(arg_24_2),
			index = arg_24_3
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
		GAME.ZERO_HOUR_OP_DONE
	}
end

function CommissionInfoMediator:handleNotification(arg_26_1)
	local var_26_0 = arg_26_1:getName()
	local var_26_1 = arg_26_1:getBody()

	if var_26_0 == PlayerProxy.UPDATED then
		self.viewComponent:OnPlayerUpdate(var_26_1)
	elseif var_26_0 == GAME.HARVEST_RES_DONE then
		local var_26_2

		if var_26_1.type == 2 then
			var_26_2 = i18n("word_oil")
		elseif var_26_1.type == 1 then
			var_26_2 = i18n("word_gold")
		end

		pg.TipsMgr.GetInstance():ShowTips(i18n("commission_get_award", var_26_2, var_26_1.outPut))
	elseif var_26_0 == GAME.EVENT_LIST_UPDATE or var_26_0 == GAME.EVENT_FINISH_UPDATE then
		local var_26_3 = getProxy(EventProxy)

		self.viewComponent:OnUpdateEventInfo()
	elseif var_26_0 == GAME.EVENT_SHOW_AWARDS then
		local var_26_4

		var_26_4 = coroutine.wrap(function()
			if #var_26_1.oldShips > 0 then
				self.viewComponent:emit(BaseUI.ON_SHIP_EXP, {
					title = pg.collection_template[var_26_1.eventId].title,
					oldShips = var_26_1.oldShips,
					newShips = var_26_1.newShips,
					isCri = var_26_1.isCri
				}, var_26_4)
				coroutine.yield()
			end

			self.viewComponent:emit(BaseUI.ON_ACHIEVE, var_26_1.awards, function()
				if var_26_1.onConfirm then
					var_26_1.onConfirm()
				end
			end)
		end)

		;(nil)()
	elseif var_26_0 == GAME.CANCEL_LEARN_TACTICS_DONE then
		self.viewComponent:OnUpdateClass()

		local var_26_5 = var_26_1.totalExp
		local var_26_6 = var_26_1.newSkill
		local var_26_7 = getProxy(BayProxy):getShipById(var_26_1.shipId)
		local var_26_8 = var_26_1.newSkill.id
		local var_26_9 = var_26_1.newSkill.level > var_26_1.oldSkill.level and i18n("tactics_end_to_learn", var_26_7:getName(), getSkillName(var_26_8), var_26_5) .. i18n("tactics_skill_level_up", var_26_1.oldSkill.level, var_26_6.level) or i18n("tactics_end_to_learn", var_26_7:getName(), getSkillName(var_26_8), var_26_5)

		if pg.skill_data_template[var_26_8].max_level <= var_26_6.level then
			self:HandleClassMaxLevel(var_26_7, var_26_1, var_26_8, var_26_5)
		else
			local var_26_10 = {
				modal = true,
				hideNo = false,
				hideClose = true
			}

			var_26_10.content = var_26_9 .. i18n("tactics_continue_to_learn")

			function var_26_10.onYes()
				self.openMsgBox = false

				self:continueClass(var_26_1.shipId, var_26_8, var_26_1.id)
			end

			function var_26_10.onNo()
				self.openMsgBox = false
			end

			pg.MsgboxMgr.GetInstance():ShowMsgBox(var_26_10)
		end
	elseif var_26_0 == GAME.FINISH_TECHNOLOGY_DONE then
		self.viewComponent:OnUpdateTechnology()

		if #var_26_1.items > 0 then
			self.viewComponent:emit(BaseUI.ON_AWARD, {
				animation = true,
				items = var_26_1.items
			})
		end
	elseif var_26_0 == GAME.FINISH_QUEUE_TECHNOLOGY_DONE then
		self.viewComponent:OnUpdateTechnology()

		local var_26_11 = {}

		for iter_26_0, iter_26_1 in ipairs(var_26_1.dropInfos) do
			if #iter_26_1 > 0 then
				table.insert(var_26_11, function(arg_31_0)
					self.viewComponent:emit(BaseUI.ON_AWARD, {
						animation = true,
						items = iter_26_1,
						removeFunc = arg_31_0
					})
				end)
			end
		end

		seriesAsync(var_26_11, function()
			local var_32_0 = getProxy(TechnologyProxy):getActivateTechnology()

			if var_32_0 and var_32_0:isCompleted() then
				self:sendNotification(GAME.FINISH_TECHNOLOGY, {
					id = var_32_0.id,
					pool_id = var_32_0.poolId
				})
			end
		end)
	elseif var_26_0 == GAME.END_CHAPTER_AUTO_DONE then
		self:HandleChapterAutoDone(var_26_1)
	elseif var_26_0 == START_CHAPTER_AUTO_DONE then
		self.viewComponent:OnUpdateChapterAuto()
	elseif var_26_0 == GAME.ZERO_HOUR_OP_DONE then
		self.viewComponent:OnUpdateChapterAuto()
	end
end

function CommissionInfoMediator:HandleClassMaxLevel(arg_33_1, arg_33_2, arg_33_3, arg_33_4)
	local var_33_0 = i18n("tactics_end_to_learn", arg_33_1:getName(), getSkillName(arg_33_3), arg_33_4)

	if _.all(arg_33_1:getSkillList(), function(arg_34_0)
		return ShipSkill.New(arg_33_1.skills[arg_34_0]):IsMaxLevel()
	end) then
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			modal = true,
			hideClose = true,
			content = var_33_0 .. i18n("tactics_continue_to_learn_other_ship_skill"),
			onYes = function()
				self:sendNotification(GAME.GO_SCENE, SCENE.NAVALTACTICS)
			end
		})
	else
		local var_33_1 = {
			modal = true,
			hideClose = true
		}

		var_33_1.content = var_33_0 .. i18n("tactics_continue_to_learn_other_skill")

		function var_33_1.onYes()
			self:sendNotification(GAME.GO_SCENE, SCENE.NAVALTACTICS, {
				shipToLesson = {
					shipId = arg_33_2.shipId,
					index = arg_33_2.id
				}
			})
		end

		pg.MsgboxMgr.GetInstance():ShowMsgBox(var_33_1)
	end
end

function CommissionInfoMediator:HandleChapterAutoDone(arg_37_1)
	switch(arg_37_1.type, {
		[ChapterAutoProxy.TYPE.SLG] = function()
			self:addSubLayers(Context.New({
				viewComponent = ChapterAutoTotalRewardLayer,
				mediator = ChapterAutoTotalRewardMediator,
				data = {
					rewards = arg_37_1.awards,
					totalTimes = arg_37_1.allCnt,
					finishTimes = arg_37_1.finishCnt,
					proficiency = arg_37_1.proficiency,
					onClose = function()
						self.viewComponent:OnUpdateChapterAuto()
					end
				}
			}), true)
		end,
		[ChapterAutoProxy.TYPE.WORLD] = function()
			local var_40_0 = nowWorld()
			local var_40_1 = var_40_0:GetAtlas()
			local var_40_2 = {}

			for iter_40_0, iter_40_1 in ipairs(arg_37_1.mapList) do
				if var_40_0.pressingAwardDic[iter_40_1].flag then
					var_40_0:FlagMapPressingAward(iter_40_1)
					var_40_1:MarkMapTransport(iter_40_1)

					if #pg.world_event_complete[var_40_0.pressingAwardDic[iter_40_1].id].event_reward_slgbuff > 0 then
						var_40_2[pg.world_event_complete[var_40_0.pressingAwardDic[iter_40_1].id].event_reward_slgbuff[1]] = defaultValue(var_40_2[pg.world_event_complete[var_40_0.pressingAwardDic[iter_40_1].id].event_reward_slgbuff[1]], 0) + pg.world_event_complete[var_40_0.pressingAwardDic[iter_40_1].id].event_reward_slgbuff[2]
					end
				end
			end

			local var_40_3 = {}

			for iter_40_2, iter_40_3 in pairs(var_40_2) do
				local var_40_4 = {
					id = iter_40_2,
					floor = iter_40_3
				}

				var_40_4.before = var_40_0:GetGlobalBuff(iter_40_2):GetFloor()

				table.insert(var_40_3, var_40_4)
				var_40_0:AddGlobalBuff(iter_40_2, iter_40_3)
			end

			self:addSubLayers(Context.New({
				viewComponent = WorldChapterAutoRewardLayer,
				mediator = WorldChapterAutoRewardMediator,
				data = {
					awards = arg_37_1.awards,
					buffInfos = var_40_3,
					proficiency = arg_37_1.proficiency,
					onClose = function()
						self.viewComponent:OnUpdateChapterAuto()
					end
				}
			}), true)
		end
	}, function()
		assert(false, "Unknown commission type: " .. arg_37_1.type)
	end)
end

return CommissionInfoMediator
