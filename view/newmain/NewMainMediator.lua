local NewMainMediator = class("NewMainMediator", import("..base.ContextMediator"))

NewMainMediator.GO_SCENE = "NewMainMediator.GO_SCENE"
NewMainMediator.OPEN_MAIL = "NewMainMediator.OPEN_MAIL"
NewMainMediator.OPEN_NOTICE = "NewMainMediator.OPEN_NOTICE"
NewMainMediator.GO_SNAPSHOT = "NewMainMediator.GO_SNAPSHOT"
NewMainMediator.OPEN_COMMISION = "NewMainMediator.OPEN_COMMISION"
NewMainMediator.OPEN_CHATVIEW = "NewMainMediator.OPEN_CHATVIEW"
NewMainMediator.SKIP_SCENE = "NewMainMediator.SKIP_SCENE"
NewMainMediator.SKIP_ACTIVITY = "NewMainMediator.SKIP_ACTIVITY"
NewMainMediator.SKIP_CORE_ACTIVITY = "NewMainMediator.SKIP_CORE_ACTIVITY"
NewMainMediator.SKIP_SHOP = "NewMainMediator.SKIP_SHOP"
NewMainMediator.GO_MINI_GAME = "NewMainMediator.GO_MINI_GAME"
NewMainMediator.SKIP_ACTIVITY_MAP = "NewMainMediator.SKIP_ACTIVITY_MAP"
NewMainMediator.SKIP_ESCORT = "NewMainMediator.SKIP_ESCORT"
NewMainMediator.SKIP_INS = "NewMainMediator.SKIP_INS"
NewMainMediator.SKIP_LOTTERY = "NewMainMediator.SKIP_LOTTERY"
NewMainMediator.GO_SINGLE_ACTIVITY = "NewMainMediator.GO_SINGLE_ACTIVITY"
NewMainMediator.REFRESH_VIEW = "NewMainMediator.REFRESH_VIEW"
NewMainMediator.OPEN_KINK_BUTTON_LAYER = "NewMainMediator.OPEN_KINK_BUTTON_LAYER"
NewMainMediator.OPEN_Compensate = "NewMainMediator.OPEN_Compensate"
NewMainMediator.ON_DROP = "NewMainMediator.ON_DROP"
NewMainMediator.ON_AWRADS = "NewMainMediator.ON_AWRADS"
NewMainMediator.CHANGE_SKIN_TOGGLE = "NewMainMediator.CHANGE_SKIN_TOGGLE"
NewMainMediator.FOLD_PANEL = "NewMainMediator.FOLD_PANEL"
NewMainMediator.HIDE_PANEL = "NewMainMediator.HIDE_PANEL"
NewMainMediator.REMOVE_LAYERS = "NewMainMediator.REMOVE_LAYERS"
NewMainMediator.DEBUG_BATTLE_LOOP = "NewMainMediator.DEBUG_BATTLE_LOOP"
NewMainMediator.OPEN_ACT_REMASTER_SCENE = "NewMainMediator.OPEN_ACT_REMASTER_SCENE"

function NewMainMediator:register()
	self:bind(NewMainMediator.OPEN_ACT_REMASTER_SCENE, function(arg_2_0, arg_2_1)
		self:sendNotification(GAME.GO_SCENE, SCENE.ACTREMASTE)
	end)
	self:bind(NewMainMediator.SKIP_LOTTERY, function(arg_3_0, arg_3_1)
		self:addSubLayers(Context.New({
			viewComponent = LotteryLayer,
			mediator = LotteryMediator,
			data = {
				activityId = arg_3_1
			}
		}))
	end)
	self:bind(NewMainMediator.SKIP_INS, function(arg_4_0)
		self:addSubLayers(Context.New({
			viewComponent = InstagramMainUI,
			mediator = InstagramMainMediator
		}))
	end)
	self:bind(NewMainMediator.SKIP_ESCORT, function(arg_5_0)
		local var_5_0 = getProxy(ChapterProxy)
		local var_5_1 = var_5_0:getMapsByType(Map.ESCORT)[1]
		local var_5_2 = var_5_0:getActiveChapter()
		local var_5_3 = GAME.GO_SCENE
		local var_5_4 = SCENE.LEVEL
		local var_5_5 = {}

		if var_5_2 and var_5_2:getConfig("map") == var_5_1.id then
			var_5_5.chapterId = var_5_2.id or nil
		end

		var_5_5.mapIdx = var_5_1.id

		pg.m02:sendNotification(var_5_3, var_5_4, var_5_5)
	end)
	self:bind(NewMainMediator.SKIP_ACTIVITY_MAP, function(arg_6_0, arg_6_1)
		local var_6_0 = getProxy(ChapterProxy)
		local var_6_1, var_6_2 = var_6_0:getLastMapForActivity(arg_6_1)

		if var_6_1 then
			if not var_6_0:getMapById(var_6_1):isUnlock() then
				pg.TipsMgr.GetInstance():ShowTips(i18n("common_activity_end"))

				goto label_6_0
			end
		end

		self:sendNotification(GAME.GO_SCENE, SCENE.LEVEL, {
			chapterId = var_6_2,
			mapIdx = var_6_1
		})

		::label_6_0::
	end)
	self:bind(NewMainMediator.SKIP_SHOP, function(arg_7_0, arg_7_1)
		self:sendNotification(GAME.GO_SCENE, SCENE.SHOP, {
			warp = arg_7_1 or NewShopsScene.TYPE_ACTIVITY
		})
	end)
	self:bind(NewMainMediator.SKIP_ACTIVITY, function(arg_8_0, arg_8_1)
		self:sendNotification(GAME.GO_SCENE, SCENE.ACTIVITY, {
			id = arg_8_1
		})
	end)
	self:bind(NewMainMediator.SKIP_CORE_ACTIVITY, function(arg_9_0, arg_9_1)
		self:sendNotification(GAME.GO_SCENE, SCENE.CORE_ACTIVITY, {
			coreName = arg_9_1
		})
	end)
	self:bind(NewMainMediator.SKIP_SCENE, function(arg_10_0, arg_10_1)
		self:sendNotification(GAME.GO_SCENE, arg_10_1[1], arg_10_1[2])
	end)
	self:bind(NewMainMediator.GO_MINI_GAME, function(arg_11_0, arg_11_1)
		self:sendNotification(GAME.GO_MINI_GAME, arg_11_1)
	end)
	self:bind(NewMainMediator.GO_SCENE, function(arg_12_0, arg_12_1, arg_12_2)
		self:sendNotification(GAME.GO_SCENE, arg_12_1, arg_12_2)
	end)
	self:bind(NewMainMediator.GO_SNAPSHOT, function(arg_13_0)
		local var_13_0 = self.viewComponent.paintingView:IsLive2DState()
		local var_13_1

		if isa(self.viewComponent.bgView.ship, VirtualEducateCharShip) then
			var_13_1 = self.viewComponent.bgView.ship.educateCharId
			var_13_0 = false
		end

		self:sendNotification(GAME.GO_SCENE, SCENE.SNAPSHOT, {
			skinId = self.viewComponent.bgView.ship:getSkinId(),
			live2d = var_13_0,
			tbId = var_13_1,
			propose = self.viewComponent.bgView.ship.propose
		})
	end)
	self:bind(NewMainMediator.OPEN_MAIL, function(arg_14_0)
		if BATTLE_DEBUG then
			self:sendNotification(GAME.BEGIN_STAGE, {
				system = SYSTEM_DEBUG
			})
		else
			self:sendNotification(GAME.GO_SCENE, SCENE.MAIL)
		end
	end)
	self:bind(NewMainMediator.OPEN_Compensate, function(arg_15_0)
		self:sendNotification(GAME.GO_SCENE, SCENE.Compensate)
	end)
	self:bind(NewMainMediator.OPEN_NOTICE, function(arg_16_0)
		self:addSubLayers(Context.New({
			mediator = NewBulletinBoardMediator,
			viewComponent = NewBulletinBoardLayer
		}))
	end)
	self:bind(NewMainMediator.OPEN_COMMISION, function(arg_17_0)
		self:addSubLayers(Context.New({
			viewComponent = CommissionInfoLayer,
			mediator = CommissionInfoMediator
		}))
	end)
	self:bind(NewMainMediator.OPEN_CHATVIEW, function(arg_18_0)
		self:addSubLayers(Context.New({
			viewComponent = NotificationLayer,
			mediator = NotificationMediator,
			data = {
				form = NotificationLayer.FORM_MAIN
			}
		}))
	end)
	self:bind(NewMainMediator.OPEN_KINK_BUTTON_LAYER, function(arg_19_0, arg_19_1)
		self:addSubLayers(arg_19_1)
	end)
	self:bind(NewMainMediator.CHANGE_SKIN_TOGGLE, function(arg_20_0, arg_20_1)
		self:sendNotification(GAME.CHANGE_SKIN_AB, arg_20_1)
	end)
	self:bind(NewMainMediator.DEBUG_BATTLE_LOOP, function(arg_21_0, arg_21_1)
		self:sendNotification(GAME.SEND_CMD, {
			cmd = "into",
			arg1 = arg_21_1
		})
	end)
end

function NewMainMediator:initNotificationHandleDic()
	self.handleDic = {
		[GAME.ON_OPEN_INS_LAYER] = function(arg_23_0, arg_23_1)
			arg_23_0.viewComponent:emit(NewMainMediator.SKIP_INS)
		end,
		[NotificationProxy.FRIEND_REQUEST_ADDED] = function(arg_24_0, arg_24_1)
			arg_24_0.viewComponent:emit(GAME.ANY_CHAT_MSG_UPDATE)
		end,
		[NotificationProxy.FRIEND_REQUEST_REMOVED] = NotificationProxy.FRIEND_REQUEST_ADDED,
		[FriendProxy.FRIEND_NEW_MSG] = NotificationProxy.FRIEND_REQUEST_ADDED,
		[FriendProxy.FRIEND_UPDATED] = NotificationProxy.FRIEND_REQUEST_ADDED,
		[ChatProxy.NEW_MSG] = NotificationProxy.FRIEND_REQUEST_ADDED,
		[GuildProxy.NEW_MSG_ADDED] = NotificationProxy.FRIEND_REQUEST_ADDED,
		[GAME.GET_GUILD_INFO_DONE] = NotificationProxy.FRIEND_REQUEST_ADDED,
		[GAME.GET_GUILD_CHAT_LIST_DONE] = NotificationProxy.FRIEND_REQUEST_ADDED,
		[GAME.BEGIN_STAGE_DONE] = function(arg_25_0, arg_25_1)
			arg_25_0:sendNotification(GAME.GO_SCENE, SCENE.COMBATLOAD, arg_25_1:getBody())
		end,
		[ChapterProxy.CHAPTER_TIMESUP] = function(arg_26_0, arg_26_1)
			MainChapterTimeUpSequence.New():Execute()
		end,
		[TechnologyConst.UPDATE_REDPOINT_ON_TOP] = function(arg_27_0, arg_27_1)
			MainTechnologySequence.New():Execute(function()
				return
			end)
		end,
		[GAME.FETCH_NPC_SHIP_DONE] = function(arg_29_0, arg_29_1)
			local var_29_0 = arg_29_1:getBody()

			arg_29_0.viewComponent:emit(BaseUI.ON_ACHIEVE, var_29_0.items, var_29_0.callback)
		end,
		[GAME.FETCH_NPC_SHIP_ACTIVITY_DONE] = GAME.FETCH_NPC_SHIP_DONE,
		[NewMainMediator.REFRESH_VIEW] = function(arg_30_0, arg_30_1)
			arg_30_0.viewComponent:setVisible(false)
			arg_30_0.viewComponent:setVisible(true)
		end,
		[GAME.CONFIRM_GET_SHIP] = function(arg_31_0, arg_31_1)
			local var_31_0 = arg_31_1:getBody()

			arg_31_0:addSubLayers(Context.New({
				mediator = BuildShipRemindMediator,
				viewComponent = BuildShipRemindLayer,
				data = {
					ships = var_31_0.ships
				},
				onRemoved = var_31_0.callback
			}))
		end,
		[GAME.CHANGE_LIVINGAREA_COVER_DONE] = function(arg_32_0, arg_32_1)
			arg_32_0.viewComponent:emit(NewMainScene.UPDATE_COVER)
		end,
		[GAME.ACT_INSTAGRAM_CHAT_DONE] = function(arg_33_0, arg_33_1)
			if arg_33_1:getBody().operation == ActivityConst.INSTAGRAM_CHAT_ACTIVATE_TOPIC then
				if arg_33_0.viewComponent.theme then
					arg_33_0.viewComponent.theme:Refresh((arg_33_0.viewComponent:GetFlagShip()))
				end
			end
		end,
		[NewMainMediator.ON_DROP] = function(arg_34_0, arg_34_1)
			arg_34_0.viewComponent:emit(BaseUI.ON_DROP, arg_34_1:getBody())
		end,
		[NewMainMediator.ON_AWRADS] = function(arg_35_0, arg_35_1)
			local var_35_0 = arg_35_1:getBody()

			arg_35_0.viewComponent:emit(BaseUI.ON_ACHIEVE, var_35_0.items, var_35_0.callback)
		end,
		[GAME.PLAY_CHANGE_SKIN_OUT] = function(arg_36_0, arg_36_1)
			arg_36_0.viewComponent:SetEffectPanelVisible(false)
			arg_36_0.viewComponent:HidePanel(true)
			arg_36_0.viewComponent:PlayChangeSkinActionOut(arg_36_1:getBody())
		end,
		[GAME.PLAY_CHANGE_SKIN_IN] = function(arg_37_0, arg_37_1)
			arg_37_0.viewComponent:PlayChangeSkinActionIn(arg_37_1:getBody())
		end,
		[GAME.PLAY_CHANGE_SKIN_FINISH] = function(arg_38_0, arg_38_1)
			arg_38_0.viewComponent:SetEffectPanelVisible(true)
			arg_38_0.viewComponent:HidePanel(false)
		end,
		[GAME.CHANGE_SKIN_EXCHANGE] = function(arg_39_0, arg_39_1)
			local var_39_0 = arg_39_1:getBody()
			local var_39_1 = not not var_39_0.asmr

			if arg_39_0.viewComponent then
				arg_39_0.viewComponent:UpdateFlagShip(arg_39_0.viewComponent:GetFlagShip(), var_39_0)
			end

			arg_39_0.viewComponent:AsmrTurning(var_39_1)
		end,
		[MusicPlayer.NO_PLAY_MUSIC_NOTIFICATION] = function(arg_40_0, arg_40_1)
			arg_40_0.viewComponent:CheckAndReplayBgm()
		end,
		[NewMainMediator.FOLD_PANEL] = function(arg_41_0, arg_41_1)
			arg_41_0.viewComponent:FoldPanels(arg_41_1:getBody())
		end,
		[NewMainMediator.HIDE_PANEL] = function(arg_42_0, arg_42_1)
			local var_42_0 = arg_42_1:getBody()

			arg_42_0.viewComponent:HidePanel(var_42_0.flag, var_42_0.content)
		end,
		[GAME.SERIES_GUIDE_END] = function(arg_43_0, arg_43_1)
			MainAwakeGuideSequence.New():Execute(function()
				return
			end)
		end,
		[NewMainMediator.DEBUG_BATTLE_LOOP] = function(arg_45_0, arg_45_1)
			arg_45_0:BuildDebugBattleLoop((arg_45_1:getBody()))
		end,
		[GAME.REMOVE_LAYERS] = function(arg_46_0, arg_46_1)
			local var_46_0 = arg_46_1:getBody().context

			arg_46_0.viewComponent:emit(NewMainMediator.REMOVE_LAYERS, arg_46_1:getBody())
		end,
		[GAME.STORY_BEGIN] = function(arg_47_0, arg_47_1)
			arg_47_0.viewComponent:emit(NewMainScene.STORY_BEGIN)
		end,
		[GAME.STORY_END] = function(arg_48_0, arg_48_1)
			arg_48_0.viewComponent:emit(NewMainScene.STORY_END)
		end,
		[PlayerProxy.UPDATED] = function(arg_49_0, arg_49_1)
			arg_49_0.viewComponent:OnPlayerUpdated()
		end,
		[GAME.END_REFLUX_CG] = function(arg_50_0, arg_50_1)
			arg_50_0.viewComponent:ShowOrHideBtnEffect(true)
		end,
		[GAME.START_REFLUX_CG] = function(arg_51_0, arg_51_1)
			arg_51_0.viewComponent:ShowOrHideBtnEffect(false)
		end,
		[ActivityProxy.UPDATED_TIP] = function(arg_52_0, arg_52_1)
			arg_52_0.viewComponent:emit(MainBaseActivityBtn.UPDATED_TIP)
		end,
		[MiniGameProxy.ON_HUB_DATA_UPDATE] = function(arg_53_0, arg_53_1)
			if arg_53_0.viewComponent.theme and arg_53_0.viewComponent.theme:IsLoaded() then
				arg_53_0.viewComponent.theme:Refresh((arg_53_0.viewComponent:GetFlagShip()))
			end
		end,
		[GAME.CRUSING_CMD_DONE] = function(arg_54_0, arg_54_1)
			local var_54_0 = arg_54_1:getBody()

			arg_54_0.viewComponent:emit(BaseUI.ON_ACHIEVE, var_54_0.awards, var_54_0.callback)
		end
	}
end

function NewMainMediator:BuildDebugBattleLoop(arg_55_1)
	if not IsUnityEditor then
		return
	end

	local var_55_0 = {}

	for iter_55_0, iter_55_1 in arg_55_1:gmatch("%s+(%S+)") do
		table.insert(var_55_0, iter_55_0)
	end

	_G.InDebugBattleLoop = {
		loopCount = tonumber(var_55_0[2]),
		loopStages = underscore.rest(var_55_0, 3),
		tempList = {}
	}

	self.viewComponent:CheckDebugBattleLoop()
end

return NewMainMediator
