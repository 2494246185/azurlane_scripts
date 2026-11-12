local MainPrevPeriodCrusingChargeTipMeidator = class("MainPrevPeriodCrusingChargeTipMeidator", pm.Mediator)

function MainPrevPeriodCrusingChargeTipMeidator:Ctor(arg_1_1)
	MainPrevPeriodCrusingChargeTipMeidator.super.Ctor(self)

	self.sequence = arg_1_1

	pg.m02:registerMediator(self)
end

function MainPrevPeriodCrusingChargeTipMeidator:listNotificationInterests()
	return {
		GAME.CHARGE_SUCCESS
	}
end

function MainPrevPeriodCrusingChargeTipMeidator:handleNotification(arg_3_1)
	if arg_3_1:getName() == GAME.CHARGE_SUCCESS then
		self.sequence:OnChargeSuccess((arg_3_1:getBody()))
	end
end

function MainPrevPeriodCrusingChargeTipMeidator:Dispose()
	pg.m02:removeMediator(self.__cname)
end

return MainPrevPeriodCrusingChargeTipMeidator
