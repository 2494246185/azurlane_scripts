local BossRushVeritasAcademyFleetSelectView = class("BossRushVeritasAcademyFleetSelectView", import("view.activity.BossRush.BossRushFleetSelectView"))

function BossRushVeritasAcademyFleetSelectView:GetTextColor()
	return Color.NewHex("272727"), Color.NewHex("FFFFFF")
end

function BossRushVeritasAcademyFleetSelectView:GetAutoInfoLayout()
	return {
		["Title/Text"] = {
			{
				x = -325,
				y = -112
			},
			{
				x = -325,
				y = -70
			}
		},
		Description = {
			{
				x = -105,
				y = 207
			},
			{
				x = -105,
				y = 250
			}
		},
		Boss = {
			{
				x = -110,
				y = -82
			},
			{
				x = -110,
				y = 20
			}
		},
		Modes = {
			{
				x = -110,
				y = -182
			},
			{
				x = -110,
				y = -68
			}
		},
		Start = {
			{
				x = -110,
				y = -267
			},
			{
				x = -110,
				y = -300
			}
		}
	}
end

function BossRushVeritasAcademyFleetSelectView:getUIName()
	return "BossRushVeritasAcademyFleetSelectUI"
end

function BossRushVeritasAcademyFleetSelectView:tempCache()
	return true
end

return BossRushVeritasAcademyFleetSelectView
