local FormationSuggestionShipInfoMediator = class("FormationSuggestionShipInfoMediator", import("view.base.ContextMediator"))

FormationSuggestionShipInfoMediator.JUMP_TO_SCENE = "FormationSuggestionShipInfoMediator::JUMP_TO_SCENE"

function FormationSuggestionShipInfoMediator:register()
	self:bind(FormationSuggestionShipInfoMediator.JUMP_TO_SCENE, function(arg_2_0, arg_2_1)
		self:sendNotification(GAME.JUMP_TO_SCENE, arg_2_1)
	end)
	self:sendNotification(GAME.FORMATION_SUGGESTION_OPEN_SHIP_INFO)
end

function FormationSuggestionShipInfoMediator:initNotificationHandleDic()
	self.handleDic = {
		[GAME.FORMATION_SUGGESTION_CLOSE_SHIP_INFO] = function(arg_4_0, arg_4_1)
			arg_4_0.viewComponent:closeView()
		end
	}
end

return FormationSuggestionShipInfoMediator
