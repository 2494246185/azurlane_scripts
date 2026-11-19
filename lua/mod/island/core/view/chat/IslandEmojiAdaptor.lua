local IslandEmojiAdaptor = class("IslandEmojiAdaptor", import("..IslandBaseUnit"))

function IslandEmojiAdaptor:Ctor(arg_1_1)
	IslandEmojiAdaptor.super.Ctor(self, arg_1_1)

	self.loaded = false
end

function IslandEmojiAdaptor:Init(arg_2_1)
	self.emojiLayer = IslandEmojiLayer.New()

	self.emojiLayer:bind(BaseUI.ON_CLOSE, function()
		self.emojiLayer:exit()

		self.emojiLayer = nil
		self.loaded = false
	end)
	self.emojiLayer:setContextData(arg_2_1)

	local function var_2_1()
		self.emojiLayer.event:disconnect(BaseUI.LOADED, var_2_1)
		self.emojiLayer:enter()
		IslandEmojiAdaptor.super.Init(self)

		self.loaded = true
	end

	self.emojiLayer.event:connect(BaseUI.LOADED, nil)
	self.emojiLayer:load()
end

function IslandEmojiAdaptor:OnDispose()
	IslandEmojiAdaptor.super.OnDispose(self)

	if self.loaded then
		self.emojiLayer:exit()

		self.emojiLayer = nil
	end
end

return IslandEmojiAdaptor
