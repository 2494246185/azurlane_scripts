local EducateCharDockScene = class("EducateCharDockScene", import("view.base.BaseUI"))

EducateCharDockScene.ON_CLOSE_VIEW = "EducateCharDockScene.ON_CLOSE_VIEW"
EducateCharDockScene.ON_SELECT = "EducateCharDockScene.ON_SELECT"
EducateCharDockScene.ON_CONFIRM = "EducateCharDockScene.ON_CONFIRM"
EducateCharDockScene.ON_SELECTED = "EducateCharDockScene.ON_SELECTED"
EducateCharDockScene.MSG_CLEAR_TIP = "EducateCharDockScene.MSG_CLEAR_TIP"

function EducateCharDockScene:getUIName()
	return "EducateCharDockUI"
end

function EducateCharDockScene:getResource(arg_2_1)
	return ResPathSupport.MergeLuaArr({
		"ui/educatechardockui",
		"ui/educatedockui_atlas",
		"ui/educatecharprofileui_atlas",
		"cue/story-richang-8.b"
	}, (function()
		local var_3_0 = {}

		for iter_3_0, iter_3_1 in ipairs(pg.secretary_special_ship.all) do
			if pg.secretary_special_ship[iter_3_1].painting then
				table.insert(var_3_0, "painting/" .. pg.secretary_special_ship[iter_3_1].painting)
				table.insert(var_3_0, "paintingface/" .. pg.secretary_special_ship[iter_3_1].painting)
			end
		end

		return var_3_0
	end)())
end

function EducateCharDockScene:init()
	self.backBtn = self._tf:Find("adapt/top/back")
	self.homeBtn = self._tf:Find("adapt/top/home")
	self.selectPage = EducateCharSelectPage.New(self._tf:Find("adapt/pages"), self.event)
	self.groupPage = EducateCharGroupPage.New(self._tf:Find("adapt/pages/groupPage"), self.event, self.contextData)
end

function EducateCharDockScene:didEnter()
	onButton(self, self.backBtn, function()
		if self.contextData.tbSkinId then
			self:closeView()

			return
		end

		if self.selectPage and self.selectPage:GetLoaded() and self.selectPage:isShowing() then
			self.selectPage:Back(function()
				self.groupPage:Show()
				self.groupPage:InitList()
				self.selectPage:Hide()
			end)

			return
		end

		self:closeView()
	end, SFX_PANEL)
	onButton(self, self.homeBtn, function()
		self:emit(EducateCharDockScene.ON_HOME)
	end, SFX_PANEL)
	self:bind(EducateCharDockScene.ON_CLOSE_VIEW, function()
		self:closeView()
	end)
	self:bind(EducateCharDockScene.ON_SELECT, function(arg_10_0, arg_10_1, arg_10_2)
		self.groupPage:Hide()
		self.selectPage:ExecuteAction("Update", arg_10_1, arg_10_2)
	end)
	self:bind(EducateCharDockScene.ON_SELECTED, function(arg_11_0, arg_11_1)
		self:emit(EducateCharDockMediator.ON_SELECTED, arg_11_1)
	end)
	self:bind(EducateCharDockScene.ON_CONFIRM, function(arg_12_0, arg_12_1)
		if self.contextData.tbSkinId then
			self:closeView()

			return
		end

		self.groupPage:Show()
		self.selectPage:Hide()
		self.groupPage:FlushList(arg_12_1)
	end)
	self.groupPage:Update()
end

function EducateCharDockScene:onBackPressed()
	if self.selectPage and self.selectPage:GetLoaded() and self.selectPage:isShowing() then
		triggerButton(self.backBtn)

		return
	end

	EducateCharDockScene.super.onBackPressed(self)
end

function EducateCharDockScene:willExit()
	if self.selectPage then
		self.selectPage:Destroy()

		self.selectPage = nil
	end

	if self.groupPage then
		self.groupPage:Destroy()

		self.groupPage = nil
	end
end

return EducateCharDockScene
