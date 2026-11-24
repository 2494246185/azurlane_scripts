local BossRushConst = class("BossRushConst")

function BossRushConst:GetPassedLayer()
	return switch(self, {
		[ActivityConst.ALVIT_BOSS_RUSH_ID] = function()
			return BossRushAlvitPassedLayer
		end,
		[ActivityConst.ZENGKEHAIJUNSHANGJIANG_BOSS_RUSH_ID] = function()
			return BossRushSardiniaPassedLayer
		end,
		[ActivityConst.ESCAPE_BOSS_RUSH_ID] = function()
			return BossRushEscapeManorPassedLayer
		end,
		[ActivityConst.VERITASACADEMY_BOSS_RUSH_ACT_ID] = function()
			return BossRushVeritasAcademyPassedLayer
		end
	}, function()
		local var_6_0 = checkExist(pg.activity_template[self], {
			"config_client"
		}, {
			"passed"
		})

		return (var_6_0 or nil) and (_G[var_6_0] or BossRushPassedCombatLoadLayer)
	end)
end

function BossRushConst:GetEXBattleResultLayer()
	return switch(self, {
		[ActivityConst.ALVIT_BOSS_RUSH_ID] = function()
			return BossRushAlvitEXBattleResultLayer
		end,
		[ActivityConst.ZENGKEHAIJUNSHANGJIANG_BOSS_RUSH_ID] = function()
			return BossRushVerZenkerEXBattleResultLayer
		end,
		[ActivityConst.ESCAPE_BOSS_RUSH_ID] = function()
			return BossRushEscapeManorBattleResultLayer
		end,
		[ActivityConst.VERITASACADEMY_BOSS_RUSH_ACT_ID] = function()
			return BossRushVeritasAcademyBattleResultLayer
		end
	}, function()
		local var_12_0 = checkExist(pg.activity_template[self], {
			"config_client"
		}, {
			"result"
		})

		return (var_12_0 or nil) and (_G[var_12_0] or BossRushEXBattleResultLayer)
	end)
end

return BossRushConst
