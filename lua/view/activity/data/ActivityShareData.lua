local ActivityShareData = class("ActivityShareData")

function ActivityShareData:Ctor()
	return
end

function ActivityShareData:SetPlayer(arg_2_1)
	self.player = arg_2_1
end

function ActivityShareData:SetFlagShip(arg_3_1)
	self.flagShip = arg_3_1
end

return ActivityShareData
