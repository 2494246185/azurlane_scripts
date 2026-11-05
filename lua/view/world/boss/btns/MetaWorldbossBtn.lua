local MetaWorldbossBtn = class("MetaWorldbossBtn")

function MetaWorldbossBtn:Ctor(arg_1_1, arg_1_2)
	pg.DelegateInfo.New(self)

	self.event = arg_1_2
	self.metaBtn = arg_1_1
	self.metaProgress = arg_1_1:Find("Text"):GetComponent(typeof(Text))
	self.metaTip = arg_1_1:Find("tip")

	self:Init()
end

function MetaWorldbossBtn:Init()
	onButton(self, self.metaBtn, function()
		self.event:emit(WorldBossMediator.GO_META, (WorldBossConst.GetCurrBossGroup()))
	end, SFX_PANEL)
	self:Update()
end

function MetaWorldbossBtn:Update()
	setActive(self.metaTip, MetaCharacterConst.isMetaSynRedTag((WorldBossConst.GetCurrBossGroup())))
end

function MetaWorldbossBtn:Dispose()
	pg.DelegateInfo.Dispose(self)
end

return MetaWorldbossBtn
