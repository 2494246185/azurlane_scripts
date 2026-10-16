local resumeMediator = class("resumeMediator", import("..base.ContextMediator"))

function resumeMediator:register()
	self.viewComponent:setPlayerVO(self.contextData.player)
end

function resumeMediator:listNotificationInterests()
	return {}
end

function resumeMediator:handleNotification(arg_3_1)
	local var_3_0 = arg_3_1:getName()
	local var_3_1 = arg_3_1:getBody()
end

return resumeMediator
