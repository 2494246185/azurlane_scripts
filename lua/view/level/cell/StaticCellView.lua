local StaticCellView = class("StaticCellView", import("view.level.cell.LevelCellView"))

function StaticCellView:Ctor(arg_1_1)
	StaticCellView.super.Ctor(self)

	self.parent = arg_1_1
	self.go = nil
	self.tf = nil
	self.info = nil
end

function StaticCellView:PrepareBase(arg_2_1)
	self.go = GameObject.New(arg_2_1)

	self.go:AddComponent(typeof(RectTransform))
	setParent(self.go, self.parent)

	self.tf = tf(self.go)
	self.tf.sizeDelta = self.parent.sizeDelta

	self:OverrideCanvas()
	self:ResetCanvasOrder()
end

function StaticCellView:DestroyGO()
	if self.loader then
		self.loader:ClearRequests()
	end

	if not IsNil(self.go) then
		Destroy(self.go)

		self.go = nil
		self.tf = nil
	end
end

function StaticCellView:Update()
	assert(false, "not implemented")
end

function StaticCellView:Clear()
	self.parent = nil
	self.info = nil

	self:DestroyGO()
end

return StaticCellView
