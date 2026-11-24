local LevelMediator2 = class("LevelMediator2", import("..base.ContextMediator"))

LevelMediator2.ON_TRACKING = "LevelMediator2:ON_TRACKING"
LevelMediator2.ON_ELITE_TRACKING = "LevelMediator2:ON_ELITE_TRACKING"
LevelMediator2.ON_RETRACKING = "LevelMediator2:ON_RETRACKING"
LevelMediator2.ON_UPDATE_CUSTOM_FLEET = "LevelMediator2:ON_UPDATE_CUSTOM_FLEET"
LevelMediator2.ON_OP = "LevelMediator2:ON_OP"
LevelMediator2.ON_RESUME_SUBSTATE = "LevelMediator2:ON_RESUME_SUBSTATE"
LevelMediator2.ON_STAGE = "LevelMediator2:ON_STAGE"
LevelMediator2.ON_GO_TO_TASK_SCENE = "LevelMediator2:ON_GO_TO_TASK_SCENE"
LevelMediator2.ON_OPEN_EVENT_SCENE = "LevelMediator2:ON_OPEN_EVENT_SCENE"
LevelMediator2.ON_DAILY_LEVEL = "LevelMediator2:ON_DAILY_LEVEL"
LevelMediator2.ON_OPEN_MILITARYEXERCISE = "LevelMediator2:ON_OPEN_MILLITARYEXERCISE"
LevelMediator2.ON_OVERRIDE_CHAPTER = "LevelMediator2:ON_OVERRIDE_CHAPTER"
LevelMediator2.ON_TIME_UP = "LevelMediator2:ON_TIME_UP"
LevelMediator2.UPDATE_EVENT_LIST = "LevelMediator2:UPDATE_EVENT_LIST"
LevelMediator2.ON_START = "ON_START"
LevelMediator2.ON_ENTER_MAINLEVEL = "LevelMediator2:ON_ENTER_MAINLEVEL"
LevelMediator2.ON_DIDENTER = "LevelMediator2:ON_DIDENTER"
LevelMediator2.ON_PERFORM_COMBAT = "LevelMediator2.ON_PERFORM_COMBAT"
LevelMediator2.ON_SUPPORT_SUBMARINE = "LevelMediator2.ON_SUPPORT_SUBMARINE"
LevelMediator2.ON_ELITE_OEPN_DECK = "LevelMediator2:ON_ELITE_OEPN_DECK"
LevelMediator2.ON_ELITE_CLEAR = "LevelMediator2:ON_ELITE_CLEAR"
LevelMediator2.ON_ELITE_RECOMMEND = "LevelMediator2:ON_ELITE_RECOMMEND"
LevelMediator2.ON_ELITE_ADJUSTMENT = "LevelMediator2:ON_ELITE_ADJUSTMENT"
LevelMediator2.ON_SUPPORT_OPEN_DECK = "LevelMediator2:ON_SUPPORT_OPEN_DECK"
LevelMediator2.ON_ACTIVITY_MAP = "LevelMediator2:ON_ACTIVITY_MAP"
LevelMediator2.GO_ACT_SHOP = "LevelMediator2:GO_ACT_SHOP"
LevelMediator2.ON_SWITCH_NORMAL_MAP = "LevelMediator2:ON_SWITCH_NORMAL_MAP"
LevelMediator2.NOTICE_AUTOBOT_ENABLED = "LevelMediator2:NOTICE_AUTOBOT_ENABLED"
LevelMediator2.ON_EXTRA_RANK = "LevelMediator2:ON_EXTRA_RANK"
LevelMediator2.ON_STRATEGYING_CHAPTER = "LevelMediator2:ON_STRATEGYING_CHAPTER"
LevelMediator2.ON_SELECT_COMMANDER = "LevelMediator2:ON_SELECT_COMMANDER"
LevelMediator2.ON_SELECT_ELITE_COMMANDER = "LevelMediator2:ON_SELECT_ELITE_COMMANDER"
LevelMediator2.ON_COMMANDER_SKILL = "LevelMediator2:ON_COMMANDER_SKILL"
LevelMediator2.ON_SHIP_DETAIL = "LevelMediator2:ON_SHIP_DETAIL"
LevelMediator2.ON_CLICK_RECEIVE_REMASTER_TICKETS_BTN = "LevelMediator2:ON_CLICK_RECEIVE_REMASTER_TICKETS_BTN"
LevelMediator2.GET_REMASTER_TICKETS_DONE = "LevelMediator2:GET_REMASTER_TICKETS_DONE"
LevelMediator2.ON_FLEET_SHIPINFO = "LevelMediator2:ON_FLEET_SHIPINFO"
LevelMediator2.ON_STAGE_SHIPINFO = "LevelMediator2:ON_STAGE_SHIPINFO"
LevelMediator2.ON_SUPPORT_SHIPINFO = "LevelMediator2:ON_SUPPORT_SHIPINFO"
LevelMediator2.ON_COMMANDER_OP = "LevelMediator2:ON_COMMANDER_OP"
LevelMediator2.CLICK_CHALLENGE_BTN = "LevelMediator2:CLICK_CHALLENGE_BTN"
LevelMediator2.ON_SUBMIT_TASK = "LevelMediator2:ON_SUBMIT_TASK"
LevelMediator2.ON_VOTE_BOOK = "LevelMediator2:ON_VOTE_BOOK"
LevelMediator2.GET_CHAPTER_DROP_SHIP_LIST = "LevelMediator2:GET_CHAPTER_DROP_SHIP_LIST"
LevelMediator2.ON_CHAPTER_REMASTER_AWARD = "LevelMediator2:ON_CHAPTER_REMASTER_AWARD"
LevelMediator2.ON_BOSSRUSH_REMASTER_ACTIVITY = "LevelMediator2:ON_BOSSRUSH_REMASTER_ACTIVITY"
LevelMediator2.ENTER_WORLD = "LevelMediator2:ENTER_WORLD"
LevelMediator2.ON_OPEN_ACT_BOSS_BATTLE = "LevelMediator2:ON_OPEN_ACT_BOSS_BATTLE"
LevelMediator2.ON_BOSSRUSH_MAP = "LevelMediator2:ON_BOSSRUSH_MAP"
LevelMediator2.SHOW_ATELIER_BUFF = "LevelMediator2:SHOW_ATELIER_BUFF"
LevelMediator2.ON_SPITEM_CHANGED = "LevelMediator2:ON_SPITEM_CHANGED"
LevelMediator2.ON_BOSSSINGLE_MAP = "LevelMediator2:ON_BOSSSINGLE_MAP"
LevelMediator2.ON_CLUE_MAP = "LevelMediator2:ON_CLUE_MAP"
LevelMediator2.ON_COLLAB_BOSSRUSH_MAP = "LevelMediator2:ON_COLLAB_BOSSRUSH_MAP"
LevelMediator2.ON_UPDATE_LOWPRIORITY_TASK = "LevelMediator2:ON_UPDATE_LOWPRIORITY_TASK"
LevelMediator2.RECORD_ACTIVITY_PERMANENT_PROGRESS = "LevelMediator2:RECORD_ACTIVITY_PERMANENT_PROGRESS"

function LevelMediator2:register()
	self:bind(LevelMediator2.RECORD_ACTIVITY_PERMANENT_PROGRESS, function(arg_2_0, arg_2_1, arg_2_2)
		self:sendNotification(GAME.RECORD_ACTIVITY_PERMANENT_PROGRESS, {
			remasterId = arg_2_1,
			callback = arg_2_2
		})
	end)
	self:bind(LevelMediator2.GET_CHAPTER_DROP_SHIP_LIST, function(arg_3_0, arg_3_1, arg_3_2)
		self:sendNotification(GAME.GET_CHAPTER_DROP_SHIP_LIST, {
			chapterId = arg_3_1,
			callback = arg_3_2
		})
	end)
	self:bind(LevelMediator2.ON_VOTE_BOOK, function(arg_4_0, arg_4_1)
		return
	end)
	self:bind(LevelMediator2.ON_COMMANDER_OP, function(arg_5_0, arg_5_1, arg_5_2)
		self.contextData.commanderOPChapter = arg_5_2

		self:sendNotification(GAME.COMMANDER_FORMATION_OP, {
			data = arg_5_1
		})
	end)
	self:bind(LevelMediator2.ON_SELECT_COMMANDER, function(arg_6_0, arg_6_1, arg_6_2, arg_6_3)
		FormationMediator.onSelectCommander(arg_6_1, arg_6_2)

		self.contextData.selectedChapterVO = arg_6_3
	end)
	self:bind(LevelMediator2.ON_SELECT_ELITE_COMMANDER, function(arg_7_0, arg_7_1, arg_7_2, arg_7_3)
		local var_7_0 = getProxy(ChapterProxy)
		local var_7_1 = arg_7_3.id

		self.contextData.editEliteChapter = arg_7_3.id

		local var_7_2 = arg_7_3:getEliteFleetCommanders()[arg_7_1] or {}

		self:sendNotification(GAME.GO_SCENE, SCENE.COMMANDERCAT, {
			maxCount = 1,
			mode = CommanderCatScene.MODE_SELECT,
			activeCommander = (var_7_2[arg_7_2] or nil) and getProxy(CommanderProxy):getCommanderById(var_7_2[arg_7_2]),
			ignoredIds = {},
			fleetType = CommanderCatScene.FLEET_TYPE_HARD_CHAPTER,
			chapterId = arg_7_3.id,
			onCommander = function(arg_8_0)
				return true
			end,
			onSelected = function(self, arg_9_1)
				self:sendNotification(GAME.SELECT_ELIT_CHAPTER_COMMANDER, {
					chapterId = var_7_1,
					index = arg_7_1,
					pos = arg_7_2,
					commanderId = self[1],
					callback = function()
						arg_9_1()
					end
				})
			end,
			onQuit = function(arg_11_0)
				self:sendNotification(GAME.SELECT_ELIT_CHAPTER_COMMANDER, {
					commanderId = 0,
					chapterId = var_7_1,
					index = arg_7_1,
					pos = arg_7_2,
					callback = function()
						arg_11_0()
					end
				})
			end
		})
	end)
	self:RegisterTrackEvent()
	self:bind(LevelMediator2.ON_UPDATE_CUSTOM_FLEET, function(arg_13_0, arg_13_1)
		self:sendNotification(GAME.UPDATE_CUSTOM_FLEET, {
			chapterId = arg_13_1.id
		})
	end)
	self:bind(LevelMediator2.ON_OP, function(arg_14_0, arg_14_1)
		self:sendNotification(GAME.CHAPTER_OP, arg_14_1)
	end)
	self:bind(LevelMediator2.ON_SWITCH_NORMAL_MAP, function(arg_15_0)
		local var_15_0 = getProxy(ChapterProxy):GetLastNormalMap()

		if var_15_0 then
			self.viewComponent:setMap(var_15_0)
		end
	end)
	self:bind(LevelMediator2.ON_RESUME_SUBSTATE, function(arg_16_0, arg_16_1)
		self:loadSubState(arg_16_1)
	end)
	self:bind(LevelMediator2.ON_STAGE, function(arg_17_0)
		self:addSubLayers(Context.New({
			mediator = ChapterPreCombatMediator,
			viewComponent = ChapterPreCombatLayer
		}), false)
	end)
	self:bind(LevelMediator2.ON_OPEN_MILITARYEXERCISE, function()
		if getProxy(ActivityProxy):getMilitaryExerciseActivity() then
			self:sendNotification(GAME.GO_SCENE, SCENE.MILITARYEXERCISE)
		else
			pg.TipsMgr.GetInstance():ShowTips(i18n("common_activity_notStartOrEnd"))
		end
	end)
	self:bind(LevelMediator2.CLICK_CHALLENGE_BTN, function(arg_19_0)
		if LOCK_LIMIT_CHALLENGE then
			self:sendNotification(GAME.GO_SCENE, SCENE.CHALLENGE_MAIN_SCENE)
		else
			self:sendNotification(GAME.GO_SCENE, SCENE.LIMIT_CHALLENGE)
		end
	end)
	self:bind(LevelMediator2.ON_DAILY_LEVEL, function(arg_20_0)
		self:sendNotification(GAME.GO_SCENE, SCENE.DAILYLEVEL)
	end)
	self:bind(LevelMediator2.ON_GO_TO_TASK_SCENE, function(arg_21_0, arg_21_1)
		self:sendNotification(GAME.GO_SCENE, SCENE.TASK, arg_21_1)
	end)
	self:bind(LevelMediator2.ON_OPEN_EVENT_SCENE, function()
		self:sendNotification(GAME.GO_SCENE, SCENE.EVENT)
	end)
	self:bind(LevelMediator2.ON_OVERRIDE_CHAPTER, function()
		getProxy(ChapterProxy):updateChapter(self.contextData.chapterVO)
	end)
	self:bind(LevelMediator2.ON_TIME_UP, function()
		self:onTimeUp()
	end)
	self:bind(LevelMediator2.UPDATE_EVENT_LIST, function()
		self.viewComponent:addbubbleMsgBox(function(arg_26_0)
			self:OnEventUpdate(arg_26_0)
		end)

		local var_25_0 = getProxy(ChapterProxy):getActiveChapter(true)

		if var_25_0 and var_25_0:IsAutoFight() then
			local var_25_1 = pg.GuildMsgBoxMgr.GetInstance()

			if var_25_1:GetShouldShowBattleTip() then
				local var_25_2 = getProxy(GuildProxy):getRawData()
				local var_25_3 = var_25_2 and var_25_2:getWeeklyTask()

				if var_25_3 and var_25_3.id ~= 0 then
					getProxy(ChapterProxy):AddExtendChapterDataTable(var_25_0.id, "ListGuildEventNotify", var_25_3:GetPresonTaskId(), var_25_3:GetPrivateTaskName())
					pg.GuildMsgBoxMgr.GetInstance():CancelShouldShowBattleTip()
				end

				var_25_1:SubmitTask(function(arg_27_0, arg_27_1, arg_27_2)
					if arg_27_0 then
						getProxy(ChapterProxy):AddExtendChapterDataTable(var_25_0.id, "ListGuildEventAutoReceiveNotify", arg_27_2, pg.task_data_template[arg_27_2].desc)
					end
				end)
			end
		else
			self.viewComponent:addbubbleMsgBox(function(arg_28_0)
				pg.GuildMsgBoxMgr.GetInstance():NotificationForBattle(arg_28_0)
			end)
		end
	end)
	self:bind(LevelMediator2.ON_ELITE_CLEAR, function(arg_29_0, arg_29_1)
		arg_29_1.chapterVO:clearEliterFleetByIndex(arg_29_1.index)

		local var_29_0 = getProxy(ChapterProxy)

		var_29_0:updateChapter(arg_29_1.chapterVO)
		var_29_0:duplicateEliteFleet(arg_29_1.chapterVO)
		self.viewComponent:RefreshFleetSelectView(arg_29_1.chapterVO)
	end)
	self:bind(LevelMediator2.NOTICE_AUTOBOT_ENABLED, function(arg_30_0, arg_30_1)
		self:sendNotification(GAME.COMMON_FLAG, {
			flagID = BATTLE_AUTO_ENABLED
		})
	end)
	self:bind(LevelMediator2.ON_ELITE_RECOMMEND, function(arg_31_0, arg_31_1)
		local var_31_0 = getProxy(ChapterProxy)

		var_31_0:eliteFleetRecommend(arg_31_1.chapterVO, arg_31_1.index)
		var_31_0:updateChapter(arg_31_1.chapterVO)
		var_31_0:duplicateEliteFleet(arg_31_1.chapterVO)
		self.viewComponent:RefreshFleetSelectView(arg_31_1.chapterVO)
	end)
	self:bind(LevelMediator2.ON_ELITE_ADJUSTMENT, function(arg_32_0, arg_32_1)
		local var_32_0 = getProxy(ChapterProxy)

		var_32_0:updateChapter(arg_32_1)
		var_32_0:duplicateEliteFleet(arg_32_1)
	end)
	self:bind(LevelMediator2.ON_ELITE_OEPN_DECK, function(arg_33_0, arg_33_1)
		local var_33_0 = arg_33_1.shipVO
		local var_33_1 = arg_33_1.chapter
		local var_33_2 = arg_33_1.teamType
		local var_33_3 = {}

		for iter_33_0, iter_33_1 in pairs((getProxy(BayProxy):getRawData())) do
			if not ShipType.ContainInLimitBundle(arg_33_1.shipType, iter_33_1:getShipType()) then
				table.insert(var_33_3, iter_33_0)
			end
		end

		self.contextData.editEliteChapter = var_33_1.id

		local var_33_4 = {}

		for iter_33_2, iter_33_3 in pairs(arg_33_1.fleet) do
			table.insert(var_33_4, iter_33_2.id)
		end

		local var_33_5, var_33_6, var_33_7 = self:getDockCallbackFuncs(arg_33_1.fleet, var_33_0, var_33_1, arg_33_1.fleetIndex)

		self:sendNotification(GAME.GO_SCENE, SCENE.DOCKYARD, {
			selectedMin = 0,
			useBlackBlock = true,
			selectedMax = 1,
			energyDisplay = true,
			ignoredIds = var_33_3,
			leastLimitMsg = i18n("ship_formationMediator_leastLimit"),
			quitTeam = var_33_0 ~= nil,
			teamFilter = var_33_2,
			leftTopInfo = i18n("word_formation"),
			onShip = var_33_5,
			confirmSelect = var_33_6,
			onSelected = var_33_7,
			hideTagFlags = setmetatable({
				inElite = var_33_1:getConfig("formation")
			}, {
				__index = ShipStatus.TAG_HIDE_LEVEL
			}),
			otherSelectedIds = var_33_4
		})
	end)
	self:bind(LevelMediator2.ON_SUPPORT_OPEN_DECK, function(arg_34_0, arg_34_1)
		local var_34_0 = arg_34_1.shipVO
		local var_34_1 = arg_34_1.chapter
		local var_34_2 = arg_34_1.teamType
		local var_34_3 = {}

		for iter_34_0, iter_34_1 in pairs((getProxy(BayProxy):getRawData())) do
			if not ShipType.ContainInLimitBundle(arg_34_1.shipType, iter_34_1:getShipType()) then
				table.insert(var_34_3, iter_34_0)
			end
		end

		local var_34_4 = {}

		for iter_34_2, iter_34_3 in pairs(arg_34_1.fleet) do
			table.insert(var_34_4, iter_34_2.id)
		end

		local var_34_5, var_34_6, var_34_7 = self:getSupportDockCallbackFuncs(arg_34_1.fleet, var_34_0, var_34_1)

		self:sendNotification(GAME.GO_SCENE, SCENE.DOCKYARD, {
			selectedMin = 0,
			useBlackBlock = true,
			selectedMax = 1,
			energyDisplay = true,
			ignoredIds = var_34_3,
			leastLimitMsg = i18n("ship_formationMediator_leastLimit"),
			quitTeam = var_34_0 ~= nil,
			teamFilter = var_34_2,
			leftTopInfo = i18n("word_formation"),
			onShip = var_34_5,
			confirmSelect = var_34_6,
			onSelected = var_34_7,
			hideTagFlags = setmetatable({
				inSupport = var_34_1:getConfig("formation")
			}, {
				__index = ShipStatus.TAG_HIDE_SUPPORT
			}),
			otherSelectedIds = var_34_4
		})

		self.contextData.selectedChapterVO = var_34_1
	end)
	self:bind(LevelMediator2.ON_ACTIVITY_MAP, function(arg_35_0, arg_35_1)
		local var_35_0 = getProxy(ChapterProxy)
		local var_35_1, var_35_2 = var_35_0:getLastMapForActivity(arg_35_1)

		if var_35_1 then
			if not var_35_0:getMapById(var_35_1):isUnlock() then
				pg.TipsMgr.GetInstance():ShowTips(i18n("common_activity_end"))

				return
			end
		end

		self.viewComponent:ShowSelectedMap(var_35_1, function()
			if var_35_2 then
				self.viewComponent:switchToChapter((var_35_0:getChapterById(var_35_2)))
			end
		end)
	end)
	self:bind(LevelMediator2.ON_BOSSRUSH_MAP, function()
		self:sendNotification(GAME.GO_SCENE, SCENE.BOSSRUSH_MAIN)
	end)
	self:bind(LevelMediator2.ON_BOSSSINGLE_MAP, function(arg_38_0, arg_38_1)
		self:sendNotification(GAME.GO_SCENE, SCENE.OTHERWORLD_MAP, arg_38_1)
	end)
	self:bind(LevelMediator2.ON_CLUE_MAP, function()
		self:sendNotification(GAME.GO_SCENE, SCENE.CLUE_MAP)
	end)
	self:bind(LevelMediator2.ON_COLLAB_BOSSRUSH_MAP, function()
		self:sendNotification(GAME.GO_SCENE, SCENE.BOSSRUSH_DAL_COLLAB)
	end)
	self:bind(LevelMediator2.GO_ACT_SHOP, function()
		local var_41_0 = self.contextData.map and self.contextData.map:getConfig("on_activity") or nil
		local var_41_1 = var_41_0 and var_41_0 ~= 0 and getProxy(ActivityProxy):getActivityById(var_41_0)
		local var_41_2 = var_41_1 and not var_41_1:isEnd() and var_41_1:GetConfigClientSetting("PTID")
		local var_41_3 = getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_LOTTERY)

		if var_41_3 and var_41_3:getConfig("config_client").resId == var_41_2 and not var_41_3:isEnd() then
			self:addSubLayers(Context.New({
				mediator = LotteryMediator,
				viewComponent = LotteryLayer,
				data = {
					activityId = var_41_3.id
				}
			}), false)

			return
		end

		local var_41_4 = var_41_1:GetConfigClientPTActivity()

		if var_41_4 then
			local var_41_5 = getProxy(ActivityProxy):GetShopActivityByRes(var_41_4:GetPTDrop()) or nil

			if var_41_5 then
				self:sendNotification(GAME.GO_SCENE, SCENE.SHOP, {
					warp = NewShopsScene.TYPE_ACTIVITY,
					actId = var_41_5.id
				})
			end
		end
	end)
	self:bind(LevelMediator2.SHOW_ATELIER_BUFF, function(arg_42_0, arg_42_1)
		if arg_42_1 then
			self:addSubLayers(Context.New({
				mediator = AterialYumiaCoreBuffMediator,
				viewComponent = AterialYumiaCoreBuffLayer
			}))
		else
			self:addSubLayers(Context.New({
				mediator = AtelierBuffMediator,
				viewComponent = AtelierBuffLayer
			}))
		end
	end)
	self:bind(LevelMediator2.ON_SHIP_DETAIL, function(arg_43_0, arg_43_1)
		self.contextData.selectedChapterVO = arg_43_1.chapter

		self:sendNotification(GAME.GO_SCENE, SCENE.SHIPINFO, {
			shipId = arg_43_1.id
		})
	end)
	self:bind(LevelMediator2.ON_FLEET_SHIPINFO, function(arg_44_0, arg_44_1)
		self:sendNotification(GAME.GO_SCENE, SCENE.SHIPINFO, {
			shipId = arg_44_1.shipId,
			shipVOs = arg_44_1.shipVOs
		})

		self.contextData.editEliteChapter = arg_44_1.chapter.id
	end)
	self:bind(LevelMediator2.ON_SUPPORT_SHIPINFO, function(arg_45_0, arg_45_1)
		self:sendNotification(GAME.GO_SCENE, SCENE.SHIPINFO, {
			shipId = arg_45_1.shipId,
			shipVOs = arg_45_1.shipVOs
		})

		self.contextData.selectedChapterVO = arg_45_1.chapter
	end)
	self:bind(LevelMediator2.ON_STAGE_SHIPINFO, function(arg_46_0, arg_46_1)
		self:sendNotification(GAME.GO_SCENE, SCENE.SHIPINFO, {
			shipId = arg_46_1.shipId,
			shipVOs = arg_46_1.shipVOs
		})
	end)
	self:bind(LevelMediator2.ON_EXTRA_RANK, function(arg_47_0)
		self:sendNotification(GAME.GO_SCENE, SCENE.BILLBOARD, {
			page = PowerRank.TYPE_EXTRA_CHAPTER
		})
	end)
	self:bind(LevelMediator2.ON_STRATEGYING_CHAPTER, function(arg_48_0)
		local var_48_0 = getProxy(ChapterProxy)
		local var_48_1 = var_48_0:getActiveChapter()

		assert(var_48_1)
		pg.MsgboxMgr.GetInstance():ShowMsgBox({
			yesText = "text_forward",
			content = i18n("levelScene_chapter_is_activation", string.split(var_48_0:getMapById(var_48_1:getConfig("map")):getConfig("name"), "|")[1] .. ":" .. var_48_1:getConfig("chapter_name")),
			onYes = function()
				self.viewComponent:switchToChapter(var_48_1)
			end,
			onNo = function()
				self.contextData.chapterVO = var_48_1

				self.viewComponent:emit(LevelMediator2.ON_OP, {
					type = ChapterConst.OpRetreat,
					exittype = ChapterConst.ExitFromMap
				})
			end,
			onClose = function()
				return
			end,
			noBtnType = pg.MsgboxMgr.BUTTON_RETREAT
		})
	end)
	self:bind(LevelMediator2.ON_COMMANDER_SKILL, function(arg_52_0, arg_52_1)
		self:addSubLayers(Context.New({
			mediator = CommanderSkillMediator,
			viewComponent = CommanderSkillLayer,
			data = {
				skill = arg_52_1
			}
		}))
	end)
	self:bind(LevelMediator2.ON_PERFORM_COMBAT, function(arg_53_0, arg_53_1, arg_53_2, arg_53_3)
		self:sendNotification(GAME.BEGIN_STAGE, {
			system = SYSTEM_PERFORM,
			stageId = arg_53_1,
			exitCallback = arg_53_2,
			memory = arg_53_3
		})
	end)
	self:bind(LevelMediator2.ON_SUPPORT_SUBMARINE, function(arg_54_0)
		self:sendNotification(GAME.BEGIN_STAGE, {
			system = SYSTEM_SCENARIO_SUB_STRIKE
		})
	end)
	self:bind(LevelMediator2.ON_CLICK_RECEIVE_REMASTER_TICKETS_BTN, function(arg_55_0)
		self:sendNotification(GAME.GET_REMASTER_TICKETS)
	end)
	self:bind(LevelMediator2.ON_BOSSRUSH_REMASTER_ACTIVITY, function(arg_56_0, arg_56_1)
		self.bossRushRemasterActivityId = arg_56_1

		self:sendNotification(GAME.ACTIVITY_PERMANENT_START, {
			activity_id = arg_56_1
		})
	end)
	self:bind(LevelMediator2.ON_SUBMIT_TASK, function(arg_57_0, arg_57_1)
		self:sendNotification(GAME.SUBMIT_TASK, arg_57_1)
	end)
	self:bind(LevelMediator2.ON_START, function(arg_58_0)
		local var_58_0 = getProxy(ChapterProxy):getActiveChapter()

		assert(var_58_0)

		local var_58_1 = var_58_0.fleet
		local var_58_2 = var_58_0:getStageId(var_58_0.fleet.line.row, var_58_0.fleet.line.column)

		seriesAsync({
			function(arg_59_0)
				local var_59_0 = {}

				for iter_59_0, iter_59_1 in pairs(var_58_1.ships) do
					table.insert(var_59_0, iter_59_1)
				end

				Fleet.EnergyCheck(var_59_0, var_58_1.name, function(arg_60_0)
					if arg_60_0 then
						arg_59_0()
					end
				end, function(arg_61_0)
					if not arg_61_0 then
						getProxy(ChapterProxy):StopAutoFight(ChapterConst.AUTOFIGHT_STOP_REASON.SHIP_ENERGY_LOW)
					end
				end)
			end,
			function(arg_62_0)
				if getProxy(PlayerProxy):getRawData():GoldMax(1) then
					getProxy(ChapterProxy):StopAutoFight(ChapterConst.AUTOFIGHT_STOP_REASON.GOLD_MAX)
					pg.MsgboxMgr.GetInstance():ShowMsgBox({
						content = i18n("gold_max_tip_title") .. i18n("resource_max_tip_battle"),
						onYes = arg_62_0
					})
				else
					arg_62_0()
				end
			end,
			function(arg_63_0)
				self:sendNotification(GAME.BEGIN_STAGE, {
					system = SYSTEM_SCENARIO,
					stageId = var_58_2
				})
			end
		})
	end)
	self:bind(self.ON_ENTER_MAINLEVEL, function(arg_64_0, arg_64_1)
		self:DidEnterLevelMainUI(arg_64_1)
	end)
	self:bind(self.ON_DIDENTER, function(arg_65_0)
		self.viewComponent:emit(LevelMediator2.UPDATE_EVENT_LIST)
	end)
	self:bind(LevelMediator2.ENTER_WORLD, function(arg_66_0)
		self:sendNotification(GAME.GO_SCENE, SCENE.WORLD)
	end)
	self:bind(LevelMediator2.ON_CHAPTER_REMASTER_AWARD, function(arg_67_0, arg_67_1, arg_67_2, arg_67_3)
		self:sendNotification(GAME.CHAPTER_REMASTER_AWARD_RECEIVE, {
			chapterId = arg_67_1,
			pos = arg_67_2,
			actId = arg_67_3
		})
	end)
	self:bind(LevelMediator2.ON_OPEN_ACT_BOSS_BATTLE, function(arg_68_0)
		self:sendNotification(GAME.GO_SCENE, SCENE.ACT_BOSS_BATTLE, {
			showAni = true
		})
	end)
	self:bind(LevelUIConst.OPEN_NORMAL_CONTINUOUS_WINDOW, function(arg_69_0, arg_69_1, arg_69_2, arg_69_3, arg_69_4)
		self:DisplayContinuousWindow(arg_69_1, _.map(arg_69_2, function(arg_70_0)
			local var_70_0 = getProxy(FleetProxy):getFleetById(arg_70_0)

			if not var_70_0 or var_70_0:getFleetType() == FleetType.Submarine then
				return
			end

			return var_70_0
		end), arg_69_3, arg_69_4)
	end)
	self:bind(LevelUIConst.OPEN_ELITE_CONTINUOUS_WINDOW, function(arg_71_0, arg_71_1, arg_71_2, arg_71_3)
		local var_71_0 = getProxy(BayProxy):getRawData()

		self:DisplayContinuousWindow(arg_71_1, _.map(arg_71_1:getEliteFleetList(), function(arg_72_0)
			if #arg_72_0 == 0 or _.any(arg_72_0, function(arg_73_0)
				return var_71_0[arg_73_0] and var_71_0[arg_73_0]:getTeamType() == TeamType.Submarine
			end) then
				return
			end

			return TypedFleet.New({
				fleetType = FleetType.Normal,
				ship_list = arg_72_0
			})
		end), arg_71_2, arg_71_3)
	end)
	self:bind(LevelMediator2.ON_UPDATE_LOWPRIORITY_TASK, function(arg_74_0, arg_74_1, arg_74_2)
		self:sendNotification(GAME.UPDATE_LOW_PRIORITY_TASK_PROGRESS, {
			taskId = arg_74_1
		})
	end)
	self:bind(EasterEggView.ON_CLICK_EASTER_EGG, function(arg_75_0, arg_75_1)
		self:sendNotification(GAME.PUZZLE_PIECE_OP, arg_75_1)
	end)

	self.player = getProxy(PlayerProxy):getData()

	self.viewComponent:updateRes(self.player)
	self.viewComponent:updateEvent((getProxy(EventProxy)))
	self.viewComponent:updateFleet((getProxy(FleetProxy):GetRegularFleets()))
	self.viewComponent:setShips(getProxy(BayProxy):getRawData())

	local var_1_0 = getProxy(ActivityProxy)

	self.viewComponent:updateVoteBookBtn()
	self.viewComponent:setCommanderPrefabs((getProxy(CommanderProxy):getPrefabFleet()))
	self.viewComponent:setEliteQuota(getProxy(DailyLevelProxy).eliteCount, pg.gameset.elite_quota.key_value)
	getProxy(ChapterProxy):updateActiveChapterShips()
	self.viewComponent:setSpecialOperationTickets((getProxy(BagProxy):getItemsByType(Item.SPECIAL_OPERATION_TICKET)))
end

function LevelMediator2:DidEnterLevelMainUI(arg_76_1)
	self.viewComponent:setMap(arg_76_1)

	if self.contextData.openChapterId then
		self.viewComponent.mapBuilder:ActionInvoke("TryOpenChapter", self.contextData.openChapterId)

		self.contextData.openChapterId = nil
	end

	local var_76_0 = self.contextData.chapterVO

	if self.contextData.chapterVO and var_76_0.active then
		self.viewComponent:switchToChapter(var_76_0)
	elseif self.contextData.map:isSkirmish() then
		self.viewComponent:ShowCurtains(true)
		self.viewComponent:doPlayAnim("TV01", function(arg_77_0)
			go(arg_77_0):SetActive(false)
			self.viewComponent:ShowCurtains(false)
		end)
	end

	if self.contextData.preparedTaskList and #self.contextData.preparedTaskList > 0 then
		for iter_76_0, iter_76_1 in ipairs(self.contextData.preparedTaskList) do
			self:sendNotification(GAME.SUBMIT_TASK, iter_76_1)
		end

		table.clean(self.contextData.preparedTaskList)
	end

	if self.contextData.StopAutoFightFlag then
		local var_76_1 = getProxy(ChapterProxy)
		local var_76_2 = var_76_1:getActiveChapter()

		if var_76_2 then
			var_76_1:SetChapterAutoFlag(var_76_2.id, false)
			self.viewComponent:updateChapterVO(var_76_2, (bit.bor(ChapterConst.DirtyAttachment, ChapterConst.DirtyStrategy)))
		end

		self.contextData.StopAutoFightFlag = nil
	end

	self:TryEnterPendingChapter()
end

function LevelMediator2:TryEnterPendingChapter()
	if not self.contextData.pendingEnterChapterId then
		return
	end

	if not self.contextData.map or not self.viewComponent.mapBuilder then
		return
	end

	if self.contextData.chapterVO and self.contextData.chapterVO.id == self.contextData.pendingEnterChapterId then
		self.contextData.pendingEnterChapterId = nil

		return
	end

	local var_78_0 = getProxy(ChapterProxy):getChapterById(self.contextData.pendingEnterChapterId)

	if not var_78_0 or not var_78_0.active then
		return
	end

	self.contextData.pendingEnterChapterId = nil
	self.waitingTracking = nil

	self.viewComponent:resetLevelGrid()

	self.viewComponent.FirstEnterChapter = var_78_0.id

	self.viewComponent:switchToChapter(var_78_0)
end

function LevelMediator2:RegisterTrackEvent()
	self:bind(LevelMediator2.ON_TRACKING, function(arg_80_0, arg_80_1, arg_80_2, arg_80_3, arg_80_4, arg_80_5)
		local var_80_0 = getProxy(ChapterProxy):getChapterById(arg_80_1, true)

		self:sendNotification(GAME.TRACKING, {
			chapterId = arg_80_1,
			fleetIds = getProxy(ChapterProxy):GetLastFleetIndex(),
			loopFlag = arg_80_2,
			operationItem = arg_80_3,
			duties = arg_80_4,
			autoFightFlag = arg_80_5
		})
	end)
	self:bind(LevelMediator2.ON_ELITE_TRACKING, function(arg_81_0, arg_81_1, arg_81_2, arg_81_3, arg_81_4, arg_81_5)
		self:sendNotification(GAME.TRACKING, {
			chapterId = arg_81_1,
			loopFlag = arg_81_2,
			operationItem = arg_81_3,
			duties = arg_81_4,
			autoFightFlag = arg_81_5
		})
	end)
	self:bind(LevelMediator2.ON_RETRACKING, function(arg_82_0, arg_82_1, arg_82_2)
		local var_82_0 = arg_82_1:GetActiveSPItemID()

		if arg_82_1:getConfig("type") == Chapter.CustomFleet then
			self.viewComponent:emit(LevelMediator2.ON_ELITE_TRACKING, arg_82_1.id, arg_82_1.loopFlag, var_82_0, arg_82_1.duties, arg_82_2)
		else
			self.viewComponent:emit(LevelMediator2.ON_TRACKING, arg_82_1.id, arg_82_1.loopFlag, var_82_0, arg_82_1.duties, arg_82_2)
		end
	end)
end

function LevelMediator2:NoticeVoteBook(arg_83_1)
	arg_83_1()
end

function LevelMediator2:TryPlaySubGuide()
	self.viewComponent:tryPlaySubGuide()
end

function LevelMediator2:listNotificationInterests()
	return {
		GAME.ZERO_HOUR_OP_DONE,
		ChapterProxy.CHAPTER_UPDATED,
		ChapterProxy.CHAPTER_TIMESUP,
		PlayerProxy.UPDATED,
		DailyLevelProxy.ELITE_QUOTA_UPDATE,
		LevelMediator2.ON_TRACKING,
		LevelMediator2.ON_ELITE_TRACKING,
		LevelMediator2.ON_RETRACKING,
		GAME.TRACKING_DONE,
		GAME.TRACKING_ERROR,
		GAME.CHAPTER_OP_DONE,
		GAME.EVENT_LIST_UPDATE,
		GAME.BEGIN_STAGE_DONE,
		ActivityProxy.ACTIVITY_OPERATION_DONE,
		ActivityProxy.ACTIVITY_UPDATED,
		GAME.SUB_CHAPTER_REFRESH_DONE,
		GAME.SUB_CHAPTER_FETCH_DONE,
		CommanderProxy.PREFAB_FLEET_UPDATE,
		GAME.COOMMANDER_EQUIP_TO_FLEET_DONE,
		GAME.COMMANDER_ELIT_FORMATION_OP_DONE,
		GAME.SUBMIT_TASK_DONE,
		GAME.SUBMIT_ACTIVITY_TASK_DONE,
		LevelUIConst.CONTINUOUS_OPERATION,
		LevelMediator2.ON_SPITEM_CHANGED,
		GAME.GET_REMASTER_TICKETS_DONE,
		GAME.ACTIVITY_PERMANENT_START_DONE,
		VoteProxy.VOTE_ORDER_BOOK_DELETE,
		VoteProxy.VOTE_ORDER_BOOK_UPDATE,
		GAME.VOTE_BOOK_BE_UPDATED_DONE,
		BagProxy.ITEM_UPDATED,
		ChapterProxy.CHAPTER_AUTO_FIGHT_FLAG_UPDATED,
		ChapterProxy.CHAPTER_SKIP_PRECOMBAT_UPDATED,
		ChapterProxy.CHAPTER_REMASTER_INFO_UPDATED,
		GAME.CHAPTER_REMASTER_INFO_REQUEST_DONE,
		GAME.CHAPTER_REMASTER_AWARD_RECEIVE_DONE,
		GAME.STORY_UPDATE_DONE,
		GAME.STORY_END,
		GAME.START_CHAPTER_AUTO_DONE,
		GAME.END_CHAPTER_AUTO_DONE,
		GAME.ADD_CHAPTER_AUTO_TIME_DONE,
		ChapterAutoProxy.FINISH_UPDATE
	}
end

function LevelMediator2:handleNotification(arg_86_1)
	local var_86_0 = arg_86_1:getName()
	local var_86_1 = arg_86_1:getBody()

	if var_86_0 == GAME.ZERO_HOUR_OP_DONE then
		self.viewComponent:onZeroHourRefresh()
	elseif var_86_0 == GAME.BEGIN_STAGE_DONE then
		self:sendNotification(GAME.GO_SCENE, SCENE.COMBATLOAD, var_86_1)
	elseif var_86_0 == VoteProxy.VOTE_ORDER_BOOK_DELETE or VoteProxy.VOTE_ORDER_BOOK_UPDATE == var_86_0 then
		self.viewComponent:updateVoteBookBtn()
	elseif var_86_0 == PlayerProxy.UPDATED then
		self.viewComponent:updateRes(var_86_1)
	elseif var_86_0 == LevelMediator2.ON_TRACKING or var_86_0 == LevelMediator2.ON_ELITE_TRACKING or var_86_0 == LevelMediator2.ON_RETRACKING then
		self.viewComponent:emit(var_86_0, unpackEx(var_86_1))
	elseif var_86_0 == GAME.TRACKING_DONE then
		self.waitingTracking = nil

		if self.contextData.pendingEnterChapterId == var_86_1.id then
			self.contextData.pendingEnterChapterId = nil
		end

		self.viewComponent:resetLevelGrid()

		self.viewComponent.FirstEnterChapter = var_86_1.id

		self.viewComponent:switchToChapter(var_86_1)
	elseif var_86_0 == ChapterProxy.CHAPTER_UPDATED then
		self.viewComponent:updateChapterVO(var_86_1.chapter, var_86_1.dirty)
	elseif var_86_0 == GAME.COMMANDER_ELIT_FORMATION_OP_DONE then
		if self.contextData.commanderOPChapter then
			for iter_86_0, iter_86_1 in pairs(getProxy(ChapterProxy):getChapterById(var_86_1.chapterId):getEliteFleetCommanders()) do
				self.contextData.commanderOPChapter:setEliteFleetByIndex(iter_86_0, {
					{
						TeamType.FormCommander,
						{
							pos = 1,
							id = iter_86_1[1]
						}
					},
					{
						TeamType.FormCommander,
						{
							pos = 2,
							id = iter_86_1[2]
						}
					}
				})
			end

			self.viewComponent:RefreshFleetSelectView(self.contextData.commanderOPChapter)
		end
	elseif var_86_0 == GAME.CHAPTER_OP_DONE then
		local var_86_2

		local function var_86_3()
			if var_86_2 and coroutine.status(var_86_2) == "suspended" then
				local var_87_0, var_87_1 = coroutine.resume(var_86_2)

				assert(var_87_0, debug.traceback(var_86_2, var_87_1))
			end
		end

		var_86_2 = coroutine.create(function()
			local var_88_0 = var_86_1.type
			local var_88_1 = self.contextData.chapterVO
			local var_88_2 = self.contextData.chapterVO:IsAutoFight()

			if var_86_1.type == ChapterConst.OpRetreat and not var_86_1.id then
				var_88_1 = var_86_1.finalChapterLevelData

				if var_86_1.exittype and var_86_1.exittype == ChapterConst.ExitFromMap then
					self.viewComponent:setChapter(nil)
					self.viewComponent.mapBuilder:UpdateChapterTF(var_88_1.id)
					self:OnExitChapter(var_88_1, var_86_1.win, var_86_1.extendData)

					return
				end

				if var_88_1:existOni() then
					local var_88_3 = var_88_1:checkOniState()

					if var_88_3 then
						self.viewComponent:displaySpResult(var_88_3, var_86_3)
						coroutine.yield()
					end
				end

				if var_88_1:isPlayingWithBombEnemy() then
					self.viewComponent:displayBombResult(var_86_3)
					coroutine.yield()
				end
			end

			local var_88_4 = var_86_1.items
			local var_88_5

			if var_86_1.items and #var_88_4 > 0 then
				if var_86_1.type == ChapterConst.OpBox and pg.box_data_template[var_88_1:getChapterCell(var_88_1.fleet.line.row, var_88_1.fleet.line.column).attachmentId].type == ChapterConst.BoxDrop and ChapterConst.IsAtelierMap(self.contextData.map) then
					local var_88_6 = _.filter(var_88_4, function(arg_89_0)
						return arg_89_0.type == DROP_TYPE_RYZA_DROP
					end)

					if #var_88_6 > 0 then
						var_88_5 = AwardInfoLayer.TITLE.RYZA

						local var_88_7 = AtelierMaterial.New({
							configId = var_88_6[math.random(#var_88_6)].id
						}):GetVoices()

						if var_88_7 and #var_88_7 > 0 then
							local var_88_8 = var_88_7[math.random(#var_88_7)]
							local var_88_9, var_88_10, var_88_11 = ShipWordHelper.GetWordAndCV(var_88_8[1], var_88_8[2], nil, PLATFORM_CODE ~= PLATFORM_US)

							self.viewComponent:emit(LevelUIConst.ADD_TOAST_QUEUE, {
								iconScale = 0.75,
								Class = LevelStageAtelierMaterialToast,
								title = i18n("ryza_tip_toast_item_got"),
								desc = var_88_11,
								voice = var_88_10,
								icon = var_88_8[3]
							})
						end
					end
				end

				seriesAsync({
					function(arg_90_0)
						getProxy(ChapterProxy):AddExtendChapterDataArray(var_88_1.id, "TotalDrops", _.filter(var_88_4, function(arg_91_0)
							return arg_91_0.type ~= DROP_TYPE_STRATEGY
						end))
						self.viewComponent:emit(BaseUI.ON_WORLD_ACHIEVE, {
							items = var_88_4,
							title = var_88_5,
							closeOnCompleted = var_88_2,
							removeFunc = arg_90_0
						})
					end,
					function(arg_92_0)
						if var_88_0 == ChapterConst.OpBox and _.any(var_88_4, function(arg_93_0)
							if arg_93_0.type ~= DROP_TYPE_VITEM then
								return false
							end

							return arg_93_0:getConfig("virtual_type") == 1
						end) then
							(function()
								local var_94_0 = getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_PUZZLA)

								if not var_94_0 then
									return
								end

								local var_94_1 = pg.activity_event_picturepuzzle[var_94_0.id]

								if not pg.activity_event_picturepuzzle[var_94_0.id] then
									return
								end

								if #table.mergeArray(var_94_0.data1_list, var_94_0.data2_list, true) < #var_94_1.pickup_picturepuzzle + #var_94_1.drop_picturepuzzle then
									return
								end

								pg.NewStoryMgr.GetInstance():Play(var_94_0:getConfig("config_client").comStory, arg_92_0)
							end)()
						end

						if _.any(var_88_4, function(arg_95_0)
							if arg_95_0.type ~= DROP_TYPE_STRATEGY then
								return false
							end

							return pg.strategy_data_template[arg_95_0.id].type == ChapterConst.StgTypeConsume
						end) then
							self.viewComponent.levelStageView:popStageStrategy()
						end

						arg_92_0()
					end
				}, var_86_3)
				coroutine.yield()
			end

			assert(var_88_1)

			if var_86_1.type == ChapterConst.OpSkipBattle or var_86_1.type == ChapterConst.OpPreClear then
				self.viewComponent.levelStageView:tryAutoAction(function()
					if not self.viewComponent.levelStageView then
						return
					end

					self.viewComponent.levelStageView:tryAutoTrigger()
				end)
			elseif var_86_1.type == ChapterConst.OpRetreat then
				local var_88_12 = getProxy(ContextProxy):getContextByMediator(LevelMediator2)

				if var_88_12 then
					local var_88_13 = {}
					local var_88_14 = var_88_12:getContextByMediator(ChapterPreCombatMediator)

					if var_88_14 then
						table.insert(var_88_13, var_88_14)
					end

					_.each(var_88_13, function(arg_97_0)
						self:sendNotification(GAME.REMOVE_LAYERS, {
							context = arg_97_0
						})
					end)
				end

				if var_86_1.id then
					return
				end

				local var_88_15 = getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_PROGRESSLOGIN)

				if var_88_15 and not var_88_15.autoActionForbidden and not var_88_15.achieved and var_88_15.data1 == 7 and var_88_1.id == 204 and var_88_1:isClear() then
					pg.MsgboxMgr.GetInstance():ShowMsgBox({
						modal = true,
						hideNo = true,
						content = "有新的签到奖励可以领取，点击确定前往",
						onYes = function()
							self:sendNotification(GAME.GO_SCENE, SCENE.ACTIVITY)
						end,
						onNo = function()
							self:sendNotification(GAME.GO_SCENE, SCENE.ACTIVITY)
						end
					})

					return
				end

				self:OnExitChapter(var_88_1, var_86_1.win, var_86_1.extendData)
			elseif var_86_1.type == ChapterConst.OpMove then
				seriesAsync({
					function(arg_100_0)
						var_88_1 = self.contextData.chapterVO

						var_88_1.fleet:SetLine(var_86_1.fullpath[#var_86_1.fullpath])
						getProxy(ChapterProxy):updateChapter(var_88_1)
						self.viewComponent.grid:moveFleet(var_86_1.path, var_86_1.fullpath, var_86_1.oldLine, arg_100_0)
					end,
					function(arg_101_0)
						if not var_86_1.teleportPaths then
							arg_101_0()

							return
						end

						local var_101_0 = var_86_1.teleportPaths[1]

						if not var_86_1.teleportPaths[1] or not var_86_1.teleportPaths[2] then
							arg_101_0()

							return
						end

						var_88_1 = self.contextData.chapterVO

						local var_101_1 = var_88_1:getFleet(FleetType.Normal, var_101_0.row, var_101_0.column)

						if not var_101_1 then
							arg_101_0()

							return
						end

						var_101_1.line = Clone(var_86_1.teleportPaths[2])

						getProxy(ChapterProxy):updateChapter(var_88_1)
						self:getViewComponent().grid:TeleportCellByPortalWithCameraMove(var_101_1, self:getViewComponent().grid:GetCellFleet(var_101_1.id), var_86_1.teleportPaths, arg_101_0)
					end,
					function(arg_102_0)
						self:playAIActions(var_86_1.aiActs, var_86_1.extraFlag, arg_102_0)
					end
				}, function()
					var_88_1 = self.contextData.chapterVO

					if _.any(var_88_1.fleet:getStrategies(), function(arg_104_0)
						return arg_104_0.id == ChapterConst.StrategyExchange and arg_104_0.count > 0
					end) then
						self.viewComponent.levelStageView:popStageStrategy()
					end

					self.viewComponent.grid:updateQuadCells(ChapterConst.QuadStateNormal)
					self.viewComponent.levelStageView:updateAmbushRate(var_88_1.fleet.line, true)
					self.viewComponent.levelStageView:updateStageStrategy()
					self.viewComponent.levelStageView:updateFleetBuff()
					self.viewComponent.levelStageView:updateBombPanel()
					self.viewComponent.levelStageView:tryAutoTrigger()
				end)
			elseif var_86_1.type == ChapterConst.OpAmbush then
				self.viewComponent.levelStageView:tryAutoTrigger()
			elseif var_86_1.type == ChapterConst.OpBox then
				self:playAIActions(var_86_1.aiActs, var_86_1.extraFlag, function()
					if not self.viewComponent.levelStageView then
						return
					end

					self.viewComponent.levelStageView:tryAutoTrigger()
				end)
			elseif var_86_1.type == ChapterConst.OpStory then
				self.viewComponent.levelStageView:tryAutoTrigger()
			elseif var_86_1.type == ChapterConst.OpSwitch then
				self.viewComponent.grid:adjustCameraFocus()
			elseif var_86_1.type == ChapterConst.OpEnemyRound then
				self:playAIActions(var_86_1.aiActs, var_86_1.extraFlag, function()
					self.viewComponent.levelStageView:updateBombPanel(true)

					if _.any(var_88_1.fleet:getStrategies(), function(arg_107_0)
						return arg_107_0.id == ChapterConst.StrategyExchange and arg_107_0.count > 0
					end) then
						self.viewComponent.levelStageView:updateStageStrategy()
						self.viewComponent.levelStageView:popStageStrategy()
					end

					self.viewComponent.levelStageView:tryAutoTrigger()
					self.viewComponent:updatePoisonAreaTip()
				end)
			elseif var_86_1.type == ChapterConst.OpSubState then
				self:saveSubState(var_88_1.subAutoAttack)
				self.viewComponent.grid:OnChangeSubAutoAttack()
			elseif var_86_1.type == ChapterConst.OpStrategy then
				if var_86_1.arg1 == ChapterConst.StrategyExchange then
					for iter_88_0, iter_88_1 in ipairs((var_88_1.fleet:findSkills(FleetSkill.TypeStrategy))) do
						if iter_88_1:GetType() == FleetSkill.TypeStrategy and iter_88_1:GetArgs()[1] == ChapterConst.StrategyExchange then
							self.viewComponent:doPlayCommander((var_88_1.fleet:findCommanderBySkillId(iter_88_1.id)))

							break
						end
					end
				end

				self:playAIActions(var_86_1.aiActs, var_86_1.extraFlag, function()
					self.viewComponent.grid:updateQuadCells(ChapterConst.QuadStateNormal)
				end)
			elseif var_86_1.type == ChapterConst.OpSupply then
				self.viewComponent.levelStageView:tryAutoTrigger()
			elseif var_86_1.type == ChapterConst.OpBarrier then
				self.viewComponent.levelStageView:tryAutoTrigger()
			elseif var_86_1.type == ChapterConst.OpSubTeleport then
				seriesAsync({
					function(arg_109_0)
						local var_109_0 = _.detect(var_88_1.fleets, function(arg_110_0)
							return arg_110_0.id == var_86_1.id
						end)

						var_109_0.line = {
							row = var_86_1.arg1,
							column = var_86_1.arg2
						}
						var_109_0.startPos = {
							row = var_86_1.arg1,
							column = var_86_1.arg2
						}

						local var_109_1 = getProxy(PlayerProxy)
						local var_109_2 = var_109_1:getData()

						var_109_2:consume({
							oil = math.ceil(pg.strategy_data_template[ChapterConst.StrategySubTeleport].arg[2] * #var_109_0:getShips(false) * var_88_1:findPath(nil, var_86_1.fullpath[1], var_86_1.fullpath[#var_86_1.fullpath]) - 1e-05)
						})
						self.viewComponent:updateRes(var_109_2)
						var_109_1:updatePlayer(var_109_2)
						self.viewComponent.grid:moveSub(table.indexof(var_88_1.fleets, var_109_0), var_86_1.fullpath, nil, function()
							getProxy(ChapterProxy):updateChapter(var_88_1, (bit.bor(ChapterConst.DirtyFleet, ChapterConst.DirtyAttachment, ChapterConst.DirtyChampionPosition)))

							var_88_1 = self.contextData.chapterVO

							arg_109_0()
						end)
					end,
					function(arg_112_0)
						if not var_86_1.teleportPaths then
							arg_112_0()

							return
						end

						if not var_86_1.teleportPaths[1] or not var_86_1.teleportPaths[2] then
							arg_112_0()

							return
						end

						local var_112_0 = _.detect(var_88_1.fleets, function(arg_113_0)
							return arg_113_0.id == var_86_1.id
						end)

						var_112_0.startPos = Clone(var_86_1.teleportPaths[2])
						var_112_0.line = Clone(var_86_1.teleportPaths[2])

						self:getViewComponent().grid:TeleportFleetByPortal(self:getViewComponent().grid:GetCellFleet(var_112_0.id), var_86_1.teleportPaths, function()
							getProxy(ChapterProxy):updateChapter(var_88_1, (bit.bor(ChapterConst.DirtyFleet, ChapterConst.DirtyAttachment, ChapterConst.DirtyChampionPosition)))

							var_88_1 = self.contextData.chapterVO

							arg_112_0()
						end)
					end,
					function(arg_115_0)
						self.viewComponent.levelStageView:SwitchBottomStagePanel(false)
						self.viewComponent.grid:TurnOffSubTeleport()
						self.viewComponent.grid:updateQuadCells(ChapterConst.QuadStateNormal)
					end
				})
			end
		end)

		var_86_3()
	elseif var_86_0 == ChapterProxy.CHAPTER_TIMESUP then
		self:onTimeUp()
	elseif var_86_0 == GAME.EVENT_LIST_UPDATE then
		self.viewComponent:addbubbleMsgBox(function(arg_116_0)
			self:OnEventUpdate(arg_116_0)
		end)
	elseif var_86_0 == GAME.VOTE_BOOK_BE_UPDATED_DONE then
		self.viewComponent:addbubbleMsgBox(function(arg_117_0)
			self:NoticeVoteBook(arg_117_0)
		end)
	elseif var_86_0 == DailyLevelProxy.ELITE_QUOTA_UPDATE then
		self.viewComponent:setEliteQuota(getProxy(DailyLevelProxy).eliteCount, pg.gameset.elite_quota.key_value)
	elseif var_86_0 == ActivityProxy.ACTIVITY_OPERATION_DONE then
		self.viewComponent.mapBuilder:UpdateMapItems()
	elseif var_86_0 == ActivityProxy.ACTIVITY_UPDATED then
		if var_86_1 and self.viewComponent.ptActivity and var_86_1.id == self.viewComponent.ptActivity.id then
			self.viewComponent:updatePtActivity(var_86_1)
		end
	elseif var_86_0 == GAME.GET_REMASTER_TICKETS_DONE then
		self.viewComponent:emit(BaseUI.ON_ACHIEVE, var_86_1, function()
			self.viewComponent:updateRemasterTicket()
		end)
	elseif var_86_0 == GAME.ACTIVITY_PERMANENT_START_DONE then
		local var_86_4 = var_86_1 and var_86_1.id

		if (var_86_1 and var_86_1.id) ~= self.bossRushRemasterActivityId then
			return
		end

		if not getProxy(ActivityPermanentProxy):IsActivityIdByType(var_86_4, ActivityPermanentProxy.TYPE_REMASTER_ACTIVITY) then
			return
		end

		self.bossRushRemasterActivityId = nil

		self:sendNotification(GAME.GO_SCENE, SCENE.BOSSRUSH_REMASTER, {
			id = var_86_4
		})
	elseif var_86_0 == CommanderProxy.PREFAB_FLEET_UPDATE then
		self.viewComponent:setCommanderPrefabs((getProxy(CommanderProxy):getPrefabFleet()))
		self.viewComponent:updateCommanderPrefab()
	elseif var_86_0 == GAME.COOMMANDER_EQUIP_TO_FLEET_DONE then
		self.viewComponent:updateFleet((getProxy(FleetProxy):GetRegularFleets()))
		self.viewComponent:RefreshFleetSelectView()
	elseif var_86_0 == GAME.SUBMIT_TASK_DONE then
		if self.contextData.map and self.contextData.map:isSkirmish() then
			self.viewComponent.mapBuilder:UpdateMapItems()
		end

		self.viewComponent:emit(BaseUI.ON_ACHIEVE, var_86_1, function()
			if self.contextData.map and self.contextData.map:isSkirmish() and self.contextData.TaskToSubmit then
				self.contextData.TaskToSubmit = nil

				self:sendNotification(GAME.SUBMIT_TASK, self.contextData.TaskToSubmit)
			end

			self.viewComponent.mapBuilder:OnSubmitTaskDone()
		end)
	elseif var_86_0 == GAME.SUBMIT_ACTIVITY_TASK_DONE then
		self.viewComponent:emit(BaseUI.ON_ACHIEVE, var_86_1.awards, function()
			self.viewComponent.mapBuilder:OnSubmitTaskDone()
		end)
	elseif var_86_0 == BagProxy.ITEM_UPDATED then
		self.viewComponent:setSpecialOperationTickets((getProxy(BagProxy):getItemsByType(Item.SPECIAL_OPERATION_TICKET)))
	elseif var_86_0 == ChapterProxy.CHAPTER_AUTO_FIGHT_FLAG_UPDATED then
		if not self:getViewComponent().levelStageView then
			return
		end

		self:getViewComponent().levelStageView:ActionInvoke("UpdateAutoFightMark")
	elseif var_86_0 == ChapterProxy.CHAPTER_SKIP_PRECOMBAT_UPDATED then
		if not self:getViewComponent().levelStageView then
			return
		end

		self:getViewComponent().levelStageView:ActionInvoke("UpdateSkipPreCombatMark")
	elseif var_86_0 == ChapterProxy.CHAPTER_REMASTER_INFO_UPDATED or var_86_0 == GAME.CHAPTER_REMASTER_INFO_REQUEST_DONE then
		self.viewComponent:updateRemasterInfo()
		self.viewComponent:updateRemasterBtnTip()
	elseif var_86_0 == GAME.CHAPTER_REMASTER_AWARD_RECEIVE_DONE then
		self.viewComponent:emit(BaseUI.ON_ACHIEVE, var_86_1)
	elseif var_86_0 == GAME.STORY_UPDATE_DONE then
		self.cachedStoryAwards = var_86_1
	elseif var_86_0 == GAME.STORY_END then
		if self.cachedStoryAwards then
			self.viewComponent:emit(BaseUI.ON_ACHIEVE, self.cachedStoryAwards.awards)

			self.cachedStoryAwards = nil
		end
	elseif var_86_0 == LevelUIConst.CONTINUOUS_OPERATION then
		self.viewComponent:emit(LevelUIConst.CONTINUOUS_OPERATION, var_86_1)
	elseif var_86_0 == GAME.TRACKING_ERROR then
		if self.waitingTracking then
			self:DisplayContinuousOperationResult(var_86_1.chapter, getProxy(ChapterProxy):PopContinuousData(SYSTEM_SCENARIO))
		end

		self.waitingTracking = nil
	elseif var_86_0 == LevelMediator2.ON_SPITEM_CHANGED then
		self.viewComponent:emit(LevelMediator2.ON_SPITEM_CHANGED, var_86_1)
	elseif var_86_0 == GAME.START_CHAPTER_AUTO_DONE then
		self.viewComponent:OnStartChapterAuto(var_86_1)
		self.viewComponent.mapBuilder:UpdateChapterTF(var_86_1.id)

		if var_86_1.isRemaster then
			self.viewComponent:updateRemasterTicket()
		end
	elseif var_86_0 == GAME.END_CHAPTER_AUTO_DONE then
		self.viewComponent:OnEndChapterAuto(var_86_1)
		self.viewComponent:HideChapterAutoDetailPanel(var_86_1)
		self.viewComponent.mapBuilder:UpdateChapterTF(var_86_1.id)

		if var_86_1.isRemaster then
			self.viewComponent:updateRemasterTicket()
		end

		self:addSubLayers(Context.New({
			viewComponent = ChapterAutoTotalRewardLayer,
			mediator = ChapterAutoTotalRewardMediator,
			data = {
				rewards = var_86_1.awards,
				totalTimes = var_86_1.allCnt,
				finishTimes = var_86_1.finishCnt,
				proficiency = var_86_1.proficiency
			}
		}), true)
	elseif var_86_0 == GAME.ADD_CHAPTER_AUTO_TIME_DONE then
		self.viewComponent:OnAddChapterAutoTimeDone(var_86_1)
	elseif var_86_0 == ChapterAutoProxy.FINISH_UPDATE then
		self.viewComponent.mapBuilder:UpdateMapItems()
	end
end

function LevelMediator2:OnExitChapter(arg_121_1, arg_121_2, arg_121_3)
	assert(arg_121_1)
	seriesAsync({
		function(arg_122_0)
			if not self.contextData.chapterVO then
				return arg_122_0()
			end

			self.viewComponent:switchToMap(arg_122_0)
		end,
		function(arg_123_0)
			self.viewComponent:addbubbleMsgBox(function()
				self.viewComponent:CleanBubbleMsgbox()
				arg_123_0()
			end)
		end,
		function(arg_125_0)
			if not arg_121_2 then
				return arg_125_0()
			end

			if arg_121_1.id == 103 and not getProxy(PlayerProxy):getData():GetCommonFlag(BATTLE_AUTO_ENABLED) then
				self.viewComponent:HandleShowMsgBox({
					modal = true,
					hideNo = true,
					content = i18n("battle_autobot_unlock"),
					onYes = arg_125_0,
					onNo = arg_125_0
				})
				self.viewComponent:emit(LevelMediator2.NOTICE_AUTOBOT_ENABLED, {})

				return
			end

			arg_125_0()
		end,
		function(arg_126_0)
			if not arg_121_2 then
				return arg_126_0()
			end

			if getProxy(ChapterProxy):getMapById(arg_121_1:getConfig("map")):isSkirmish() then
				local var_126_0 = arg_121_1.id
				local var_126_1 = getProxy(SkirmishProxy):getRawData()
				local var_126_2 = _.detect(var_126_1, function(arg_127_0)
					return tonumber(arg_127_0:getConfig("event")) == var_126_0
				end)

				if not var_126_2 then
					arg_126_0()

					return
				end

				local var_126_3 = getProxy(TaskProxy)
				local var_126_4 = var_126_2:getConfig("task_id")
				local var_126_5 = var_126_3:getTaskVO(var_126_4)

				if var_126_5 and var_126_5:getTaskStatus() == 1 then
					self:sendNotification(GAME.SUBMIT_TASK, var_126_4)

					if var_126_2 == var_126_1[#var_126_1] then
						local var_126_6 = getProxy(ActivityProxy):getActivityById(ActivityConst.ACTIVITY_ID_US_SKIRMISH_RE)

						assert(var_126_6, "Missing Skirmish Activity " .. (ActivityConst.ACTIVITY_ID_US_SKIRMISH_RE or "NIL"))

						local var_126_7 = var_126_6:getConfig("config_data")
						local var_126_8 = var_126_3:getTaskVO(var_126_7[#var_126_7][2])

						if var_126_8 and var_126_8:getTaskStatus() < 2 then
							self.contextData.TaskToSubmit = var_126_7[#var_126_7][2]
						end
					end
				end
			end

			arg_126_0()
		end,
		function(arg_128_0)
			if not arg_121_2 then
				return arg_128_0()
			end

			local var_128_0 = getProxy(ChapterProxy):getMapById(arg_121_1:getConfig("map"))

			if var_128_0:isRemaster() then
				local var_128_1 = var_128_0:getRemaster()
				local var_128_2 = Map.GetRearChaptersOfRemaster(var_128_1)

				assert(var_128_2)

				if _.any(var_128_2, function(arg_129_0)
					return arg_129_0 == arg_121_1.id
				end) and BossRushChapterRemasterHelper.UnlockMemoryGroupStoriesAndShowMsgBox(pg.re_map_template[var_128_1].memory_group, arg_128_0) then
					return
				end
			end

			arg_128_0()
		end,
		function(arg_130_0)
			if self.contextData.map and not self.contextData.map:isUnlock() then
				self.viewComponent:emit(LevelMediator2.ON_SWITCH_NORMAL_MAP)

				return
			end

			if not arg_121_3 then
				return arg_130_0()
			end

			local var_130_0 = arg_121_3 and arg_121_3.AutoFightFlag
			local var_130_1 = {}

			if arg_121_3 and arg_121_3.ResultDrops then
				for iter_130_0, iter_130_1 in ipairs(arg_121_3.ResultDrops) do
					var_130_1 = table.mergeArray(var_130_1, iter_130_1)
				end
			end

			local var_130_2 = {}

			if arg_121_3 and arg_121_3.TotalDrops then
				for iter_130_2, iter_130_3 in ipairs(arg_121_3.TotalDrops) do
					var_130_2 = table.mergeArray(var_130_2, iter_130_3)
				end
			end

			DropResultIntegration(var_130_2)

			local var_130_3 = getProxy(ChapterProxy):GetContinuousData(SYSTEM_SCENARIO)

			if var_130_3 then
				var_130_3:MergeDrops(var_130_2, var_130_1)
				var_130_3:MergeEvents(arg_121_3.ListEventNotify, arg_121_3.ListGuildEventNotify, arg_121_3.ListGuildEventAutoReceiveNotify)

				if arg_121_2 then
					var_130_3:ConsumeBattleTime()
				end

				if var_130_3:IsActive() and var_130_3:GetRestBattleTime() > 0 then
					self.waitingTracking = true

					self.viewComponent:emit(LevelMediator2.ON_RETRACKING, arg_121_1, var_130_0)

					return
				end

				getProxy(ChapterProxy):PopContinuousData(SYSTEM_SCENARIO)
				self:DisplayContinuousOperationResult(arg_121_1, var_130_3)
				arg_130_0()

				return
			end

			local var_130_4 = var_130_0 ~= nil

			if var_130_0 == nil and not arg_121_3.ResultDrops then
				return arg_130_0()
			end

			local var_130_5
			local var_130_6

			if var_130_4 then
				var_130_5 = i18n("autofight_rewards")
				var_130_6 = i18n("total_rewards_subtitle")
			else
				var_130_5 = i18n("settle_rewards_title")
				var_130_6 = i18n("settle_rewards_subtitle")
			end

			self:addSubLayers(Context.New({
				viewComponent = LevelStageTotalRewardPanel,
				mediator = LevelStageTotalRewardPanelMediator,
				data = {
					title = var_130_5,
					subTitle = var_130_6,
					chapter = arg_121_1,
					onClose = arg_130_0,
					rewards = var_130_2,
					resultRewards = var_130_1,
					events = arg_121_3.ListEventNotify,
					guildTasks = arg_121_3.ListGuildEventNotify,
					guildAutoReceives = arg_121_3.ListGuildEventAutoReceiveNotify,
					isAutoFight = var_130_0
				}
			}), true)
		end,
		function(arg_131_0)
			if Map.autoNextPage then
				Map.autoNextPage = nil

				triggerButton(self.viewComponent.btnNext)
			end

			if arg_121_2 then
				self.viewComponent:RefreshMapBG()
			end

			self:TryPlaySubGuide()
		end
	})
end

function LevelMediator2:DisplayContinuousWindow(arg_132_1, arg_132_2, arg_132_3, arg_132_4)
	local var_132_0 = arg_132_1:getConfig("oil")

	if arg_132_1:IsSupportSubmarineStage() and #arg_132_1:getSupportFleet() > 0 then
		var_132_0 = var_132_0 + getGameset("submarine_support_oil_consume")[1]

		local var_132_1 = 0
		local var_132_2 = 0
	end

	if arg_132_1:getPlayType() == ChapterConst.TypeMultiStageBoss then
		var_132_1 = _.reduce(pg.chapter_model_multistageboss[arg_132_1.id].boss_refresh, 0, function(arg_133_0, arg_133_1)
			return arg_133_0 + arg_133_1
		end)
		var_132_2 = #pg.chapter_model_multistageboss[arg_132_1.id].boss_refresh
	else
		var_132_2 = 1
		var_132_1 = arg_132_1:getConfig("boss_refresh")
	end

	local var_132_3 = arg_132_1:getConfig("use_oil_limit")

	table.Foreach(arg_132_2, function(arg_134_0, arg_134_1)
		if arg_132_4[arg_134_0] == ChapterFleet.DUTY_IDLE then
			return
		end

		local var_134_0 = arg_134_1:GetCostSum().oil

		if arg_132_4[arg_134_0] == ChapterFleet.DUTY_KILLALL then
			local var_134_1 = var_132_3[1] or 0
			local var_134_2 = var_134_0

			if var_134_1 > 0 then
				var_134_2 = math.min(var_134_2, var_134_1)
			end

			local var_134_3 = var_132_3[2] or 0
			local var_134_4 = var_134_0

			if var_134_3 > 0 then
				var_134_4 = math.min(var_134_4, var_134_3)
			end

			var_132_0 = var_132_0 + var_134_2 * var_132_1 + var_134_4 * var_132_2
		elseif arg_132_4[arg_134_0] == ChapterFleet.DUTY_CLEANPATH then
			local var_134_5 = var_132_3[1] or 0
			local var_134_6 = var_134_0

			if var_134_5 > 0 then
				var_134_6 = math.min(var_134_6, var_134_5)
			end

			var_132_0 = var_132_0 + var_134_6 * var_132_1
		elseif arg_132_4[arg_134_0] == ChapterFleet.DUTY_KILLBOSS then
			local var_134_7 = var_132_3[2] or 0
			local var_134_8 = var_134_0

			if var_134_7 > 0 then
				var_134_8 = math.min(var_134_8, var_134_7)
			end

			var_132_0 = var_132_0 + var_134_8 * var_132_2
		end
	end)

	local var_132_4 = arg_132_1:GetMaxBattleCount()
	local var_132_5 = arg_132_3 and arg_132_3 > 0
	local var_132_6 = arg_132_1:GetSpItems()

	if var_132_6[1] then
		local var_132_7 = var_132_6[1].count or 0

		if var_132_6[1] then
			local var_132_8 = var_132_6[1].id
			local var_132_11
			local var_132_10
			local var_132_9

			if not var_132_6[1].id then
				var_132_8 = 0
				var_132_9 = {
					mediator = LevelContinuousOperationWindowMediator,
					viewComponent = LevelContinuousOperationWindow
				}
				var_132_10 = {
					maxCount = var_132_4,
					oilCost = var_132_0,
					chapter = arg_132_1
				}
				var_132_11 = {
					rate = 2,
					enabled = var_132_5,
					extraCount = var_132_7,
					spItemId = var_132_8
				}
			end
		end
	end

	var_132_11.freeBonus = arg_132_1:GetRestDailyBonus()
	var_132_10.extraRate = var_132_11
	var_132_9.data = var_132_10

	self:addSubLayers(Context.New(var_132_9))
end

function LevelMediator2:DisplayContinuousOperationResult(arg_135_1, arg_135_2)
	self:addSubLayers(Context.New({
		viewComponent = LevelContinuousOperationTotalRewardPanel,
		mediator = LevelStageTotalRewardPanelMediator,
		data = {
			title = i18n("autofight_rewards"),
			subTitle = i18n("total_rewards_subtitle"),
			chapter = arg_135_1,
			rewards = arg_135_2:GetDrops(),
			resultRewards = arg_135_2:GetSettlementDrops(),
			continuousData = arg_135_2,
			events = arg_135_2:GetEvents(1),
			guildTasks = arg_135_2:GetEvents(2),
			guildAutoReceives = arg_135_2:GetEvents(3)
		}
	}), true)
end

function LevelMediator2:OnEventUpdate(arg_136_1)
	local var_136_0 = getProxy(EventProxy)

	self.viewComponent:updateEvent(var_136_0)

	if pg.SystemOpenMgr.GetInstance():isOpenSystem(self.player.level, "EventMediator") and var_136_0.eventForMsg then
		local var_136_1 = var_136_0.eventForMsg.id or 0
		local var_136_2 = getProxy(ChapterProxy):getActiveChapter(true)

		if var_136_2 and var_136_2:IsAutoFight() then
			getProxy(ChapterProxy):AddExtendChapterDataArray(var_136_2.id, "ListEventNotify", var_136_1)
			existCall(arg_136_1)
		else
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				modal = false,
				hideNo = true,
				content = i18n("event_special_update", (pg.collection_template[var_136_1] or nil) and (pg.collection_template[var_136_1].title or "")),
				onYes = arg_136_1,
				onNo = arg_136_1
			})
		end

		var_136_0.eventForMsg = nil
	else
		existCall(arg_136_1)
	end
end

function LevelMediator2:onTimeUp()
	local var_137_0 = getProxy(ChapterProxy):getActiveChapter()

	if var_137_0 and not var_137_0:inWartime() then
		local function var_137_1()
			self:sendNotification(GAME.CHAPTER_OP, {
				type = ChapterConst.OpRetreat
			})
		end

		if self.contextData.chapterVO then
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				modal = true,
				hideNo = true,
				content = i18n("battle_preCombatMediator_timeout"),
				onYes = var_137_1,
				onNo = var_137_1
			})
		else
			var_137_1()
			pg.TipsMgr.GetInstance():ShowTips(i18n("levelScene_chapter_timeout"))
		end
	end
end

function LevelMediator2:getDockCallbackFuncs(arg_139_1, arg_139_2, arg_139_3, arg_139_4)
	local var_139_0 = getProxy(ChapterProxy)

	return function(arg_140_0, arg_140_1)
		local var_140_0, var_140_1 = ShipStatus.ShipStatusCheck("inElite", arg_140_0, arg_140_1, {
			inElite = arg_139_3:getConfig("formation")
		})

		if not var_140_0 then
			return var_140_0, var_140_1
		end

		for iter_140_0, iter_140_1 in pairs(arg_139_1) do
			if arg_140_0:isSameKind(iter_140_0) then
				return false, i18n("ship_formationMediator_changeNameError_sameShip")
			end
		end

		return true
	end, function(arg_141_0, arg_141_1, arg_141_2)
		arg_141_1()
	end, function(arg_142_0)
		local var_142_0 = arg_139_3:getEliteFleetList()[arg_139_4]

		if arg_139_2 then
			local var_142_1 = table.indexof(var_142_0, arg_139_2.id)

			assert(var_142_1)

			if arg_142_0[1] then
				var_142_0[var_142_1] = arg_142_0[1]
			else
				table.remove(var_142_0, var_142_1)
			end
		else
			table.insert(var_142_0, arg_142_0[1])
		end

		arg_139_3:setEliteFleetByIndex(arg_139_4, {
			{
				TeamType.FormShips,
				var_142_0
			}
		})
		var_139_0:updateChapter(arg_139_3)
		var_139_0:duplicateEliteFleet(arg_139_3)
	end
end

function LevelMediator2:getSupportDockCallbackFuncs(arg_143_1, arg_143_2, arg_143_3)
	local var_143_0 = getProxy(ChapterProxy)

	return function(arg_144_0, arg_144_1)
		local var_144_0, var_144_1 = ShipStatus.ShipStatusCheck("inSupport", arg_144_0, arg_144_1)

		if not var_144_0 then
			return var_144_0, var_144_1
		end

		for iter_144_0, iter_144_1 in pairs(arg_143_1) do
			if arg_144_0:isSameKind(iter_144_0) then
				return false, i18n("ship_formationMediator_changeNameError_sameShip")
			end
		end

		return true
	end, function(arg_145_0, arg_145_1, arg_145_2)
		arg_145_1()
	end, function(arg_146_0)
		local var_146_0 = arg_143_3:getSupportFleet()

		if arg_143_2 then
			local var_146_1 = table.indexof(var_146_0, arg_143_2.id)

			assert(var_146_1)

			if arg_146_0[1] then
				var_146_0[var_146_1] = arg_146_0[1]
			else
				table.remove(var_146_0, var_146_1)
			end
		else
			table.insert(var_146_0, arg_146_0[1])
		end

		arg_143_3:setEliteFleetByIndex(4, {
			{
				TeamType.FormShips,
				var_146_0
			}
		})
		var_143_0:updateChapter(arg_143_3)
		var_143_0:duplicateEliteFleet(arg_143_3)
	end
end

function LevelMediator2:playAIActions(arg_147_1, arg_147_2, arg_147_3)
	if not self.viewComponent.grid then
		arg_147_3()

		return
	end

	local var_147_0 = getProxy(ChapterProxy)
	local var_147_1

	local function var_147_2()
		if var_147_1 and coroutine.status(var_147_1) == "suspended" then
			local var_148_0, var_148_1 = coroutine.resume(var_147_1)

			assert(var_148_0, debug.traceback(var_147_1, var_148_1))

			if not var_148_0 then
				self.viewComponent:unfrozen(-1)
				self:sendNotification(GAME.CHAPTER_OP, {
					type = ChapterConst.OpRequest
				})
			end
		end
	end

	var_147_1 = coroutine.create(function()
		self.viewComponent:frozen()

		local var_149_0 = {}
		local var_149_1 = arg_147_2 or 0

		for iter_149_0, iter_149_1 in ipairs(arg_147_1) do
			local var_149_2 = self.contextData.chapterVO
			local var_149_3, var_149_4 = iter_149_1:applyTo(self.contextData.chapterVO, true)

			assert(var_149_3, var_149_4)
			iter_149_1:PlayAIAction(self.contextData.chapterVO, self, function()
				local var_150_0, var_150_1, var_150_2 = iter_149_1:applyTo(var_149_2, false)

				if var_150_0 then
					var_147_0:updateChapter(var_149_2, var_150_1)

					var_149_1 = bit.bor(var_149_1, var_150_2 or 0)
				end

				onNextTick(var_147_2)
			end)
			coroutine.yield()

			if isa(iter_149_1, FleetAIAction) and iter_149_1.actType == ChapterConst.ActType_Poison and self.contextData.chapterVO:existFleet(FleetType.Normal, iter_149_1.line.row, iter_149_1.line.column) then
				table.insert(var_149_0, (self.contextData.chapterVO:getFleetIndex(FleetType.Normal, iter_149_1.line.row, iter_149_1.line.column)))
			end
		end

		local var_149_5 = bit.band(var_149_1, ChapterConst.DirtyAutoAction)

		var_149_1 = bit.band(var_149_1, bit.bnot(ChapterConst.DirtyAutoAction))

		if var_149_1 ~= 0 then
			var_147_0:updateChapter(self.contextData.chapterVO, var_149_1)
		end

		seriesAsync({
			function(arg_151_0)
				if var_149_5 ~= 0 then
					self.viewComponent.levelStageView:tryAutoAction(arg_151_0)
				else
					arg_151_0()
				end
			end,
			function(arg_152_0)
				table.ParallelIpairsAsync(var_149_0, function(arg_153_0, arg_153_1, arg_153_2)
					self.viewComponent.grid:showFleetPoisonDamage(arg_153_1, arg_153_2)
				end, arg_152_0)
			end,
			function(arg_154_0)
				arg_147_3()
				self.viewComponent:unfrozen()
			end
		})
	end)

	var_147_2()
end

function LevelMediator2:saveSubState(arg_155_1)
	PlayerPrefs.SetInt("chapter_submarine_ai_type_" .. getProxy(PlayerProxy):getRawData().id, arg_155_1 + 1)
	PlayerPrefs.Save()
end

function LevelMediator2:loadSubState(arg_156_1)
	local var_156_0 = math.clamp(PlayerPrefs.GetInt("chapter_submarine_ai_type_" .. getProxy(PlayerProxy):getRawData().id, 1) - 1, 0, 1)

	if var_156_0 ~= arg_156_1 then
		self.viewComponent:emit(LevelMediator2.ON_OP, {
			type = ChapterConst.OpSubState,
			arg1 = var_156_0
		})
	end
end

function LevelMediator2:remove()
	self:removeSubLayers(LevelContinuousOperationWindowMediator)
	LevelMediator2.super.remove(self)
end

return LevelMediator2
