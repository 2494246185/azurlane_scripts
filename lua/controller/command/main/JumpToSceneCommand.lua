local JumpToSceneCommand = class("JumpToSceneCommand", pm.SimpleCommand)

function JumpToSceneCommand:execute(arg_1_1)
	local var_1_0 = arg_1_1:getBody()
	local var_1_1 = var_1_0[1]
	local var_1_2 = var_1_0[2]

	switch(var_1_0[1], {
		[SCENE.CORE_ACTIVITY] = function()
			self:JumpToCoreActivity(var_1_1, var_1_2)
		end
	}, function()
		self:sendNotification(GAME.GO_SCENE, var_1_1, var_1_2)
	end)
end

function JumpToSceneCommand:JumpToCoreActivity(arg_4_1, arg_4_2)
	if arg_4_2.id then
		if not getProxy(ActivityProxy):IsActivityNotEnd(arg_4_2.id) then
			pg.TipsMgr.GetInstance():ShowTips(i18n("challenge_end_tip"))

			return
		end
	end

	self:sendNotification(GAME.GO_SCENE, arg_4_1, arg_4_2)
end

return JumpToSceneCommand
