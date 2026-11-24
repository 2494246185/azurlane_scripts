local MainActRemasterBtn = class("MainActRemasterBtn")

function MainActRemasterBtn:Ctor(arg_1_1, arg_1_2, arg_1_3, arg_1_4)
	self.tpl = arg_1_1

	pg.DelegateInfo.New(self)

	self.event = arg_1_2
	self.hideSubImg = arg_1_4

	if arg_1_3 then
		self._tf = self.tpl
	end
end

function MainActRemasterBtn:GetLinkConfig()
	return {
		param = "0",
		name = "event_actremaster",
		text_pic = "text_event_all",
		type = 3,
		pic = "event_actremaster",
		id = 1,
		group_id = 1,
		order = 1,
		time = {
			"default",
			51033
		}
	}
end

function MainActRemasterBtn:InShowTime()
	self.config = self:GetLinkConfig()

	return getProxy(ActivityRemasterProxy):ShouldShowActiveBtn()
end

function MainActRemasterBtn:NewGameObject()
	return self._tf or Object.Instantiate(self.tpl, self.tpl.parent).transform
end

function MainActRemasterBtn:Init(arg_5_1)
	self._tf = self:NewGameObject()
	self._tf.gameObject.name = self.__cname
	self.image = self._tf:Find("Image"):GetComponent(typeof(Image))
	self.subImage = self._tf:Find("sub_Image"):GetComponent(typeof(Image))
	self.tipTr = self._tf:Find("Tip"):GetComponent(typeof(Image))
	self.tipTxt = self._tf:Find("Tip/Text"):GetComponent(typeof(Text))

	setActive(self._tf, true)

	self.tipTxt.text = ""

	self:InitTipImage()
	self:UpdatePosition(arg_5_1)
	self:InitSubImage()
	self:InitImage(function()
		self:OnInit()
		self:Register()
	end)
end

function MainActRemasterBtn:Register()
	onButton(self, self._tf, function()
		self:emit(NewMainMediator.OPEN_ACT_REMASTER_SCENE)
	end, SFX_MAIN)
end

function MainActRemasterBtn:InitImage(arg_9_1)
	if not self.config.pic or self.config.pic == self.imgName then
		arg_9_1()

		return
	end

	self.imgName = self.config.pic

	LoadSpriteAtlasAsync(self:ResPath() .. "/" .. self.config.pic, "", function(arg_10_0)
		if IsNil(self.image) then
			return
		end

		self.image.sprite = arg_10_0

		self.image:SetNativeSize()
		arg_9_1()
	end)
end

function MainActRemasterBtn:InitSubImage()
	if self.hideSubImg then
		setActive(self.subImage.gameObject, false)

		return
	end

	local var_11_0 = self.config.text_pic

	setActive(self.subImage.gameObject, self.config.text_pic ~= nil and var_11_0 ~= "")

	if not var_11_0 or var_11_0 == self.subImgName then
		return
	end

	self.subImgName = var_11_0

	GetImageSpriteFromAtlasAsync(self:ResPath() .. "/" .. var_11_0, "", self.subImage, true)
end

function MainActRemasterBtn:GetTipImage()
	return "tip"
end

function MainActRemasterBtn:InitTipImage()
	local var_13_0 = self:GetTipImage()

	if not var_13_0 or var_13_0 == self.tipImageName then
		return
	end

	self.tipImageName = var_13_0

	GetImageSpriteFromAtlasAsync("LinkButton/" .. var_13_0, "", self.tipTr, true)
end

function MainActRemasterBtn:UpdatePosition(arg_14_1)
	self._tf.anchoredPosition = Vector2(self._tf.anchoredPosition.x, -150 - (arg_14_1 - 1) * (self._tf.sizeDelta.y + -20), 0)
end

function MainActRemasterBtn:Clear()
	if self._tf then
		setActive(self._tf, false)
	end
end

function MainActRemasterBtn:emit(...)
	self.event:emit(...)
end

function MainActRemasterBtn:Dispose()
	pg.DelegateInfo.Dispose(self)

	if self._tf then
		Destroy(self._tf.gameObject)

		self._tf = nil
	end
end

function MainActRemasterBtn:ResPath()
	return "LinkButton"
end

function MainActRemasterBtn:GetActivityID()
	assert(false, "策划配置default类型 必须重写这个方法")
end

function MainActRemasterBtn:CustomOnClick()
	assert(false, "策划配置type = 0 这个按钮必须自己定义跳转行为")
end

function MainActRemasterBtn:GetEventName()
	assert(false, "overwrite me !!!")
end

function MainActRemasterBtn:OnInit()
	setActive(self.tipTr.gameObject, true)
end

return MainActRemasterBtn
