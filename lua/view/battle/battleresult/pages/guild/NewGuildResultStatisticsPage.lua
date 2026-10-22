local NewGuildResultStatisticsPage = class("NewGuildResultStatisticsPage", import("..NewBattleResultStatisticsPage"))

function NewGuildResultStatisticsPage:UpdateGrade()
	LoadImageSpriteAsync("battlescore/grade_label_clear", self.gradeTxt, false)
	setActive(self.gradeIcon, false)
end

function NewGuildResultStatisticsPage:UpdatePainting(arg_2_1)
	self:UpdatePaintingPosition()
	self:UpdateMvpPainting(arg_2_1)
end

return NewGuildResultStatisticsPage
