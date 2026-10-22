local ActivitySingleScene = class("ActivitySingleScene", import("..base.BaseUI"))

ActivitySingleScene.EXIT = "exit"

function ActivitySingleScene:preload(arg_1_1)
	arg_1_1()
end

function ActivitySingleScene:getResource()
	local var_2_0 = ActivitySingleScene.super.getResource(self)
	local var_2_1 = self.contextData.activity

	if not self.contextData.activity and self.contextData.id then
		var_2_1 = getProxy(ActivityProxy):getActivityById(self.contextData.id)
	end

	if var_2_1 and not var_2_1:isEnd() then
		table.insertto(var_2_0, var_2_1:getPageABNames())
	end

	return var_2_0
end

function ActivitySingleScene:getUIName()
	return "ActivitySingleUI"
end

function ActivitySingleScene:init()
	self.shareData = ActivityShareData.New()
	self.pageContainer = self._tf

	pg.UIMgr.GetInstance():OverlayPanel(self._tf)
end

function ActivitySingleScene:didEnter()
	self:bind(ActivitySingleScene.EXIT, function(arg_6_0)
		self:emit(ActivitySingleScene.ON_BACK)
	end)
end

function ActivitySingleScene:setPlayer(arg_7_1)
	self.shareData:SetPlayer(arg_7_1)
end

function ActivitySingleScene:setFlagShip(arg_8_1)
	self.shareData:SetFlagShip(arg_8_1)
end

function ActivitySingleScene:updateTaskLayers()
	if not self.activity then
		return
	end

	self:updateActivity(self.activity)
end

function ActivitySingleScene:selectActivity(arg_10_1)
	self.activity = arg_10_1

	local var_10_0 = arg_10_1:getConfig("page_info")

	if var_10_0.class_name and not arg_10_1:isEnd() then
		self.actPage = import("view.activity.subPages." .. var_10_0.class_name).New(self.pageContainer, self.event, self.contextData)

		if self.actPage:UseSecondPage(arg_10_1) then
			self.actPage:SetUIName(var_10_0.ui_name2)
		else
			self.actPage:SetUIName(var_10_0.ui_name)
		end

		self.actPage:SetShareData(self.shareData)
		self.actPage:Load()
		self.actPage:ActionInvoke("Flush", self.activity)
		self.actPage:ActionInvoke("ShowOrHide", true)
	end
end

function ActivitySingleScene:updateActivity(arg_11_1)
	if ActivityConst.PageIdLink[arg_11_1.id] then
		arg_11_1 = getProxy(ActivityProxy):getActivityById(ActivityConst.PageIdLink[arg_11_1.id])
	end

	if arg_11_1:isShow() then
		if arg_11_1:isCorePage(self.contextData.coreName or "") and not arg_11_1:isEnd() and self.activity and self.activity.id == arg_11_1.id then
			self.activity = arg_11_1

			self.actPage:ActionInvoke("Flush", arg_11_1)
		end
	end
end

function ActivitySingleScene:onBackPressed()
	self.actPage:ActionInvoke("onBackPressed")
	self:emit(ActivitySingleScene.ON_BACK_PRESSED)
end

function ActivitySingleScene:willExit()
	self.shareData = nil

	if self.actPage then
		self.actPage:Destroy()
	end

	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)
end

return ActivitySingleScene
