local SpringFesMainPage = class("SpringFesMainPage", import("...base.BaseActivityPage"))

function SpringFesMainPage:OnInit()
	self.bg = self._tf:Find("AD")
	self.go1 = self.bg:Find("1")
	self.go2 = self.bg:Find("2")
	self.go3 = self.bg:Find("3")
	self.go4 = self.bg:Find("4")
end

function SpringFesMainPage:OnFirstFlush()
	onButton(self, self.go1, function()
		self:emit(ActivityMediator.SELECT_ACTIVITY, 470)
	end)
	onButton(self, self.go2, function()
		self:emit(ActivityMediator.EVENT_GO_SCENE, SCENE.COLORING)
	end)
	onButton(self, self.go3, function()
		self:emit(ActivityMediator.EVENT_GO_SCENE, SCENE.CHARGE, {
			wrap = 4
		})
	end)
	onButton(self, self.go4, function()
		self:emit(ActivityMediator.SELECT_ACTIVITY, 473)
	end)
end

return SpringFesMainPage
