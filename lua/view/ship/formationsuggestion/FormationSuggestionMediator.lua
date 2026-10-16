local FormationSuggestionMediator = class("FormationSuggestionMediator", import("view.base.ContextMediator"))

FormationSuggestionMediator.ON_CLOSE_SHIP_INFO = "FormationSuggestionMediator::ON_CLOSE_SHIP_INFO"

function FormationSuggestionMediator:register()
	self:bind(FormationSuggestionMediator.ON_CLOSE_SHIP_INFO, function(arg_2_0, arg_2_1)
		self:sendNotification(GAME.FORMATION_SUGGESTION_CLOSE_SHIP_INFO)
	end)
end

function FormationSuggestionMediator:initNotificationHandleDic()
	self.handleDic = {
		[GAME.FORMATION_SUGGESTION_OPEN_SHIP_INFO] = function(arg_4_0, arg_4_1)
			arg_4_0.viewComponent:OnOpenShipInfo()
		end,
		[GAME.FORMATION_SUGGESTION_EXIT_SHIP_INFO] = function(arg_5_0, arg_5_1)
			arg_5_0.viewComponent:OnCloseShipInfo()
		end
	}
end

function FormationSuggestionMediator:remove()
	return
end

return FormationSuggestionMediator
