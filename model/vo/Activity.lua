local Activity = class("Activity", import(".BaseVO"))

Activity.MAINTAIN = 0
Activity.NATURAL_EXPIRE = 1

local var_0_1

function Activity.GetType2Class()
	if var_0_1 then
		return var_0_1
	end

	var_0_1 = {
		[ActivityConst.ACTIVITY_TYPE_HITMONSTERNIAN] = BeatMonterNianActivity,
		[ActivityConst.ACTIVITY_TYPE_COLLECTION_EVENT] = CollectionEventActivity,
		[ActivityConst.ACTIVITY_TYPE_RETURN_AWARD] = ReturnerActivity,
		[ActivityConst.ACTIVITY_TYPE_BUILDING_BUFF] = BuildingBuffActivity,
		[ActivityConst.ACTIVITY_TYPE_BUILDING_BUFF_2] = BuildingBuff2Activity,
		[ActivityConst.ACTIVITY_TYPE_ATELIER_LINK] = AtelierActivity,
		[ActivityConst.ACTIVITY_TYPE_BOSS_BATTLE_MARK_2] = ActivityBossActivity,
		[ActivityConst.ACTIVITY_TYPE_PT_CRUSING] = CrusingActivity,
		[ActivityConst.ACTIVITY_TYPE_PT_HEI5] = Hei5Activity,
		[ActivityConst.ACTIVITY_TYPE_BOSSRUSH] = BossRushActivity,
		[ActivityConst.ACTIVITY_TYPE_EXTRA_BOSSRUSH_RANK] = BossRushRankActivity,
		[ActivityConst.ACTIVITY_TYPE_BOSS_RUSH_DAL_COLLAB] = CollabrateBossRushActivity,
		[ActivityConst.ACTIVITY_TYPE_WORKBENCH] = WorkBenchActivity,
		[ActivityConst.ACTIVITY_TYPE_VIRTUAL_BAG] = VirtualBagActivity,
		[ActivityConst.ACTIVITY_TYPE_SCULPTURE] = SculptureActivity,
		[ActivityConst.ACTIVITY_TYPE_HOTSPRING] = SpringActivity,
		[ActivityConst.ACTIVITY_TYPE_HOTSPRING_2] = Spring2Activity,
		[ActivityConst.ACTIVITY_TYPE_TASK_RYZA] = ActivityTaskActivity,
		[ActivityConst.ACTIVITY_TYPE_PUZZLA] = PuzzleActivity,
		[ActivityConst.ACTIVITY_TYPE_SKIN_COUPON] = SkinCouponActivity,
		[ActivityConst.ACTIVITY_TYPE_MANUAL_SIGN] = ManualSignActivity,
		[ActivityConst.ACTIVITY_TYPE_BOSSSINGLE] = BossSingleActivity,
		[ActivityConst.ACTIVITY_TYPE_BOSSSINGLE_VARIABLE] = BossSingleVariableActivity,
		[ActivityConst.ACTIVITY_TYPE_EVENT_SINGLE] = SingleEventActivity,
		[ActivityConst.ACTIVITY_TYPE_LINER] = LinerActivity,
		[ActivityConst.ACTIVITY_TYPE_TOWN] = TownActivity,
		[ActivityConst.ACTIVITY_TYPE_TOWN2] = TownActivity2,
		[ActivityConst.ACTIVITY_TYPE_AIRFIGHT_BATTLE] = AirFightActivity,
		[ActivityConst.ACTIVITY_TYPE_NOT_TRACEABLE] = NotTraceableTaskActivity,
		[ActivityConst.ACTIVITY_TYPE_HOLIDAY_VILLA] = VirtualBagActivity,
		[ActivityConst.ACTIVITY_TYPE_CITY_REBUILD] = VirtualBagActivity,
		[ActivityConst.ACTIVITY_TYPE_ISLAND_DRAW_AWARD] = DrawAwardActivity,
		[ActivityConst.ACTIVITY_TYPE_LOVE_LETTER_UP] = LoveLetterActivity,
		[ActivityConst.ACTIVITY_TYPE_MALL] = MallActivity,
		[ActivityConst.ACTIVITY_TYPE_AUCTION_GAME] = AuctionGameActivity,
		[ActivityConst.ACTIVITY_TYPE_REVERSE_PACMAN] = ReversePacmanActivity,
		[ActivityConst.ACTIVITY_TYPE_PT_RANK] = PTRankActivity,
		[ActivityConst.ACTIVITY_TYPE_PT_BUFF] = PTBuffActivity,
		[ActivityConst.ACTIVITY_TYPE_PT_BUFF_MARK2] = PTBuffActivity,
		[ActivityConst.ACTIVITY_TYPE_UR_EXCHANGE] = URExchangeActivity
	}

	return var_0_1
end

function Activity:Create()
	return (Activity.GetType2Class()[pg.activity_template[self.id].type] or Activity).New(self)
end

function Activity:Ctor(arg_3_1)
	self.id = arg_3_1.id
	self.configId = self.id
	self.stopTime = arg_3_1.stop_time
	self.data1 = defaultValue(arg_3_1.data1, 0)
	self.data2 = defaultValue(arg_3_1.data2, 0)
	self.data3 = defaultValue(arg_3_1.data3, 0)
	self.data4 = defaultValue(arg_3_1.data4, 0)
	self.str_data1 = defaultValue(arg_3_1.str_data1, "")
	self.data1_list = {}

	for iter_3_0, iter_3_1 in ipairs(arg_3_1.data1_list or {}) do
		table.insert(self.data1_list, iter_3_1)
	end

	self.data2_list = {}

	for iter_3_2, iter_3_3 in ipairs(arg_3_1.data2_list or {}) do
		table.insert(self.data2_list, iter_3_3)
	end

	self.data3_list = {}

	for iter_3_4, iter_3_5 in ipairs(arg_3_1.data3_list or {}) do
		table.insert(self.data3_list, iter_3_5)
	end

	self.data4_list = {}

	for iter_3_6, iter_3_7 in ipairs(arg_3_1.data4_list or {}) do
		table.insert(self.data4_list, iter_3_7)
	end

	self.data1KeyValueList = {}

	for iter_3_8, iter_3_9 in ipairs(arg_3_1.date1_key_value_list or {}) do
		self.data1KeyValueList[iter_3_9.key] = {}

		for iter_3_10, iter_3_11 in ipairs(iter_3_9.value_list or {}) do
			self.data1KeyValueList[iter_3_9.key][iter_3_11.key] = iter_3_11.value
		end
	end

	self.buffList = {}

	for iter_3_12, iter_3_13 in ipairs(arg_3_1.buff_list or {}) do
		table.insert(self.buffList, ActivityBuff.New(self.id, iter_3_13.id, iter_3_13.timestamp))
	end

	if self:getConfig("type") == ActivityConst.ACTIVITY_TYPE_NEWSERVER_SHOP then
		self.data2KeyValueList = {}

		for iter_3_14, iter_3_15 in ipairs(arg_3_1.date1_key_value_list or {}) do
			self.data2KeyValueList[iter_3_15.key] = {}
			self.data2KeyValueList[iter_3_15.key].value = iter_3_15.value
			self.data2KeyValueList[iter_3_15.key].dataMap = {}

			for iter_3_16, iter_3_17 in ipairs(iter_3_15.value_list or {}) do
				self.data2KeyValueList[iter_3_15.key].dataMap[iter_3_17.key] = iter_3_17.value
			end
		end
	end

	self.clientData1 = 0
	self.clientList = {}
end

function Activity:GetBuffList()
	return self.buffList
end

function Activity:AddBuff(arg_5_1)
	assert(isa(arg_5_1, ActivityBuff), "activityBuff should instance of ActivityBuff")
	table.insert(self.buffList, arg_5_1)
end

function Activity:setClientList(arg_6_1)
	self.clientList = arg_6_1
end

function Activity:getClientList()
	return self.clientList
end

function Activity:updateDataList(arg_8_1)
	table.insert(self.data1_list, arg_8_1)
end

function Activity:setDataList(arg_9_1)
	self.data1_list = arg_9_1
end

function Activity:updateKVPList(arg_10_1, arg_10_2, arg_10_3)
	self.data1KeyValueList[arg_10_1] = self.data1KeyValueList[arg_10_1] or {}
	self.data1KeyValueList[arg_10_1][arg_10_2] = arg_10_3
end

function Activity:getKVPList(arg_11_1, arg_11_2)
	self.data1KeyValueList[arg_11_1] = self.data1KeyValueList[arg_11_1] or {}

	return self.data1KeyValueList[arg_11_1][arg_11_2] or 0
end

function Activity:getData1()
	return self.data1
end

function Activity:getData2()
	return self.data2
end

function Activity:getData3()
	return self.data3
end

function Activity:getStrData1()
	return self.str_data1
end

function Activity:getData1List()
	return self.data1_list
end

function Activity:bindConfigTable()
	return pg.activity_template
end

function Activity:getDataConfigTable()
	local var_18_0 = self:getConfig("type")
	local var_18_1 = self:getConfig("config_id")

	if var_18_0 == ActivityConst.ACTIVITY_TYPE_MONOPOLY then
		return pg.activity_event_monopoly[tonumber(var_18_1)]
	elseif var_18_0 == ActivityConst.ACTIVITY_TYPE_PIZZA_PT or var_18_0 == ActivityConst.ACTIVITY_TYPE_PT_BUFF or var_18_0 == ActivityConst.ACTIVITY_TYPE_PT_BUFF_MARK2 then
		return pg.activity_event_pt[tonumber(var_18_1)]
	elseif var_18_0 == ActivityConst.ACTIVITY_TYPE_VOTE then
		return pg.activity_vote[tonumber(var_18_1)]
	end
end

function Activity:getDataConfig(arg_19_1)
	local var_19_0 = self:getDataConfigTable()

	assert(var_19_0, "miss config : " .. self.id)

	return var_19_0 and var_19_0[arg_19_1]
end

function Activity:getIslandConfigTable()
	return pg.island_activity_template[self.configId]
end

function Activity:getIslandConfig(arg_21_1)
	local var_21_0 = self:getIslandConfigTable()

	assert(var_21_0, "miss config : " .. self.id)

	return (var_21_0 or nil) and (var_21_0[arg_21_1] or self:getConfig(arg_21_1))
end

function Activity:isIslandShow()
	return self:getIslandConfigTable() and self:getIslandConfig("is_show") > 0
end

function Activity:isEnd()
	local var_23_0

	if self.stopTime > 0 then
		if pg.TimeMgr.GetInstance():GetServerTime() < self.stopTime then
			var_23_0 = false

			goto label_23_0
		end
	end

	::label_23_0::

	return true
end

function Activity:increaseUsedCount(arg_24_1)
	if arg_24_1 == 1 then
		self.data1 = self.data1 + 1
	elseif arg_24_1 == 2 then
		self.data2 = self.data2 + 1
	end
end

function Activity:readyToAchieve()
	local var_25_0, var_25_1 = self:IsShowTipById()
	local var_25_2 = self:IsShowTipByClient()

	if var_25_0 then
		return var_25_1
	end

	if var_25_2 then
		return var_25_2
	end

	Activity.readyToAchieveDic = Activity.readyToAchieveDic or {
		[ActivityConst.ACTIVITY_TYPE_DONOTHING] = function(arg_26_0)
			if LevelDropUpActUtil.IsLevelDropUpAct(arg_26_0.id) then
				return LevelDropUpActUtil.ShouldTipLevelDropUpAct(arg_26_0.id)
			end

			return false
		end,
		[ActivityConst.ACTIVITY_TYPE_CARD_PAIRS] = function(arg_27_0)
			return math.ceil(os.difftime(pg.TimeMgr.GetInstance():GetServerTime(), arg_27_0.data3) / 86400) > arg_27_0.data2 and arg_27_0.data2 < arg_27_0:getConfig("config_data")[4]
		end,
		[ActivityConst.ACTIVITY_TYPE_LEVELAWARD] = function(arg_28_0)
			local var_28_0 = getProxy(PlayerProxy):getRawData()
			local var_28_1 = pg.activity_level_award[arg_28_0:getConfig("config_id")]

			for iter_28_0 = 1, #var_28_1.front_drops do
				if var_28_1.front_drops[iter_28_0][1] <= var_28_0.level and not _.include(arg_28_0.data1_list, var_28_1.front_drops[iter_28_0][1]) then
					return true
				end
			end

			return false
		end,
		[ActivityConst.ACTIVITY_TYPE_CHARGEAWARD] = function(arg_29_0)
			return ChargeAwardPage.IsShowTip(arg_29_0)
		end,
		[ActivityConst.ACTIVITY_TYPE_STORY_AWARD] = function(arg_30_0)
			local var_30_0 = getProxy(PlayerProxy):getRawData()
			local var_30_1 = pg.activity_event_chapter_award[arg_30_0:getConfig("config_id")]

			for iter_30_0 = 1, #var_30_1.chapter do
				if getProxy(ChapterProxy):isClear(var_30_1.chapter[iter_30_0]) and not _.include(arg_30_0.data1_list, var_30_1.chapter[iter_30_0]) then
					return true
				end
			end

			return false
		end,
		[ActivityConst.ACTIVITY_TYPE_TASKS] = function(arg_31_0)
			local var_31_0 = arg_31_0:getConfig("config_client").subType

			if var_31_0 then
				return arg_31_0:activityTasksSubTypeFunc(var_31_0)
			end

			local var_31_1 = getProxy(TaskProxy)

			if IslandTaskActhelper.IsIslandTaskAct(arg_31_0) then
				return IslandTaskActhelper.ShouldTipIslandTask(arg_31_0)
			end

			if _.any(_.flatten(arg_31_0:getConfig("config_data")), function(arg_32_0)
				local var_32_0 = var_31_1:getTaskById(arg_32_0)

				return var_32_0 and var_32_0:isFinish() and not var_32_0:isReceive()
			end) then
				return true
			end

			local var_31_2 = getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_WORLDINPICTURE)

			if var_31_2 and not var_31_2:isEnd() and var_31_2:getConfig("config_client").linkActID == arg_31_0.id and var_31_2:readyToAchieve() then
				return true
			end

			if arg_31_0:getConfig("config_client") and arg_31_0:getConfig("config_client").decodeGameId then
				local var_31_3 = getProxy(MiniGameProxy):GetHubByGameId(arg_31_0:getConfig("config_client").decodeGameId)

				if var_31_3 then
					local var_31_4 = arg_31_0:getConfig("config_data")

					if var_31_3.ultimate <= 0 and _.all(var_31_4[#var_31_4], function(arg_33_0)
						return getProxy(TaskProxy):getFinishTaskById(arg_33_0) ~= nil
					end) then
						return true
					end
				end
			end

			if arg_31_0:getConfig("config_client") and arg_31_0:getConfig("config_client").linkTaskPoolAct then
				local var_31_5 = getProxy(ActivityProxy):getActivityById(arg_31_0:getConfig("config_client").linkTaskPoolAct)

				if var_31_5 and var_31_5:readyToAchieve() then
					return true
				end
			end

			if arg_31_0:getConfig("config_client") and arg_31_0:getConfig("config_client").link_act then
				local var_31_6 = getProxy(ActivityProxy):getActivityById(arg_31_0:getConfig("config_client").link_act)

				if var_31_6 and var_31_6:readyToAchieve() then
					return true
				end
			end

			return false
		end,
		[ActivityConst.ACTIVITY_TYPE_TASK_LIST] = ActivityConst.ACTIVITY_TYPE_TASKS,
		[ActivityConst.ACTIVITY_TYPE_HITMONSTERNIAN] = function(arg_34_0)
			return arg_34_0:GetDataConfig("hp") > arg_34_0.data3 and arg_34_0:GetCountForHitMonster() > 0
		end,
		[ActivityConst.ACTIVITY_TYPE_DODGEM] = function(arg_35_0)
			local var_35_0 = pg.TimeMgr.GetInstance()
			local var_35_1 = var_35_0:DiffDay(arg_35_0.data1, var_35_0:GetServerTime()) + 1
			local var_35_2 = arg_35_0:getConfig("config_id")

			if var_35_2 == 1 then
				return arg_35_0.data4 == 0 and arg_35_0.data2 >= 7 or defaultValue(arg_35_0.data2_list[1], 0) > 0 or defaultValue(arg_35_0.data2_list[2], 0) > 0 or arg_35_0.data2 < math.min(var_35_1, 7) or var_35_1 > arg_35_0.data3
			elseif var_35_2 == 2 then
				return arg_35_0.data4 == 0 and arg_35_0.data2 >= 7 or defaultValue(arg_35_0.data2_list[1], 0) > 0 or defaultValue(arg_35_0.data2_list[2], 0) > 0 or arg_35_0.data2 < math.min(var_35_1, 7)
			end
		end,
		[ActivityConst.ACTIVITY_TYPE_MONOPOLY] = function(arg_36_0)
			return math.ceil((pg.TimeMgr.GetInstance():GetServerTime() - arg_36_0.data1) / 86400) * arg_36_0:getDataConfig("daily_time") + arg_36_0.data1_list[1] - arg_36_0.data1_list[2] > 0
		end,
		[ActivityConst.ACTIVITY_TYPE_PIZZA_PT] = function(arg_37_0)
			local var_37_0 = ActivityPtData.New(arg_37_0):CanGetAward()
			local var_37_1 = true

			if arg_37_0:getConfig("config_client") then
				local var_37_2 = arg_37_0:getConfig("config_client").task_act_id

				if var_37_2 and var_37_2 ~= 0 and pg.activity_template[var_37_2] then
					local var_37_3 = _.flatten(pg.activity_template[var_37_2].config_data)

					if var_37_3 and #var_37_3 > 0 then
						local var_37_4 = getProxy(TaskProxy)

						for iter_37_0 = 1, #var_37_3 do
							local var_37_5 = var_37_4:getTaskById(var_37_3[iter_37_0])

							if var_37_5 and var_37_5:isFinish() then
								return true
							end
						end
					end
				end
			end

			local var_37_6 = false
			local var_37_7 = arg_37_0:getConfig("config_client").fireworkActID

			if var_37_7 and var_37_7 ~= 0 then
				local var_37_8 = getProxy(ActivityProxy):getActivityById(var_37_7)

				var_37_6 = var_37_8 and var_37_8:readyToAchieve() or false
			end

			local var_37_9 = arg_37_0:getConfig("config_client")[2]

			return var_37_0 and var_37_1 or var_37_6 or type(var_37_9) == "number" and ManualSignActivity.IsManualSignActAndAnyAwardCanGet(var_37_9)
		end,
		[ActivityConst.ACTIVITY_TYPE_PT_BUFF] = ActivityConst.ACTIVITY_TYPE_PIZZA_PT,
		[ActivityConst.ACTIVITY_TYPE_PT_BUFF_MARK2] = ActivityConst.ACTIVITY_TYPE_PIZZA_PT,
		[ActivityConst.ACTIVITY_TYPE_RETURN_AWARD] = function(arg_38_0)
			if arg_38_0.data1 == 1 then
				local var_38_0 = pg.activity_template_headhunting[arg_38_0.id]
				local var_38_1 = pg.activity_template_headhunting[arg_38_0.id].target
				local var_38_2 = 0

				for iter_38_0, iter_38_1 in ipairs(arg_38_0:getClientList()) do
					var_38_2 = var_38_2 + iter_38_1:getPt()
				end

				local var_38_3 = 0

				for iter_38_2 = #var_38_1, 1, -1 do
					if table.contains(arg_38_0.data1_list, var_38_1[iter_38_2]) then
						var_38_3 = iter_38_2

						break
					end
				end

				return var_38_2 >= var_38_1[math.min(var_38_3 + 1, #var_38_0.drop_client)] and var_38_3 ~= #var_38_0.drop_client or _.any(var_38_0.tasklist, function(arg_39_0)
					local var_39_0 = getProxy(TaskProxy):getTaskById(arg_39_0)

					return var_39_0 and var_39_0:isFinish() and not var_39_0:isReceive()
				end)
			elseif arg_38_0.data1 == 2 then
				local var_38_5 = getProxy(TaskProxy)

				return _.any(_.flatten(pg.activity_template_returnner[arg_38_0.id].task_list), function(arg_40_0)
					local var_40_0 = var_38_5:getTaskById(arg_40_0)

					return var_40_0 and var_40_0:isFinish()
				end)
			end

			return false
		end,
		[ActivityConst.ACTIVITY_TYPE_MINIGAME] = function(arg_41_0)
			local var_41_0 = getProxy(MiniGameProxy):GetHubByHubId(arg_41_0:getConfig("config_id"))

			if var_41_0.count > 0 then
				return true
			end

			if var_41_0:getConfig("reward") ~= 0 and var_41_0.usedtime >= var_41_0:getConfig("reward_need") and var_41_0.ultimate == 0 then
				return true
			end

			return false
		end,
		[ActivityConst.ACTIVITY_TYPE_TURNTABLE] = function(arg_42_0)
			if arg_42_0.data4 ~= 0 then
				local var_42_0 = getProxy(TaskProxy)

				for iter_42_0, iter_42_1 in ipairs(pg.activity_event_turning[arg_42_0:getConfig("config_id")].task_table[arg_42_0.data4]) do
					if (var_42_0:getTaskById(iter_42_1) or var_42_0:getFinishTaskById(iter_42_1)):getTaskStatus() == 1 then
						return true
					end
				end

				if math.clamp(pg.TimeMgr.GetInstance():DiffDay(arg_42_0.data1, pg.TimeMgr.GetInstance():GetServerTime()) + 1, 1, pg.activity_event_turning[arg_42_0:getConfig("config_id")].total_num) > arg_42_0.data3 then
					for iter_42_2, iter_42_3 in ipairs(pg.activity_event_turning[arg_42_0:getConfig("config_id")].task_table[arg_42_0.data4]) do
						if (var_42_0:getTaskById(iter_42_3) or var_42_0:getFinishTaskById(iter_42_3)):getTaskStatus() ~= 2 then
							return false
						end
					end

					return true
				end
			elseif arg_42_0.data4 == 0 then
				if math.clamp(pg.TimeMgr.GetInstance():DiffDay(arg_42_0.data1, pg.TimeMgr.GetInstance():GetServerTime()) + 1, 1, pg.activity_event_turning[arg_42_0:getConfig("config_id")].total_num) > arg_42_0.data3 then
					return true
				end
			end

			return false
		end,
		[ActivityConst.ACTIVITY_TYPE_LOTTERY_AWARD] = function(arg_43_0)
			return arg_43_0.data2 <= 0
		end,
		[ActivityConst.ACTIVITY_TYPE_SHRINE] = function(arg_44_0)
			local var_44_0 = arg_44_0:getConfig("config_client").story
			local var_44_1

			if var_44_0 then
				var_44_1 = #var_44_0 or 7
			end

			local var_44_2 = math.clamp(pg.TimeMgr.GetInstance():DiffDay(arg_44_0.data3, pg.TimeMgr.GetInstance():GetServerTime()) + 1, 1, var_44_1)

			if var_44_0 then
				local var_44_3 = pg.NewStoryMgr.GetInstance()
				local var_44_4 = math.clamp(arg_44_0.data2, 0, var_44_1)

				for iter_44_0 = 1, var_44_2 do
					if var_44_0[iter_44_0][1] and iter_44_0 <= var_44_4 and not var_44_3:IsPlayed(var_44_0[iter_44_0][1]) then
						return true
					end
				end
			end

			if var_44_1 <= var_44_2 and var_44_1 <= arg_44_0.data2 and arg_44_0.data1 <= 0 then
				return true
			end

			if Shrine2022View.IsNeedShowTipForShipCount() then
				return true
			end

			return false
		end,
		[ActivityConst.ACTIVITY_TYPE_LINK_LINK] = function(arg_45_0)
			local var_45_0 = pg.TimeMgr.GetInstance()

			return math.clamp(var_45_0:DiffDay(arg_45_0.data3, var_45_0:GetServerTime()) + 1 - arg_45_0.data2, 0, #arg_45_0:getConfig("config_client")[3] - arg_45_0.data2) > 0
		end,
		[ActivityConst.ACTIVITY_TYPE_BUILDING_BUFF] = function(arg_46_0)
			for iter_46_0, iter_46_1 in ipairs((arg_46_0:GetBuildingIds())) do
				local var_46_0 = arg_46_0:GetBuildingLevel(iter_46_1)

				if pg.activity_event_building[iter_46_1] and var_46_0 < #pg.activity_event_building[iter_46_1].buff and underscore.all(pg.activity_event_building[iter_46_1].material[var_46_0], function(arg_47_0)
					local var_47_0 = arg_47_0[2]
					local var_47_1 = arg_47_0[3]
					local var_47_2 = 0

					if arg_47_0[1] == DROP_TYPE_VITEM then
						assert(AcessWithinNull(Item.getConfigData(var_47_0), "link_id") == arg_46_0.id)

						var_47_2 = arg_46_0:GetMaterialCount(var_47_0)
					elseif arg_47_0[1] > DROP_TYPE_USE_ACTIVITY_DROP then
						local var_47_3 = AcessWithinNull(pg.activity_drop_type[arg_47_0[1]], "activity_id")

						assert(var_47_3)

						bagAct = getProxy(ActivityProxy):getActivityById(var_47_3)
						var_47_2 = bagAct:getVitemNumber(var_47_0)
					end

					return var_47_1 <= var_47_2
				end) then
					return true
				end
			end

			return false
		end,
		[ActivityConst.ACTIVITY_TYPE_BUILDING_BUFF_2] = function(arg_48_0, ...)
			return Activity.readyToAchieveDic[ActivityConst.ACTIVITY_TYPE_BUILDING_BUFF](arg_48_0, ...) or arg_48_0:CanRequest()
		end,
		[ActivityConst.ACTIVITY_TYPE_EXPEDITION] = function(arg_49_0)
			if arg_49_0.data3 > 0 and arg_49_0.data1 ~= 0 then
				return true
			else
				for iter_49_0 = 1, #arg_49_0.data1_list do
					if not bit.band(arg_49_0.data1_list[iter_49_0], ActivityConst.EXPEDITION_TYPE_GOT) ~= 0 then
						if bit.band(arg_49_0.data1_list[iter_49_0], ActivityConst.EXPEDITION_TYPE_OPEN) ~= 0 then
							return true
						elseif bit.band(arg_49_0.data1_list[iter_49_0], ActivityConst.EXPEDITION_TYPE_BAOXIANG) ~= 0 then
							return true
						elseif bit.band(arg_49_0.data1_list[iter_49_0], ActivityConst.EXPEDITION_TYPE_BOSS) ~= 0 then
							return true
						end
					end
				end
			end

			return false
		end,
		[ActivityConst.ACTIVITY_TYPE_CLIENT_DISPLAY] = function(arg_50_0)
			local var_50_0 = arg_50_0:getConfig("config_client")

			if var_50_0 and var_50_0.linkGameHubID then
				local var_50_1 = getProxy(MiniGameProxy):GetHubByHubId(var_50_0.linkGameHubID)

				if var_50_1 then
					if var_50_0.trimRed then
						if var_50_1.ultimate == 1 then
							return false
						end

						if var_50_1.usedtime == var_50_1:getConfig("reward_need") then
							return true
						end
					end

					return var_50_1.count > 0
				end
			end

			return false
		end,
		[ActivityConst.ACTIVITY_TYPE_BB] = function(arg_51_0)
			return arg_51_0.data2 > 0
		end,
		[ActivityConst.ACTIVITY_TYPE_PUZZLA] = function(arg_52_0)
			local var_52_0 = arg_52_0.data1_list
			local var_52_1 = arg_52_0.data2_list
			local var_52_2 = arg_52_0:getConfig("config_client").linkActID

			if var_52_2 then
				local var_52_3 = getProxy(ActivityProxy):getActivityById(var_52_2)

				if var_52_3 and var_52_3:readyToAchieve() then
					return true
				end
			end

			if _.any(arg_52_0:GetPicturePuzzleIds(), function(arg_53_0)
				return not table.contains(var_52_1, arg_53_0) and table.contains(var_52_0, arg_53_0)
			end) then
				return true
			end

			local var_52_4 = pg.activity_event_picturepuzzle[arg_52_0.id]

			if pg.activity_event_picturepuzzle[arg_52_0.id] and var_52_4.chapter > 0 and arg_52_0.data1 < 1 then
				return true
			end

			if var_52_4 and #var_52_4.auto_finish_args > 0 and arg_52_0.data1 == 1 then
				return true
			end

			return false
		end,
		[ActivityConst.ACTIVITY_TYPE_AIRFIGHT_BATTLE] = function(arg_54_0)
			return AirFightActivity.readyToAchieve(arg_54_0)
		end,
		[ActivityConst.ACTIVITY_TYPE_WORLDINPICTURE] = function(arg_55_0)
			local var_55_0 = WorldInPictureActiviyData.New(arg_55_0)

			return not var_55_0:IsTravelAll() and var_55_0:GetTravelPoint() > 0 or var_55_0:GetDrawPoint() > 0 and var_55_0:AnyAreaCanDraw()
		end,
		[ActivityConst.ACTIVITY_TYPE_APRIL_REWARD] = function(arg_56_0)
			if arg_56_0.data1 == 0 then
				if arg_56_0:getConfig("config_client").autounlock <= pg.TimeMgr.GetInstance():GetServerTime() - arg_56_0:getStartTime() then
					return true
				end
			elseif arg_56_0.data1 ~= 0 and arg_56_0.data2 == 0 then
				return true
			end

			return false
		end,
		[ActivityConst.ACTIVITY_TYPE_TASK_POOL] = function(arg_57_0)
			local var_57_0 = arg_57_0:getConfig("config_data")
			local var_57_1 = getProxy(TaskProxy)

			if arg_57_0.data1 >= #var_57_0 then
				return false
			end

			local var_57_2 = pg.TimeMgr.GetInstance()
			local var_57_3 = (var_57_2:DiffDay(arg_57_0:getStartTime(), var_57_2:GetServerTime()) + 1) * arg_57_0:getConfig("config_id")

			var_57_3 = var_57_3 > #var_57_0 and #var_57_0 or var_57_3

			return var_57_3 - arg_57_0.data1 > 0 and _.any(var_57_0, function(arg_58_0)
				local var_58_0 = var_57_1:getTaskById(arg_58_0)

				return var_58_0 and var_58_0:isFinish()
			end)
		end,
		[ActivityConst.ACTIVITY_TYPE_EVENT] = function(arg_59_0)
			return PlayerPrefs.GetInt("ACTIVITY_TYPE_EVENT_" .. arg_59_0.id .. "_" .. getProxy(PlayerProxy):getData().id) == 0
		end,
		[ActivityConst.ACTIVITY_TYPE_PT_OTHER] = function(arg_60_0)
			if arg_60_0.data2 and arg_60_0.data2 <= 0 and arg_60_0.data1 >= pg.activity_event_avatarframe[arg_60_0:getConfig("config_id")].target then
				return true
			end

			return false
		end,
		[ActivityConst.ACTIVITY_TYPE_HOTSPRING] = function(arg_61_0)
			local var_61_0, var_61_1 = arg_61_0:GetUpgradeCost()

			if arg_61_0:GetSlotCount() < arg_61_0:GetTotalSlotCount() and var_61_1 <= arg_61_0:GetCoins() then
				return true
			end

			return false
		end,
		[ActivityConst.ACTIVITY_TYPE_FIREWORK] = function(arg_62_0)
			if arg_62_0.data1 > 0 and arg_62_0:getConfig("config_data")[2][2] <= getProxy(PlayerProxy):getRawData():getResource(arg_62_0:getConfig("config_data")[2][1]) then
				return true
			end

			return false
		end,
		[ActivityConst.ACTIVITY_TYPE_FLOWER_FIELD] = function(arg_63_0)
			local var_63_0 = pg.TimeMgr.GetInstance()

			return var_63_0:GetServerTime() >= var_63_0:GetTimeToNextTime(math.max(arg_63_0.data1, arg_63_0.data2))
		end,
		[ActivityConst.ACTIVITY_TYPE_ISLAND] = function(arg_64_0)
			for iter_64_0, iter_64_1 in pairs(getProxy(SixthAnniversaryIslandProxy):GetNodeDic()) do
				if iter_64_1:IsVisual() and iter_64_1:RedDotHint() then
					return true
				end
			end

			return false
		end,
		[ActivityConst.ACTIVITY_TYPE_HOTSPRING_2] = function(arg_65_0)
			return Spring2Activity.readyToAchieve(arg_65_0)
		end,
		[ActivityConst.ACTIVITY_TYPE_CARD_PUZZLE] = function(arg_66_0)
			local var_66_0 = #arg_66_0.data2_list
			local var_66_1 = arg_66_0:getData1List()
			local var_66_2 = arg_66_0:getConfig("config_data")[2]

			if #var_66_1 == #var_66_2 then
				return false
			end

			return (function()
				for iter_67_0, iter_67_1 in ipairs(var_66_2) do
					if not table.contains(var_66_1, iter_67_1[1]) and var_66_0 >= iter_67_1[1] then
						return true
					end
				end

				return false
			end)() or (function()
				return PlayerPrefs.GetInt("DAY_TIP_" .. arg_66_0.id .. "_" .. getProxy(PlayerProxy):getData().id .. "_" .. arg_66_0:getDayIndex()) == 0
			end)()
		end,
		[ActivityConst.ACTIVITY_TYPE_SURVEY] = function(arg_69_0)
			local var_69_0, var_69_1 = getProxy(ActivityProxy):isSurveyOpen()

			return var_69_0 and not getProxy(ActivityProxy):isSurveyDone() and not SurveyPage.IsEverEnter(var_69_1)
		end,
		[ActivityConst.ACTIVITY_TYPE_ZUMA] = function(arg_70_0)
			return LaunchBallActivityMgr.GetInvitationAble(arg_70_0.id)
		end,
		[ActivityConst.ACTIVITY_TYPE_GIFT_UP] = function(arg_71_0)
			if getProxy(ShopsProxy):ShouldRefreshChargeList() then
				if not arg_71_0.requestingChargeList then
					arg_71_0.requestingChargeList = true

					pg.m02:sendNotification(GAME.GET_CHARGE_LIST, {
						callback = function()
							arg_71_0.requestingChargeList = nil

							pg.m02:sendNotification(ActivityProxy.ACTIVITY_UPDATED, arg_71_0)
						end
					})
				end

				return false
			end

			local var_71_0 = arg_71_0:getConfig("config_client").gifts[2]

			return underscore(var_71_0):chain():first((math.min(#var_71_0, arg_71_0:getNDay()))):any(function(arg_73_0)
				local var_73_0 = getProxy(ShopsProxy):GetGiftCommodity(arg_73_0, Goods.TYPE_GIFT_PACKAGE)

				return var_73_0:canPurchase() and var_73_0:inTime() and not var_73_0:IsGroupLimit()
			end):value()
		end,
		[ActivityConst.ACTIVITY_TYPE_UR_EXCHANGE] = function(arg_74_0)
			local var_74_0 = getProxy(ShopsProxy):getActivityShopById(arg_74_0:GetConfigClientSetting("shopId"))

			for iter_74_0, iter_74_1 in ipairs(arg_74_0:GetConfigClientSetting("goodsId")) do
				local var_74_1 = var_74_0:GetCommodityById(iter_74_1)

				if var_74_1:canPurchase() then
					local var_74_2 = var_74_1:GetConsume()

					if var_74_2.count <= var_74_2:getOwnedCount() then
						return true
					end
				end
			end

			return false
		end,
		[ActivityConst.ACTIVITY_TYPE_SKIN_COUPON_COUNTING] = function(arg_75_0)
			return arg_75_0:getData1() > 0
		end,
		[ActivityConst.ACTIVITY_TYPE_DAILY_STAGE_BONUS] = function(arg_76_0)
			return arg_76_0:NeedLoginRedPoint()
		end,
		[ActivityConst.ACTIVITY_TYPE_TASK_RYZA] = function(arg_77_0)
			for iter_77_0, iter_77_1 in ipairs((getProxy(ActivityTaskProxy):getTaskById(arg_77_0.id))) do
				if iter_77_1:getTaskStatus() == 1 then
					return true
				end
			end
		end,
		[ActivityConst.ACTIVITY_TYPE_MINIGAME] = function(arg_78_0)
			if getProxy(MiniGameProxy):GetHubByHubId((arg_78_0:getConfig("config_id"))).count > 0 then
				return true
			end
		end,
		[ActivityConst.ACTIVITY_TYPE_7DAYSLOGIN] = function(arg_79_0)
			local var_79_0 = pg.TimeMgr.GetInstance()
			local var_79_1 = var_79_0:GetServerTime()

			return arg_79_0.data1 < #pg.activity_7_day_sign[arg_79_0:getConfig("config_id")].front_drops and not var_79_0:IsSameDay(var_79_1, arg_79_0.data2) and var_79_1 > arg_79_0.data2
		end,
		[ActivityConst.ACTIVITY_TYPE_PT_HEI5] = function(arg_80_0)
			return #arg_80_0:GetHei5UnreceiveAward() > 0
		end,
		[ActivityConst.ACTIVITY_TYPE_TownSkinStory] = function(arg_81_0)
			local var_81_0 = pg.NewStoryMgr.GetInstance()

			if arg_81_0.data1 > 0 and underscore.any(arg_81_0:GetConfigClientSetting("story"), function(arg_82_0)
				return not var_81_0:IsPlayed(arg_82_0[1])
			end) then
				return true
			end
		end,
		[ActivityConst.ACTIVITY_TYPE_MANUAL_SIGN] = function(arg_83_0)
			return arg_83_0:CanGetAward() or not arg_83_0:TodayIsSigned()
		end,
		[ActivityConst.ACTIVITY_TYPE_LOVE_LETTER_MAIL] = function(arg_84_0)
			return getProxy(PlayerProxy):getRawData().level >= arg_84_0:getConfig("config_id") and arg_84_0.data1 == 0
		end,
		[ActivityConst.ACTIVITY_TYPE_ISLAND_GAME_PT] = function(arg_85_0)
			local var_85_0 = getProxy(IslandProxy):GetIsland():GetTaskAgency()

			return IslandGamePtTemplatePage.ShouldFirstTip(arg_85_0.id) or _.any(pg.island_activity_pt_page[arg_85_0:getIslandConfig("config_id")].task_id, function(arg_86_0)
				local var_86_0 = var_85_0:GetTask(arg_86_0)

				return var_86_0 and var_86_0:IsFinish() and not var_85_0:IsFinishTask(arg_86_0)
			end)
		end,
		[ActivityConst.ACTIVITY_TYPE_ISLAND_CHEATE_TAVERN] = function(arg_87_0)
			for iter_87_0, iter_87_1 in ipairs((getProxy(ActivityTaskProxy):getTaskById(ActivityConst.ISLAND_BAR_ACT_ID))) do
				if iter_87_1:getTaskStatus() == 1 then
					return true
				end
			end

			return false
		end,
		[ActivityConst.ACTIVITY_TYPE_REVERSE_PACMAN] = function(arg_88_0)
			print("TODO: 红点功能")

			return false
		end
	}

	return switch(self:getConfig("type"), Activity.readyToAchieveDic, nil, self)
end

function Activity:IsShowTipByClient()
	local var_89_0 = self:getConfig("config_client")

	if var_89_0.sub_act_id then
		local var_89_1 = getProxy(ActivityProxy):getActivityById(var_89_0.sub_act_id)

		return var_89_1 and not var_89_1:isEnd() and var_89_1:readyToAchieve()
	elseif var_89_0.is_showMedal then
		return ActivityMedalGroup.showTip(var_89_0.medal_group_id)
	elseif var_89_0.is_clickOnce then
		return PlayerPrefs.GetInt(Activity.GetPlayerActivyIDKey(self:getConfig("id")), 0) == 0
	else
		return false
	end
end

function Activity:IsShowTipById()
	Activity.ShowTipTableById = Activity.ShowTipTableById or {
		[ActivityConst.ACTIVITY_ID_US_SKIRMISH_RE] = function(arg_91_0)
			local var_91_0 = getProxy(SkirmishProxy)

			var_91_0:UpdateSkirmishProgress()

			local var_91_1 = 0
			local var_91_2 = 0

			for iter_91_0, iter_91_1 in ipairs((var_91_0:getRawData())) do
				local var_91_3 = iter_91_1:GetState()

				var_91_1 = var_91_3 > SkirmishVO.StateInactive and var_91_1 + 1 or var_91_1
				var_91_2 = var_91_3 == SkirmishVO.StateClear and var_91_2 + 1 or var_91_2
			end

			return var_91_2 < var_91_1
		end,
		[ActivityConst.POCKY_SKIN_LOGIN] = function(arg_92_0)
			local var_92_0 = arg_92_0:getConfig("config_client").linkids
			local var_92_1 = getProxy(TaskProxy)
			local var_92_2 = getProxy(ActivityProxy)
			local var_92_3 = var_92_2:getActivityById(var_92_0[1])
			local var_92_4 = var_92_2:getActivityById(var_92_0[2])
			local var_92_5 = var_92_2:getActivityById(var_92_0[3])

			assert(var_92_3 and var_92_4 and var_92_5)

			return (function()
				local var_95_0 = _.flatten(arg_92_0:getConfig("config_data"))

				for iter_95_0 = 1, math.min(#var_95_0, var_92_4.data3) do
					local var_95_1 = var_92_1:getTaskById(var_95_0[iter_95_0])

					if var_95_1 and var_95_1:isFinish() and not var_95_1:isReceive() then
						return true
					end
				end
			end)() or (function()
				return var_92_3 and var_92_3:readyToAchieve()
			end)() or (function()
				return var_92_4 and var_92_4:readyToAchieve()
			end)() or (function()
				if not (var_92_5 and var_92_5:readyToAchieve()) or not var_92_3 then
					return false
				end

				local var_96_1 = ActivityPtData.New(var_92_3)

				return var_96_1.level >= #var_96_1.targets
			end)()
		end,
		[ActivityConst.TOWERCLIMBING_SIGN] = function(arg_97_0)
			local var_97_0 = getProxy(MiniGameProxy):GetHubByHubId(9)

			return var_97_0.ultimate == 0 and var_97_0:getConfig("reward_need") <= var_97_0.usedtime
		end,
		[pg.activity_const.NEWYEAR_SNACK_PAGE_ID.act_id] = NewYearSnackPage.IsTip,
		[ActivityConst.WWF_TASK_ID] = WWFPtPage.IsShowRed,
		[ActivityConst.NEWMEIXIV4_SKIRMISH_ID] = NewMeixiV4SkirmishPage.IsShowRed,
		[ActivityConst.JIUJIU_YOYO_ID] = JiujiuYoyoPage.IsShowRed,
		[ActivityConst.SENRANKAGURA_TRAIN_ACT_ID] = SenrankaguraTrainScene.IsShowRed,
		[ActivityConst.DORM_SIGN_ID] = DormSignPage.IsShowRed,
		[ActivityConst.DORM_SIGN_ID_2] = DormSignTwoPage.IsShowRed,
		[ActivityConst.DORM_SIGN_ID_3] = DormSignThirdPage.IsShowRed,
		[ActivityConst.ISLAND_SIGN_ID] = IslandSignPage.IsShowRed,
		[ActivityConst.GOASTSTORYACTIVITY_ID] = GhostSkinPageLayer.IsShowRed,
		[ActivityConst.YUMIA_BASE_ACT_ID] = YoumiyaStrongholdLayer.ShouldShowTip,
		[ActivityConst.NINJA_CITY_MAIN_ACTIVITY_ID] = function(arg_98_0)
			if CityRebuildBookLayer.ShouldShowTip() or CityRebuildTasksLayer.ShouldShowTip() then
				return true
			end

			return false
		end,
		[ActivityConst.MALL_MAIN_ACTIVITY_ID] = function(arg_99_0)
			return AnniversaryNineMainPage.IsTip()
		end,
		[ActivityConst.SAILING_SHIP_3_SKIN_ACT_ID] = SailingShip3SkinLayer.ShouldShowTip,
		[ActivityConst.HelenaPT_ACT_ID] = function(arg_100_0)
			return HelenaScenarioPage:IsShowRed(arg_100_0)
		end,
		[ActivityConst.LOVE_LETTER_LOGIN_ID] = function(arg_101_0)
			for iter_101_0 = 1, arg_101_0:getNDay() do
				local var_101_0 = arg_101_0:getConfig("config_data")[iter_101_0]

				if var_101_0 then
					local var_101_1 = getProxy(TaskProxy):getTaskVO(var_101_0) or nil

					if var_101_1 and var_101_1:getTaskStatus() == 1 then
						return true
					end
				end
			end

			return false
		end,
		[ActivityConst.WindFogCorridor_SkinStory_MainPage] = function(arg_102_0)
			local var_102_0 = pg.NewStoryMgr.GetInstance()

			if arg_102_0.data1 > 0 and underscore.any(arg_102_0:GetConfigClientSetting("story"), function(arg_103_0)
				return not var_102_0:IsPlayed(arg_103_0[1])
			end) then
				return true
			end

			return WindFogCorridorSkinPageLayer.IsShowRed()
		end
	}

	return tobool(Activity.ShowTipTableById[self.id]), Activity.ShowTipTableById[self.id] and Activity.ShowTipTableById[self.id](self)
end

function Activity:activityTasksSubTypeFunc(arg_104_1)
	if arg_104_1 == 1 then
		local var_104_0 = 1
		local var_104_1 = getProxy(TaskProxy)
		local var_104_2 = self:getConfig("config_client").unlock_task
		local var_104_3 = math.min(self:getNDay(), #var_104_2)

		for iter_104_0 = 1, var_104_3 do
			if not true then
				break
			end

			var_104_0 = iter_104_0

			if iter_104_0 < var_104_3 then
				for iter_104_1, iter_104_2 in ipairs(var_104_2[iter_104_0]) do
					local var_104_4 = var_104_1:getTaskById(iter_104_2) or var_104_1:getFinishTaskById(iter_104_2)

					if not var_104_4 or var_104_4:getTaskStatus() ~= 2 then
						break
					end
				end
			end
		end

		for iter_104_3, iter_104_4 in ipairs(var_104_2[math.min(var_104_0, #var_104_2)]) do
			local var_104_6 = var_104_1:getTaskById(iter_104_4) or var_104_1:getFinishTaskById(iter_104_4)

			if not var_104_6 then
				return false
			end

			if var_104_6:getTaskStatus() == 1 then
				return true
			end
		end
	end

	if arg_104_1 == TASK_SUB_TYPE_CLIENT_TRIGGER then
		local var_104_7, var_104_8 = getActivityTask(self, true)

		return var_104_7 and (not var_104_8 or var_104_8:getTaskStatus() ~= 2)
	end

	return false
end

function Activity:isShow()
	if LOCK_SKIN_US then
		if pg.gameset.levellimit_skinstory.key_value >= getProxy(PlayerProxy):getRawData().level and table.contains(pg.gameset.levellimit_skinstory.description, self.id) then
			return false
		end
	end

	if self:getConfig("is_show") <= 0 then
		return false
	end

	if self:getConfig("type") == ActivityConst.ACTIVITY_TYPE_RETURN_AWARD then
		return self.data1 ~= 0
	elseif self:getConfig("type") == ActivityConst.ACTIVITY_TYPE_CLIENT_DISPLAY then
		local var_105_0 = self:getConfig("config_client").display_link

		if var_105_0 then
			return underscore.any(var_105_0, function(arg_106_0)
				return arg_106_0[2] == 0 or pg.TimeMgr.GetInstance():inTime(ShopConst.GetShopConfig(arg_106_0[2]).time)
			end)
		end
	elseif self:getConfig("type") == ActivityConst.ACTIVITY_TYPE_SURVEY then
		local var_105_1 = getProxy(ActivityProxy)

		return var_105_1:isSurveyOpen() and not var_105_1:isSurveyDone()
	elseif self:getConfig("type") == ActivityConst.ACTIVITY_TYPE_UR_EXCHANGE then
		local var_105_2 = getProxy(ShopsProxy):getActivityShopById(self:GetConfigClientSetting("shopId"))

		for iter_105_0, iter_105_1 in ipairs(self:GetConfigClientSetting("goodsId")) do
			if var_105_2:GetCommodityById(iter_105_1):canPurchase() then
				return true
			end
		end

		return false
	elseif self:getConfig("type") == ActivityConst.ACTIVITY_TYPE_TASK_RYZA and table.contains({
		ActivityConst.DORM_SIGN_ID,
		ActivityConst.DORM_SIGN_ID_2,
		ActivityConst.DORM_SIGN_ID_3
	}, self:getConfig("id")) then
		return #getProxy(ActivityProxy):getActivityById(self:getConfig("id")):getConfig("config_data") ~= #getProxy(ActivityTaskProxy):getFinishTaskById(self:getConfig("id"))
	end

	return true
end

function Activity:isAfterShow()
	if self.configId == ActivityConst.ISLAND_SIGN_ID then
		local var_107_0 = getProxy(ActivityTaskProxy):GetActivityTasks(self.id)

		return _.all(_.flatten(self:getConfig("config_data")), function(arg_108_0)
			return var_107_0[arg_108_0] and var_107_0[arg_108_0]:isOver()
		end)
	end

	if self.configId == ActivityConst.UR_TASK_ACT_ID or self.configId == ActivityConst.SPECIAL_WEAPON_ACT_ID then
		local var_107_1 = getProxy(TaskProxy)

		return underscore.all(self:getConfig("config_data")[1], function(arg_109_0)
			local var_109_0 = var_107_1:getTaskVO(arg_109_0)

			return var_109_0 and var_109_0:isReceive()
		end)
	end

	return false
end

function Activity:getPageABNames()
	local var_110_0 = self:getConfig("page_info")

	return {
		var_110_0.ui_name,
		var_110_0.ui_name2
	}
end

function Activity:checkPageABExist()
	if not IsUnityEditor then
		return true
	end

	return underscore.all(self:getPageABNames(), function(arg_112_0)
		return checkABExist(string.format("ui/%s", arg_112_0))
	end)
end

function Activity:getShowPriority()
	return self:getConfig("is_show")
end

function Activity:isCorePage(arg_114_1)
	return self:getConfig("page_core") == arg_114_1
end

function Activity:left4Day()
	if self.stopTime - pg.TimeMgr.GetInstance():GetServerTime() < 345600 then
		return true
	end

	return false
end

function Activity:getAwardInfos()
	return self.data1KeyValueList or {}
end

function Activity:updateData(arg_117_1, arg_117_2)
	if self:getConfig("type") == ActivityConst.ACTIVITY_TYPE_LOTTERY then
		if not self:getAwardInfos()[arg_117_1] then
			self.data1KeyValueList[arg_117_1] = {}
		end

		for iter_117_0, iter_117_1 in ipairs(arg_117_2) do
			self.data1KeyValueList[arg_117_1][iter_117_1] = self.data1KeyValueList[arg_117_1][iter_117_1] and self.data1KeyValueList[arg_117_1][iter_117_1] + 1 or 1
		end
	end
end

function Activity:getTaskShip()
	return self:getConfig("config_client")[1]
end

function Activity:getNotificationMsg()
	local var_119_0 = self:getConfig("type")
	local var_119_1 = ActivityProxy.ACTIVITY_SHOW_AWARDS

	if var_119_0 == ActivityConst.ACTIVITY_TYPE_SHOP or var_119_0 == ActivityConst.ACTIVITY_TYPE_SKIN_FAKE_PACKAGE or var_119_0 == ActivityConst.ACTIVITY_TYPE_TIMES_FAKE_PACKAGE then
		var_119_1 = ActivityProxy.ACTIVITY_SHOP_SHOW_AWARDS
	elseif var_119_0 == ActivityConst.ACTIVITY_TYPE_LOTTERY then
		var_119_1 = ActivityProxy.ACTIVITY_LOTTERY_SHOW_AWARDS
	elseif var_119_0 == ActivityConst.ACTIVITY_TYPE_REFLUX then
		var_119_1 = ActivityProxy.ACTIVITY_SHOW_REFLUX_AWARDS
	elseif var_119_0 == ActivityConst.ACTIVITY_TYPE_RED_PACKETS or var_119_0 == ActivityConst.ACTIVITY_TYPE_RED_PACKET_LOTTER then
		var_119_1 = ActivityProxy.ACTIVITY_SHOW_RED_PACKET_AWARDS
	end

	return var_119_1
end

function Activity:getDayIndex()
	local var_120_0 = pg.TimeMgr.GetInstance()

	return var_120_0:DiffDay(self:getStartTime(), (var_120_0:GetServerTime())) + 1
end

function Activity:getStartTime()
	return pg.TimeMgr.GetInstance():parseTimeFromConfig((self:getStartTimeTable()))
end

function Activity:getStartTimeTable()
	local var_122_0
	local var_122_1

	if self:getConfig("time") == "stop" then
		local var_122_2 = getProxy(ActivityRemasterProxy):GetActivaingReamsterData()

		if var_122_2 then
			var_122_0 = var_122_2:GetStartTimeTable(self.id)
		end
	else
		local var_122_3, var_122_4 = parseTimeConfig(self:getConfig("time"))

		if var_122_4 and var_122_4[1] == "newuser" then
			var_122_1 = self.stopTime - var_122_4[3] * 86400
		else
			var_122_0 = var_122_3[2]
		end
	end

	if var_122_0 and var_122_0 ~= "" then
		return var_122_0
	end

	local var_122_5 = pg.TimeMgr.GetInstance()
	local var_122_6 = var_122_5:STimeDescS(var_122_1 or var_122_5:GetServerTime(), "*t")

	return {
		{
			var_122_6.year,
			var_122_6.month,
			var_122_6.day
		},
		{
			var_122_6.hour,
			var_122_6.min,
			var_122_6.sec
		}
	}
end

function Activity:getNDay(arg_123_1)
	arg_123_1 = arg_123_1 or self:getStartTime()

	local var_123_0 = pg.TimeMgr.GetInstance()

	return var_123_0:DiffDay(arg_123_1, var_123_0:GetServerTime()) + 1
end

function Activity:isVariableTime()
	local var_124_0, var_124_1 = parseTimeConfig(self:getConfig("time"))

	return var_124_1 and var_124_1[1] == "newuser"
end

function Activity:setSpecialData(arg_125_1, arg_125_2)
	if self.speciaData then
		self.speciaData = self.speciaData or {}
	end

	self.speciaData[arg_125_1] = arg_125_2
end

function Activity:getSpecialData(arg_126_1)
	return (self.speciaData and self.speciaData[arg_126_1] or nil) and (self.speciaData[arg_126_1] or nil)
end

function Activity:canPermanentFinish()
	local var_127_0 = self:getConfig("type")

	if var_127_0 == ActivityConst.ACTIVITY_TYPE_TASK_LIST then
		local var_127_1 = self:getConfig("config_data")
		local var_127_2 = getProxy(TaskProxy)
		local var_127_3 = {}

		var_127_3[1] = var_127_1[#var_127_1]

		return underscore.all(underscore.flatten(var_127_3), function(arg_128_0)
			return var_127_2:getFinishTaskById(arg_128_0) ~= nil
		end)
	elseif var_127_0 == ActivityConst.ACTIVITY_TYPE_PT_BUFF or var_127_0 == ActivityConst.ACTIVITY_TYPE_PT_BUFF_MARK2 then
		local var_127_4 = ActivityPtData.New(self)

		return var_127_4.level >= #var_127_4.targets
	end

	return false
end

function Activity:GetShopTime()
	local var_129_0 = pg.TimeMgr.GetInstance()
	local var_129_1 = self:getStartTime()
	local var_129_2 = var_129_0:STimeDescS(self.stopTime, "*t")

	if var_129_2.hour == 0 and var_129_2.min == 0 and var_129_2.sec == 0 then
		return var_129_0:STimeDescS(var_129_1, "%y.%m.%d") .. " - " .. string.format("%s.%s.%s", var_129_2.year, var_129_2.month, var_129_2.day - 1)
	else
		return var_129_0:STimeDescS(var_129_1, "%y.%m.%d") .. " - " .. var_129_0:STimeDescS(self.stopTime, "%y.%m.%d")
	end
end

function Activity:IsActivityReady()
	return self and not self:isEnd() and self:readyToAchieve()
end

function Activity:NeedLoginRedPoint()
	return PlayerPrefs.GetString(self:GetLoginRedPointKey(), "") ~= self:GetLoginRedPointValue()
end

function Activity:SetLoginRedPoint()
	PlayerPrefs.SetString(self:GetLoginRedPointKey(), self:GetLoginRedPointValue())
end

function Activity:GetLoginRedPointValue()
	return pg.TimeMgr.GetInstance():STimeDescC(pg.TimeMgr.GetInstance():GetServerTime(), "%Y/%m/%d")
end

function Activity:GetLoginRedPointKey()
	return string.format("%s_%s", self:GetPlayerID(), self.id)
end

function Activity:GetPlayerID()
	return getProxy(PlayerProxy):getPlayerId()
end

function Activity:GetConfigClientSetting(arg_136_1)
	return self:getConfig("config_client")[arg_136_1]
end

function Activity:IsMaintenanceFinish()
	return not self:GetConfigClientSetting("no_maintenance")
end

function Activity:GetPlayerActivyIDKey()
	return "Activity_PlayerPrefs_PlayerId_" .. getProxy(PlayerProxy):getPlayerId() .. "ActivityID_" .. self
end

function Activity:GetConfigClientPTDrop()
	if self:isEnd() then
		return nil
	end

	if self:GetConfigClientSetting("PT_ACT") then
		local var_139_0 = getProxy(ActivityProxy):getActivityById(self:GetConfigClientSetting("PT_ACT"))

		return var_139_0 and var_139_0:GetPTDrop() or nil
	elseif self:GetConfigClientSetting("PTID") then
		return Drop.New({
			type = DROP_TYPE_RESOURCE,
			id = self:GetConfigClientSetting("PTID")
		})
	elseif self:GetConfigClientSetting("ptId") then
		return Drop.New({
			type = DROP_TYPE_RESOURCE,
			id = self:GetConfigClientSetting("ptId")
		})
	end

	return nil
end

function Activity:GetConfigClientPTActivity()
	if self:isEnd() then
		return nil
	end

	if self:GetConfigClientSetting("PT_ACT") then
		return getProxy(ActivityProxy):getActivityById(self:GetConfigClientSetting("PT_ACT"))
	else
		local var_140_0 = self:GetConfigClientPTDrop()

		return (var_140_0 or nil) and (getProxy(ActivityProxy):GetPTActivityByRes(var_140_0) or nil)
	end
end

local function var_0_2(arg_141_0)
	local var_141_0 = pg.TimeMgr.GetInstance()
	local var_141_1 = string.split(var_141_0:STimeDescC(arg_141_0.stopTime, "%Y/%m/%d/%H/%M/%S"), "/")

	return GetActTimeDesc(false, (arg_141_0:getConfig("config_client").natural_expire or 0) == Activity.MAINTAIN, var_141_0[1][2], arg_141_0:getStartTimeTable()[1][3], var_141_1[2], var_141_1[3], var_141_1[4], var_141_1[5], var_141_1[6])
end

function Activity:GetActivityTimeStr(arg_142_1)
	if self:getConfig("time") == "stop" then
		local var_142_0 = getProxy(ActivityRemasterProxy):GetActivaingReamsterData()

		if not var_142_0 then
			return ""
		end

		return var_142_0:GetActivityTimeDesc(self.id)
	elseif arg_142_1 then
		return ""
	else
		return var_0_2(self)
	end
end

return Activity
