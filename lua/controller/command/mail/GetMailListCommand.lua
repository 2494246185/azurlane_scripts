local GetMailListCommand = class("GetMailListCommand", pm.SimpleCommand)

function GetMailListCommand:execute(arg_1_1)
	local var_1_0 = arg_1_1:getBody()
	local var_1_1 = var_1_0.cmd
	local var_1_2 = var_1_0.callback
	local var_1_3, var_1_4, var_1_5 = switch(var_1_0.cmd, {
		new = function()
			return 1, getProxy(MailProxy):GetNewIndex()
		end,
		next = function()
			return 1, getProxy(MailProxy):GetNextIndex()
		end,
		important = function()
			return 2, 0, 0
		end,
		rare = function()
			return 3, 0, 0
		end
	})

	if var_1_5 < var_1_4 then
		warning("without mail can require")

		return
	end

	pg.ConnectionMgr.GetInstance():Send(30002, {
		type = var_1_3,
		index_begin = var_1_4,
		index_end = var_1_5
	}, 30003, function(arg_6_0)
		local var_6_0 = underscore.map(arg_6_0.mail_list, function(arg_7_0)
			return Mail.New(arg_7_0)
		end)

		switch(var_1_1, {
			new = function()
				getProxy(MailProxy):AddNewMails(var_6_0)
			end,
			next = function()
				getProxy(MailProxy):AddNextMails(var_6_0)
			end,
			important = function()
				getProxy(MailProxy):SetImportantMails(var_6_0)
			end,
			rare = function()
				getProxy(MailProxy):SetRareMails(var_6_0)
			end
		})
		existCall(var_1_2)
		self:sendNotification(GAME.GET_MAIL_LIST_DONE)
	end)
end

return GetMailListCommand
