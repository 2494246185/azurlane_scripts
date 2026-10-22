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
				}))),
				onYes = arg_3_0
			})
		end)
	end

	if underscore.any(var_1_4, function(arg_6_0)
		local var_6_0

		if not arg_6_0:IsFinished() then
			var_6_0 = arg_6_0:UsedTicket()

			if var_6_0 then
				var_6_0 = pg.TimeMgr.GetInstance():GetServerTime() > arg_6_0:GetTicketTime()
			end
		end

		return var_6_0
	end) then
		table.insert(var_1_11, function(arg_7_0)
			pg.MsgboxMgr.GetInstance():ShowMsgBox({
				content = i18n("auto_battle_drop_book_expired"),
				onYes = arg_7_0
			})
		end)
	end

	if var_1_4[1].type == ChapterAutoProxy.TYPE.SLG then
		local var_1_12 = getProxy(NavalAcademyProxy)
		local var_1_13 = var_1_12:getCourse()
		local var_1_14 = var_1_12:GetClassVO():GetMaxProficiency()
		local var_1_15 = var_1_13:GetProficiency() + var_1_4[1]:GetClassExpAward() * var_1_5

		if var_1_14 < var_1_13 then
			table.insert(var_1_11, function(arg_8_0)
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					content = i18n("auto_battle_drop_classEXP_overflow", var_1_15 - var_1_14),
					onYes = arg_8_0
				})
			end)
		end

		local var_1_16 = getProxy(BagProxy):getItemCountById(ChapterAutoCommission.EXP_BOOK_ID) + underscore.reduce(var_1_4, 0, function(arg_9_0, arg_9_1)
			return arg_9_0 + (arg_9_1:IsFinished() and arg_9_1:UsedTicket() and arg_9_1:GetExpBookAward() or 0)
		end)
		local var_1_17 = Item.getConfigData(ChapterAutoCommission.EXP_BOOK_ID).max_num

		if var_1_17 < var_1_16 then
			table.insert(var_1_11, function(arg_10_0)
				pg.MsgboxMgr.GetInstance():ShowMsgBox({
					content = i18n("auto_battle_drop_bookEXP_overflow", var_1_16 - var_1_17),
					onYes = arg_10_0
				})
			end)
		end
	end

	if var_1_4[1].type == ChapterAutoProxy.TYPE.WORLD then
		table.insert(var_1_11, function(arg_11_0)
			WorldConst.ReqWorldCheck(arg_11_0)
		end)
	end

	seriesAsync(var_1_11, function()
		self:Send(var_1_9, var_1_10, var_1_5, var_1_6, var_1_7, var_1_8, var_1_4, var_1_2, var_1_1)
	end)
end

function EndChapterAutoCommand:Send(arg_13_1, arg_13_2, arg_13_3, arg_13_4, arg_13_5, arg_13_6, arg_13_7, arg_13_8, arg_13_9)
	getProxy(ChapterAutoProxy):SetRecordEventFlag(true)
	pg.ConnectionMgr.GetInstance():Send(13014, {
		num = arg_13_3
	}, 13015, function(arg_14_0)
		if arg_14_0.result == 0 then
			local var_14_0 = getProxy(ChapterAutoProxy)

			var_14_0:SetRecordEventFlag(false)
			var_14_0:ClearCommissionList()
			var_14_0:ReduceCostTime(arg_14_0.seconds)
			var_14_0:AddTickets(arg_14_0.chapter_auto_ticket_list)
			var_14_0:IncreaseOil(arg_14_0.oil)

			if arg_13_1 == ChapterAutoProxy.TYPE.WORLD then
				local var_14_1 = nowWorld().staminaMgr

				var_14_1:UpdateStamina()
				var_14_1:PlusStamina(arg_14_0.world_ap)
			end

			local var_14_2 = false

			switch(arg_13_1, {
				[ChapterAutoProxy.TYPE.SLG] = function()
					local var_15_0 = getProxy(ChapterProxy)

					var_15_0:addRemasterPassCount(arg_13_2, nil, arg_13_4)

					local var_15_1 = var_15_0:getChapterById(arg_13_2, true)

					var_15_1:writeDrops(arg_14_0.drop_list)

					if arg_13_6 > 0 then
						if var_15_0:getMapById(var_15_1:getConfig("map")):isRemaster() then
							var_14_2 = true

							var_15_0:updateRemasterTicketsNum(math.min(var_15_0.remasterTickets + arg_13_6 * var_15_0:getRemasterTicketCost(), pg.gameset.reactivity_ticket_max.key_value))
						end
					end
				end
			})
			getProxy(NavalAcademyProxy):AddProficiency(arg_14_0.class_exp)

			local var_14_3 = PlayerConst.addTranDrop(arg_14_0.drop_list)
			local var_14_4 = {}

			if arg_13_1 == ChapterAutoProxy.TYPE.WORLD then
				local var_14_5 = nowWorld()
				local var_14_6 = var_14_5:GetAtlas()

				for iter_14_0, iter_14_1 in ipairs(underscore.first(arg_13_7, arg_13_3)) do
					table.insert(var_14_4, iter_14_1.id)
					var_14_6:AddDelegatedMap(iter_14_1.id)
				end

				getProxy(WorldProxy):RecordDelegateAward({
					var_14_4,
					var_14_3
				})

				if arg_13_8 then
					local var_14_7 = {}

					for iter_14_2, iter_14_3 in ipairs(var_14_4) do
						if var_14_5.pressingAwardDic[iter_14_3].flag then
							var_14_5:FlagMapPressingAward(iter_14_3)
							var_14_6:MarkMapTransport(iter_14_3)

							if #pg.world_event_complete[var_14_5.pressingAwardDic[iter_14_3].id].event_reward_slgbuff > 0 then
								var_14_7[pg.world_event_complete[var_14_5.pressingAwardDic[iter_14_3].id].event_reward_slgbuff[1]] = defaultValue(var_14_7[pg.world_event_complete[var_14_5.pressingAwardDic[iter_14_3].id].event_reward_slgbuff[1]], 0) + pg.world_event_complete[var_14_5.pressingAwardDic[iter_14_3].id].event_reward_slgbuff[2]
							end
						end
					end

					for iter_14_4, iter_14_5 in pairs(var_14_7) do
						var_14_5:AddGlobalBuff(iter_14_4, iter_14_5)
					end
				end
			end

			self:sendNotification(GAME.END_CHAPTER_AUTO_DONE, {
				isRemaster = var_14_2,
				type = arg_13_1,
				id = arg_13_2,
				awards = var_14_3,
				proficiency = arg_14_0.class_exp,
				finishCnt = arg_13_3,
				allCnt = arg_13_3 + arg_13_5,
				mapList = var_14_4
			})
			existCall(arg_13_9)
		else
			pg.TipsMgr.GetInstance():ShowTips(errorTip("chapter_auto_end_fail", arg_14_0.result))
		end
	end)
end

return EndChapterAutoCommand
