local NewServerMainPage = class("NewServerMainPage", import("...base.BaseActivityPage"))

function NewServerMainPage:OnInit()
	self.bg = self._tf:Find("AD")
	self.time = self.bg:Find("time")
	self.shopBtn = self.bg:Find("btn_list/shop")
	self.fightBtn = self.bg:Find("btn_list/fight")
	self.buildBtn = self.bg:Find("btn_list/build")
end

function NewServerMainPage:OnFirstFlush()
	onButton(self, self.shopBtn, function()
		pg.m02:sendNotification(GAME.GO_SCENE, SCENE.NEW_SERVER_CARNIVAL, {
			page = NewServerCarnivalScene.SHOP_PAGE
		})
	end)
	onButton(self, self.buildBtn, function()
		local var_4_0 = getProxy(ActivityProxy):getActivityByType(ActivityConst.ACTIVITY_TYPE_NEWSERVER_BUILD)

		if var_4_0 and not var_4_0:isEnd() then
			self:emit(ActivityMediator.EVENT_GO_SCENE, SCENE.GETBOAT, {
				page = BuildShipScene.PAGE_NEWSERVER
			})
		else
			self:emit(ActivityMediator.EVENT_GO_SCENE, SCENE.GETBOAT)
		end
	end)
	onButton(self, self.fightBtn, function()
		self:emit(ActivityMediator.SPECIAL_BATTLE_OPERA)
	end)
	self:updateTime()
end

function NewServerMainPage:updateTime()
	local var_6_0 = pg.TimeMgr.GetInstance()

	setText(self.time, var_6_0:STimeDescS(self.activity:getStartTime(), "%m.%d") .. " - " .. var_6_0:STimeDescS(self.activity.stopTime, "%m.%d %H:%M"))
end

function NewServerMainPage:OnUpdateFlush()
	return
end

return NewServerMainPage
