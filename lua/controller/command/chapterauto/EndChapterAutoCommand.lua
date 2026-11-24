local EndChapterAutoCommand = class("EndChapterAutoCommand", pm.SimpleCommand)

function EndChapterAutoCommand:execute(arg_1_1)
	local var_1_0 = arg_1_1:getBody()
	local var_1_1 = var_1_0.callback
	local var_1_2 = var_1_0.isReset
	local var_1_3 = getProxy(ChapterAutoProxy)
	local var_1_4 = var_1_3:GetCommissionList()
	local var_1_5, var_1_6 = var_1_3:GetFinishedCnt()
	local var_1_7 = #var_1_4 - var_1_5
	local var_1_8 = underscore.reduce(var_1_4, 0, function(arg_2_0, arg_2_1)
		return arg_2_0 + (arg_2_1:UsedTicket() and 1 or 0)
	end) - var_1_6
	local var_1_9 = var_1_4[1].type
	local var_1_10 = var_1_4[1].id
	local var_1_11 = {}

	if #var_1_4 - var_1_5 > 0 then
		table.insert(var_1_11, function(arg_3_0)
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				content = i18n((switch(var_1_9, {
					[ChapterAutoProxy.TYPE.SLG] = function()
						return "auto_battle_ing_stop_tips"
					end,
					[ChapterAutoProxy.TYPE.WORLD] = function()
						return var_1_2 and "world_auto_plan_error_tip6" or "world_auto_plan_cancel_tip"
					end
				}, function()
					return "auto_battle_ing_stop_tips"
				end))),
				onYes = arg_3_0
			})
		end)
	end

	if underscore.any(var_1_4, function(arg_7_0)
		local var_7_0

		if not arg_7_0:IsFinished() then
			var_7_0 = arg_7_0:UsedTicket()

			if var_7_0 then
				var_7_0 = pg.TimeMgr.GetInstance():GetServerTime() > arg_7_0:GetTicketTime()
			end
		end

		return var_7_0
	end) then
		table.insert(var_1_11, function(arg_8_0)
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				content = i18n("auto_battle_drop_book_expired"),
				onYes = arg_8_0
			})
		end)
	end

	if var_1_4[1].type == ChapterAutoProxy.TYPE.SLG then
		local var_1_12 = getProxy(NavalAcademyProxy)
		local var_1_13 = var_1_12:getCourse()
		local var_1_14 = var_1_12:GetClassVO():GetMaxProficiency()
		local var_1_15 = var_1_13:GetProficiency() + var_1_4[1]:GetClassExpAward() * var_1_5

		if var_1_14 < var_1_13 then
			table.insert(var_1_11, function(arg_9_0)
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					content = i18n("auto_battle_drop_classEXP_overflow", var_1_15 - var_1_14),
					onYes = arg_9_0
				})
			end)
		end

		local var_1_16 = getProxy(BagProxy):getItemCountById(ChapterAutoCommission.EXP_BOOK_ID) + underscore.reduce(var_1_4, 0, function(arg_10_0, arg_10_1)
			return arg_10_0 + (arg_10_1:IsFinished() and arg_10_1:UsedTicket() and arg_10_1:GetExpBookAward() or 0)
		end)
		local var_1_17 = Item.getConfigData(ChapterAutoCommission.EXP_BOOK_ID).max_num

		if var_1_17 < var_1_16 then
			table.insert(var_1_11, function(arg_11_0)
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					content = i18n("auto_battle_drop_bookEXP_overflow", var_1_16 - var_1_17),
					onYes = arg_11_0
				})
			end)
		end
	end

	if var_1_4[1].type == ChapterAutoProxy.TYPE.WORLD then
		table.insert(var_1_11, function(arg_12_0)
			WorldConst.ReqWorldCheck(arg_12_0)
		end)
	end

	seriesAsync(var_1_11, function()
		self:Send(var_1_9, var_1_10, var_1_5, var_1_6, var_1_7, var_1_8, var_1_4, var_1_2, var_1_1)
	end)
end

function EndChapterAutoCommand:Send(arg_14_1, arg_14_2, arg_14_3, arg_14_4, arg_14_5, arg_14_6, arg_14_7, arg_14_8, arg_14_9)
	getProxy(ChapterAutoProxy):SetRecordEventFlag(true)
	pg.ConnectionMgr.GetInstance():Send(13014, {
		num = arg_14_3
	}, 13015, function(arg_15_0)
		if arg_15_0.result == 0 then
			local var_15_0 = getProxy(ChapterAutoProxy)

			var_15_0:SetRecordEventFlag(false)
			var_15_0:ClearCommissionList()
			var_15_0:ReduceCostTime(arg_15_0.seconds)
			var_15_0:AddTickets(arg_15_0.chapter_auto_ticket_list)
			var_15_0:IncreaseOil(arg_15_0.oil)

			if arg_14_1 == ChapterAutoProxy.TYPE.WORLD then
				local var_15_1 = nowWorld().staminaMgr

				var_15_1:UpdateStamina()
				var_15_1:PlusStamina(arg_15_0.world_ap)
			end

			local var_15_2 = false

			switch(arg_14_1, {
				[ChapterAutoProxy.TYPE.SLG] = function()
					local var_16_0 = getProxy(ChapterProxy)

					var_16_0:addRemasterPassCount(arg_14_2, nil, arg_14_4)

					local var_16_1 = var_16_0:getChapterById(arg_14_2, true)

					var_16_1:writeDrops(arg_15_0.drop_list)

					if arg_14_6 > 0 then
						if var_16_0:getMapById(var_16_1:getConfig("map")):isRemaster() then
							var_15_2 = true

							var_16_0:updateRemasterTicketsNum(math.min(var_16_0.remasterTickets + arg_14_6 * var_16_0:getRemasterTicketCost(), pg.gameset.reactivity_ticket_max.key_value))
						end
					end
				end,
				[ChapterAutoProxy.TYPE.RUSH] = function()
					local var_17_0 = getProxy(ChapterProxy)
					local var_17_1 = pg.activity_series_enemy_auto[arg_14_2].link_id

					var_17_0:addRemasterPassCount(arg_14_2, pg.activity_series_enemy_auto[arg_14_2].link_id, arg_14_4)

					if arg_14_6 > 0 and BossRushChapterRemasterHelper.GetRemasterByActivityId(var_17_1) ~= nil then
						var_17_0:updateRemasterTicketsNum(math.min(var_17_0.remasterTickets + arg_14_6 * BossRushChapterRemasterHelper.GetPermanentActivityTicketCost(var_17_1, arg_14_2), pg.gameset.reactivity_ticket_max.key_value))
					end
				end
			})
			getProxy(NavalAcademyProxy):AddProficiency(arg_15_0.class_exp)

			local var_15_3 = PlayerConst.addTranDrop(arg_15_0.drop_list)
			local var_15_4 = {}

			if arg_14_1 == ChapterAutoProxy.TYPE.WORLD then
				local var_15_5 = nowWorld()
				local var_15_6 = var_15_5:GetAtlas()

				for iter_15_0, iter_15_1 in ipairs(underscore.first(arg_14_7, arg_14_3)) do
					table.insert(var_15_4, iter_15_1.id)
					var_15_6:AddDelegatedMap(iter_15_1.id)
				end

				getProxy(WorldProxy):RecordDelegateAward({
					var_15_4,
					var_15_3
				})

				if arg_14_8 then
					local var_15_7 = {}

					for iter_15_2, iter_15_3 in ipairs(var_15_4) do
						if var_15_5.pressingAwardDic[iter_15_3].flag then
							var_15_5:FlagMapPressingAward(iter_15_3)
							var_15_6:MarkMapTransport(iter_15_3)

							if #pg.world_event_complete[var_15_5.pressingAwardDic[iter_15_3].id].event_reward_slgbuff > 0 then
								var_15_7[pg.world_event_complete[var_15_5.pressingAwardDic[iter_15_3].id].event_reward_slgbuff[1]] = defaultValue(var_15_7[pg.world_event_complete[var_15_5.pressingAwardDic[iter_15_3].id].event_reward_slgbuff[1]], 0) + pg.world_event_complete[var_15_5.pressingAwardDic[iter_15_3].id].event_reward_slgbuff[2]
							end
						end
					end

					for iter_15_4, iter_15_5 in pairs(var_15_7) do
						var_15_5:AddGlobalBuff(iter_15_4, iter_15_5)
					end
				end
			end

			self:sendNotification(GAME.END_CHAPTER_AUTO_DONE, {
				isRemaster = var_15_2,
				type = arg_14_1,
				id = arg_14_2,
				awards = var_15_3,
				proficiency = arg_15_0.class_exp,
				finishCnt = arg_14_3,
				allCnt = arg_14_3 + arg_14_5,
				mapList = var_15_4
			})
			existCall(arg_14_9)
		else
			pg.TipsMgr.GetInstance():ShowTips(errorTip("chapter_auto_end_fail", arg_15_0.result))
		end
	end)
end

return EndChapterAutoCommand
