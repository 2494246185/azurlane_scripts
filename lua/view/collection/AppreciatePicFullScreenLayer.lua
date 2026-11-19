local AppreciatePicFullScreenLayer = class("AppreciatePicFullScreenLayer", import("..base.BaseUI"))

function AppreciatePicFullScreenLayer:getUIName()
	return "AppreciatePicFullScreenUI"
end

function AppreciatePicFullScreenLayer:init()
	self:findUI()
	self:initData()
	self:addListener()
	self:updatePanel()
end

function AppreciatePicFullScreenLayer:didEnter()
	pg.UIMgr.GetInstance():BlurPanel(self._tf)
end

function AppreciatePicFullScreenLayer:willExit()
	pg.UIMgr.GetInstance():UnOverlayPanel(self._tf)
	self.resLoader:Clear()
end

function AppreciatePicFullScreenLayer:findUI()
	return
end

function AppreciatePicFullScreenLayer:initData()
	self.resLoader = AutoLoader.New()
	self.curPicInfo = self.contextData.curPicInfo
end

function AppreciatePicFullScreenLayer:addListener()
	onButton(self, self.bg, function()
		self:closeView()
	end, SFX_PANEL)
	onButton(self, self.galleryPicImg, function()
		self:closeView()
	end, SFX_PANEL)
	onButton(self, self.mangaPicImg, function()
		self:closeView()
	end, SFX_PANEL)
end

function AppreciatePicFullScreenLayer:updatePanel()
	setActive(self.galleryPanel, self.curPicInfo.type == AppreciatePicConst.TYPE_GALLERY)
	setActive(self.mangaPanel, self.curPicInfo.type == AppreciatePicConst.TYPE_MANGA)

	if self.curPicInfo.type == AppreciatePicConst.TYPE_GALLERY then
		self:updateGalleryPanel()
	elseif self.curPicInfo.type == AppreciatePicConst.TYPE_MANGA then
		self:updateMangaPanel()
	end
end

function AppreciatePicFullScreenLayer:updateGalleryPanel()
	self:setImage(self.galleryPicImg, self.curPicInfo)
end

function AppreciatePicFullScreenLayer:updateMangaPanel()
	self:setImage(self.mangaPicImg, self.curPicInfo)
end

function AppreciatePicFullScreenLayer:setImage(arg_14_1, arg_14_2)
	local var_14_0 = GetFileName(arg_14_2.path)
	local var_14_1 = GetComponent(arg_14_1, typeof(Image)).sprite

	if not IsNil(var_14_1) then
		if string.lower(var_14_1.name) ~= string.lower(var_14_0) then
			self.resLoader:LoadSprite(arg_14_2.path, var_14_0, arg_14_1, false)
		end
	else
		self.resLoader:LoadSprite(arg_14_2.path, var_14_0, arg_14_1, false)
	end
end

return AppreciatePicFullScreenLayer
