local RecordActivityPermanentProgressCommand = class("RecordActivityPermanentProgressCommand", pm.SimpleCommand)

function RecordActivityPermanentProgressCommand:execute(arg_1_1)
	local var_1_0 = arg_1_1:getBody()
	local var_1_1 = var_1_0.callback

	if not pg.re_map_template[var_1_0.remasterId] then
		var_1_0.callback()

		return
	end

	local var_1_2 = pg.re_map_template[var_1_0.remasterId].activity_id
	local var_1_3 = BossRushChapterRemasterHelper.GetProgress(var_1_0.remasterId)

	if var_1_3 <= 0 then
		var_1_0.callback()

		return
	end

	print(var_1_2, var_1_3)
	pg.ConnectionMgr.GetInstance():Send(11216, {
		act_id = var_1_2,
		progress = var_1_3
	}, 11217, function(arg_2_0)
		if arg_2_0.result == 0 then
			getProxy(ActivityPermanentProxy):UpdateActivityProgress(var_1_2, var_1_3)
			self:sendNotification(GAME.RECORD_ACTIVITY_PERMANENT_PROGRESS_DONE)
		else
			pg.TipsMgr.GetInstance():ShowTips(errorTip("", arg_2_0.result))
		end

		var_1_1()
	end)
end

return RecordActivityPermanentProgressCommand
