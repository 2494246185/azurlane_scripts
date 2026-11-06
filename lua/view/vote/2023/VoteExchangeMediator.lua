local VoteExchangeMediator = class("VoteExchangeMediator", import("view.base.ContextMediator"))

VoteExchangeMediator.GO_TASK = "VoteExchangeMediator:GO_TASK"
VoteExchangeMediator.SKIP_TASK = "VoteExchangeMediator:SKIP_TASK"
VoteExchangeMediator.SUBMIT_TASK = "VoteExchangeMediator:SUBMIT_TASK"

function VoteExchangeMediator:register()
	self:bind(VoteExchangeMediator.GO_TASK, function(arg_2_0)
		self:sendNotification(GAME.GO_SCENE, SCENE.TASK, {
			page = TaskScene.PAGE_TYPE_ROUTINE
		})
	end)
	self:bind(VoteExchangeMediator.SKIP_TASK, function(arg_3_0, arg_3_1)
		self:sendNotification(GAME.TASK_GO, {
			taskVO = arg_3_1
		})
	end)
	self:bind(VoteExchangeMediator.SUBMIT_TASK, function(arg_4_0, arg_4_1)
		self:sendNotification(GAME.SUBMIT_TASK, arg_4_1)
	end)
end

function VoteExchangeMediator:listNotificationInterests()
	return {
		GAME.SUBMIT_TASK_DONE
	}
end

function VoteExchangeMediator:handleNotification(arg_6_1)
	local var_6_0 = arg_6_1:getBody()

	if arg_6_1:getName() == GAME.SUBMIT_TASK_DONE then
		self.viewComponent:Flush()
	end
end

return VoteExchangeMediator
