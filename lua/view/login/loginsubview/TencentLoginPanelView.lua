local TencentLoginPanelView = class("TencentLoginPanelView", import("...base.BaseSubView"))

function TencentLoginPanelView:getUIName()
	return "TencentLoginPanelView"
end

function TencentLoginPanelView:OnLoaded()
	return
end

function TencentLoginPanelView:SetShareData(arg_3_1)
	self.shareData = arg_3_1
end

function TencentLoginPanelView:OnInit()
	self.tencentPanel = self._tf
	self.wxLoginBtn = self.tencentPanel:Find("wx_login")
	self.qqLoginBtn = self.tencentPanel:Find("qq_login")

	self:InitEvent()
end

function TencentLoginPanelView:InitEvent()
	onButton(self, self.qqLoginBtn, function()
		pg.SdkMgr.GetInstance():LoginSdk(1)
	end)
	onButton(self, self.wxLoginBtn, function()
		pg.SdkMgr.GetInstance():LoginSdk(2)
	end)
end

function TencentLoginPanelView:OnDestroy()
	return
end

return TencentLoginPanelView
