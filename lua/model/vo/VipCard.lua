local VipCard = class("VipCard", import(".BaseVO"))

VipCard.MONTH = 1

function VipCard:Ctor(arg_1_1)
	self.id = arg_1_1.type
	self.type = arg_1_1.type
	self.leftDate = arg_1_1.left_date
	self.data = arg_1_1.data
end

function VipCard:getLeftDate()
	if self.type == VipCard.MONTH then
		return self.leftDate + 86400
	end
end

function VipCard:GetLeftDay()
	return (math.floor((self:getLeftDate() - pg.TimeMgr.GetInstance():GetServerTime()) / 86400))
end

function VipCard:isExpire()
	if self.type == VipCard.MONTH then
		return self:getLeftDate() <= pg.TimeMgr.GetInstance():GetServerTime()
	end
end

return VipCard
