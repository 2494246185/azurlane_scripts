local ActivityRemasterMediator = class("ActivityRemasterMediator", import("view.base.ContextMediator"))

ActivityRemasterMediator.ACTIVE_ACT = "ActivityRemasterMediator.ACTIVE_ACT"

function ActivityRemasterMediator:register()
	self:bind(ActivityRemasterMediator.ACTIVE_ACT, function(arg_2_0, arg_2_1)
		self:sendNotification(GAME.ACT_REMASTER_ACTIVE, {
			id = arg_2_1
		})
	end)
end

function ActivityRemasterMediator:listNotificationInterests()
	return {
		GAME.ACT_REMASTER_ACTIVE_DONE
	}
end

function ActivityRemasterMediator:handleNotification(arg_4_1)
	local var_4_0 = arg_4_1:getBody()

	if arg_4_1:getName() == GAME.ACT_REMASTER_ACTIVE_DONE then
		self.viewComponent:emit(BaseUI.ON_BACK)
	end
end

return ActivityRemasterMediator
