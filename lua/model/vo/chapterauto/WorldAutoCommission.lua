local WorldAutoCommission = class("WorldAutoCommission", import("model.vo.ChapterAuto.ChapterAutoTicket"))

function WorldAutoCommission:bindConfigTable()
	return pg.world_auto_statistics
end

function WorldAutoCommission:GetClassExpAward()
	assert(false)
end

function WorldAutoCommission:GetExpBookAward()
	assert(false)
end

return WorldAutoCommission
