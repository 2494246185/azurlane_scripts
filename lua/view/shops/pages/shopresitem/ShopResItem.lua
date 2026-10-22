local ShopResItem = class("ShopResItem")

function ShopResItem:Ctor(arg_1_1, arg_1_2)
	self._go = Object.Instantiate(arg_1_1, arg_1_2)
	self._tf = self._go.transform
	self.icon = findTF(self._tf, "icon"):GetComponent(typeof(Image))
	self.cntText = findTF(self._tf, "Text")
end

function ShopResItem:SetData(arg_2_1)
	setText(self.cntText, arg_2_1.count)
	GetImageSpriteFromAtlasAsync(arg_2_1:getIcon(), "", self.icon)
	self:Show(true)
end

function ShopResItem:Show(arg_3_1)
	setActive(self._go, arg_3_1)
end

function ShopResItem:Dispose()
	Object.Destroy(self._go)

	self._go = nil
	self._tf = nil
end

return ShopResItem
