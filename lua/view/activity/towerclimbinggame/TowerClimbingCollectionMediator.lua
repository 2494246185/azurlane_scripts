local TowerClimbingCollectionMediator = class("TowerClimbingCollectionMediator", import("...base.ContextMediator"))

TowerClimbingCollectionMediator.ON_GET = "TowerClimbingCollectionMediator:ON_GET"

function TowerClimbingCollectionMediator:register()
	self:bind(TowerClimbingCollectionMediator.ON_GET, function(arg_2_0, arg_2_1)
		self:sendNotification(GAME.SEND_MINI_GAME_OP, {
			hubid = 9,
			cmd = MiniGameOPCommand.CMD_SPECIAL_GAME,
			args1 = {
				MiniGameDataCreator.TowerClimbingGameID,
				2,
				arg_2_1
			}
		})
	end)
	self.viewComponent:SetData((getProxy(MiniGameProxy):GetMiniGameData(MiniGameDataCreator.TowerClimbingGameID):clone()))
end

function TowerClimbingCollectionMediator:listNotificationInterests()
	return {
		GAME.SEND_MINI_GAME_OP_DONE
	}
end

function TowerClimbingCollectionMediator:handleNotification(arg_4_1)
	local var_4_0 = arg_4_1:getBody()

	if arg_4_1:getName() == GAME.SEND_MINI_GAME_OP_DONE and var_4_0.hubid == 9 and var_4_0.cmd == MiniGameOPCommand.CMD_SPECIAL_GAME and var_4_0.argList[1] == MiniGameDataCreator.TowerClimbingGameID and var_4_0.argList[2] == 2 then
		self.viewComponent:SetData((getProxy(MiniGameProxy):GetMiniGameData(MiniGameDataCreator.TowerClimbingGameID)))
		self.viewComponent:OpenBook(var_4_0.argList[3])
		self.viewComponent:UpdateTip()
	end
end

return TowerClimbingCollectionMediator
