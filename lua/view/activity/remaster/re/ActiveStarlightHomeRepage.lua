local ActiveStarlightHomeRepage = class("ActiveStarlightHomeRepage", import("view.activity.subPages.ActiveStarlightHomepage"))

function ActiveStarlightHomeRepage:Ctor(arg_1_1, arg_1_2, arg_1_3)
	ActiveStarlightHomeRepage.super.Ctor(self, arg_1_1, arg_1_2, arg_1_3)
	ActivityRemasterUtil.AdapterCoreScene(self, arg_1_1, arg_1_2, arg_1_3)
end

function ActiveStarlightHomeRepage:OnFirstFlush()
	ActiveStarlightHomeRepage.super.OnFirstFlush(self)
	self:UpdateTime()
end

function ActiveStarlightHomeRepage:UpdateTime()
	ActivityRemasterUtil.UpdateTime(self)
end

return ActiveStarlightHomeRepage
