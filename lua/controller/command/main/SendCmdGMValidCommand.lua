local SendCmdGMValidCommand = class("SendCmdGMValidCommand", pm.SimpleCommand)

function SendCmdGMValidCommand:execute(arg_1_1)
	local var_1_0 = arg_1_1:getBody()

	pg.ConnectionMgr.GetInstance():Send(11100, {
		cmd = "is_gm"
	}, 11101, function(arg_2_0)
		existCall(var_1_0, arg_2_0.result == 0, arg_2_0.msg)
	end)
end

return SendCmdGMValidCommand
