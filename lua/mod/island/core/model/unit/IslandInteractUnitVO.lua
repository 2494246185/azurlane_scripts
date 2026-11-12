local IslandInteractUnitVO = class("IslandInteractUnitVO", import(".IslandUnitVO"))

function IslandInteractUnitVO:Ctor(arg_1_1)
	IslandInteractUnitVO.super.Ctor(self, arg_1_1)

	self.config = pg.island_unit_interactive_item[self.modelId]
	self.slots = {}

	for iter_1_0 = 1, self.config.slot_cnt do
		table.insert(self.slots, InteractSlot.New(iter_1_0, self.id))
	end

	self:InitTimlineInfo()
end

function IslandInteractUnitVO:InitTimlineInfo()
	self.timelineInfo = {}

	if self.config.timeline == nil or self.config.timeline == "" then
		return
	end

	for iter_2_0, iter_2_1 in ipairs(self.config.timeline) do
		table.insert(self.timelineInfo, pg.island_item_timeline[iter_2_1])
	end
end

function IslandInteractUnitVO:GetTimeline()
	return self.timelineInfo
end

function IslandInteractUnitVO:HasTimeline()
	return #self.timelineInfo > 0
end

function IslandInteractUnitVO:GetSlot()
	return #self.slots
end

function IslandInteractUnitVO:GetBlackboardParam()
	return self.config.param
end

return IslandInteractUnitVO
