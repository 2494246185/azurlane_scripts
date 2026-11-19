local MainRequestNewInstagramDataSequence = class("MainRequestNewInstagramDataSequence")

function MainRequestNewInstagramDataSequence:Execute(arg_1_1)
	local var_1_0 = {}

	if not getProxy(InstagramProxy):IsReqNewInstagramData() then
		table.insert(var_1_0, function(arg_2_0)
			pg.m02:sendNotification(GAME.REQ_NEW_INSTAGRAM_DATA, {
				idList = getProxy(InstagramProxy):GetNewInstagramIds(),
				callback = arg_2_0
			})
		end)
	end

	seriesAsync(var_1_0, arg_1_1)
end

return MainRequestNewInstagramDataSequence
