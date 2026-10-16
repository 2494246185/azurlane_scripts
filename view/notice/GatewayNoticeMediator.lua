local GatewayNoticeMediator = class("GatewayNoticeMediator", import("..base.ContextMediator"))

function GatewayNoticeMediator:register()
	self:updateNotices()
end

function GatewayNoticeMediator:updateNotices()
	self.viewComponent:updateNotices(getProxy(GatewayNoticeProxy):getGatewayNotices(false))
end

return GatewayNoticeMediator
