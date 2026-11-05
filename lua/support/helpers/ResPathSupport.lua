ResPathSupport = {}

local var_0_0 = ResPathSupport

ResPathSupport.ConstPath = {}
ResPathSupport.ConstPath.BG = {}
ResPathSupport.ConstPath.BG.Base = "bg"
ResPathSupport.ConstPath.BG.CommonBG = "commonbg"
ResPathSupport.ConstPath.BG.ShipRarityBG = "bg/star_level_bg_%s%s"
ResPathSupport.ConstPath.BG.ShipRarityUI = "ui/star_level_bg_%s%s"
ResPathSupport.ConstPath.BG.ShipRarityEffect = "ui/al_bg02_%s"
ResPathSupport.ConstPath.BG.ShipCard = "bg/star_level_card_%s"
ResPathSupport.ConstPath.BG.ShipBGFixList = {
	"",
	"_0",
	"_1"
}
ResPathSupport.ConstPath.BG.LoadingBGList = {
	"loadingbg",
	"loadingbg_hx"
}
ResPathSupport.ConstPath.BG.LoadingBG = "loadingbg"
ResPathSupport.ConstPath.Sound = {}
ResPathSupport.ConstPath.Sound.Default = "cue/%s.b"
ResPathSupport.ConstPath.Sound.BGM = "cue/bgm-%s.b"
ResPathSupport.ConstPath.Painting = {}
ResPathSupport.ConstPath.Painting.Base = "painting/%s%s"
ResPathSupport.ConstPath.Painting.FixList = {
	"",
	"_blueprint",
	"_ex",
	"_hx",
	"_n",
	"_n_ex",
	"_n_hx",
	"_n_rw",
	"_pt_hx",
	"_rank",
	"_shophx",
	"_wjz",
	"_wjz_hx"
}
ResPathSupport.ConstPath.Painting.ShopFixList = {
	"",
	"_hx",
	"_shophx"
}
ResPathSupport.ConstPath.PaintingFace = {}
ResPathSupport.ConstPath.PaintingFace.Base = "paintingface/%s%s"
ResPathSupport.ConstPath.PaintingFace.FixList = {
	"",
	"_hx"
}
ResPathSupport.ConstPath.PaintingShipYardIcon = {}
ResPathSupport.ConstPath.PaintingShipYardIcon.Base = "shipyardicon/%s%s"
ResPathSupport.ConstPath.PaintingShipYardIcon.FixList = {
	"",
	"_hx"
}
ResPathSupport.ConstPath.PaintingSquareIcon = {}
ResPathSupport.ConstPath.PaintingSquareIcon.Base = "squareicon/%s%s"
ResPathSupport.ConstPath.PaintingSquareIcon.FixList = {
	"",
	"_hx"
}
ResPathSupport.ConstPath.PaintingHeroHrzIcon = {}
ResPathSupport.ConstPath.PaintingHeroHrzIcon.Base = "herohrzicon/%s%s"
ResPathSupport.ConstPath.PaintingHeroHrzIcon.FixList = {
	"",
	"_hx"
}
ResPathSupport.ConstPath.Live2D = {}
ResPathSupport.ConstPath.Live2D.Base = "live2d/%s%s"
ResPathSupport.ConstPath.Live2D.FixList = {
	"",
	"_hx"
}
ResPathSupport.ConstPath.SpinePainting = {}
ResPathSupport.ConstPath.SpinePainting.Base = "spinepainting/%s%s"
ResPathSupport.ConstPath.SpinePainting.FixList = {
	"",
	"_hx"
}
ResPathSupport.ConstPath.SpineChar = {}
ResPathSupport.ConstPath.SpineChar.Base = "char/%s%s"
ResPathSupport.ConstPath.SpineChar.FixList = {
	"",
	"_hx",
	"_l",
	"_r"
}
ResPathSupport.ConstPath.SpineQIcon = {}
ResPathSupport.ConstPath.SpineQIcon.Base = "qicon/%s%s"
ResPathSupport.ConstPath.SpineQIcon.FixList = {
	"",
	"_hx",
	"_l",
	"_r"
}
ResPathSupport.ConstPath.SpineModel = {}
ResPathSupport.ConstPath.SpineModel.Base = "shipmodels/%s%s"
ResPathSupport.ConstPath.SpineModel.FixList = {
	"",
	"_hx",
	"_l",
	"_r"
}
ResPathSupport.ConstPath.Ship = {}
ResPathSupport.ConstPath.Ship.Rarity = {}
ResPathSupport.ConstPath.Ship.Rarity.NewShipBG = "newshipbg/bg_%s"
ResPathSupport.ConstPath.Ship.Rarity.EffectDesign = "raritydesign/%s"
ResPathSupport.ConstPath.Ship.Rarity.EffectMeta = "raritymeta/%s"
ResPathSupport.ConstPath.Ship.Rarity.ShipRarity = "shiprarity/%s%s%s"
ResPathSupport.ConstPath.Ship.Rarity.ShipRarityFixList1 = {
	"",
	"0",
	"1"
}
ResPathSupport.ConstPath.Ship.Rarity.ShipRarityFixList2 = {
	"m",
	"s"
}
ResPathSupport.ConstPath.Ship.Rarity.GetRole = "ui/getrole_%s%s"
ResPathSupport.ConstPath.Ship.Rarity.GetRoleFixList = {
	"",
	"_1",
	"_2"
}
ResPathSupport.ConstPath.Ship.Nation = {}
ResPathSupport.ConstPath.Ship.Nation.Prints = "prints/%s%s"
ResPathSupport.ConstPath.Ship.Nation.PrintsFixList = {
	"_0"
}
ResPathSupport.ConstPath.Commander = {}
ResPathSupport.ConstPath.Commander.CommanderHrz = "commanderhrz"
ResPathSupport.ConstPath.Commander.CommanderSkillIcon = "commanderskillicon"
ResPathSupport.ConstPath.Equipment = {}
ResPathSupport.ConstPath.Equipment.Equip = "equips"
ResPathSupport.ConstPath.LevelMap = "levelmap"
ResPathSupport.ConstPath.ChapterPic = "chapter/pic"
ResPathSupport.ConstPath.Enemies = "enemies"
ResPathSupport.ConstPath.StrategyIcon = "strategyicon"
ResPathSupport.ConstPath.FurnitureIcon = "furnitureicon"
ResPathSupport.ConstPath.UI = {}
ResPathSupport.ConstPath.UI.Base = "ui"
ResPathSupport.ConstPath.UI.Atlas = "_atlas"
ResPathSupport.ConstPath.UI.LivingAreaCover = "livingareacover"
ResPathSupport.ConstPath.UI.ActivityBanner = "activitybanner"
ResPathSupport.ConstPath.UI.LinkButton = "linkbutton"
ResPathSupport.ConstPath.UI.ShipSkillIcon = "skillicon"
ResPathSupport.ConstPath.UI.Effect = "effect"
ResPathSupport.ConstPath.UI.ShipModelBuliding = "ui/shipmodelbuliding"
ResPathSupport.ConstPath.UI.BuildPainting = "ui/buildpainting"
ResPathSupport.ConstPath.UI.IconFrame = "iconframe"

function ResPathSupport.MergeLuaArr(...)
	local var_1_0 = {}

	for iter_1_0, iter_1_1 in pairs({
		...
	}) do
		if iter_1_1 then
			for iter_1_2 = 1, #iter_1_1 do
				var_1_0[#var_1_0 + 1] = iter_1_1[iter_1_2]
			end
		end
	end

	return var_1_0
end

function ResPathSupport:UniqueLuaArr()
	local var_2_0 = {}
	local var_2_1 = {}

	if self then
		for iter_2_0 = 1, #self do
			if self[iter_2_0] and self[iter_2_0] ~= "" and not var_2_1[self[iter_2_0]] then
				var_2_1[self[iter_2_0]] = true
				var_2_0[#var_2_0 + 1] = self[iter_2_0]
			end
		end
	end

	return var_2_0
end

function ResPathSupport.CombinePath(...)
	return table.concat({
		...
	}, "/")
end

function ResPathSupport.GetSoundResList(arg_4_0)
	local var_4_0 = {}

	if arg_4_0 and #arg_4_0 > 0 then
		_.each({
			var_0_0.ConstPath.Sound.Default,
			var_0_0.ConstPath.Sound.BGM
		}, function(arg_5_0)
			table.insert(var_4_0, string.format(arg_5_0, arg_4_0))
		end)
	end

	return var_4_0
end

function ResPathSupport.GetShipRarityBgList(arg_6_0)
	local var_6_0 = {
		pg.ship_data_statistics[arg_6_0].rarity,
		pg.ship_data_statistics[arg_6_0].rarity + 1
	}
	local var_6_1 = var_0_0.ConstPath.BG.ShipBGFixList
	local var_6_2 = {}

	_.each({
		var_0_0.ConstPath.BG.ShipRarityBG,
		var_0_0.ConstPath.BG.ShipRarityUI
	}, function(arg_7_0)
		_.each(var_6_0, function(arg_8_0)
			local var_8_0 = shipRarity2bgPrint(arg_8_0, false, false)

			_.each(var_6_1, function(arg_9_0)
				table.insert(var_6_2, string.lower(string.format(arg_7_0, var_8_0, arg_9_0)))
			end)
		end)
	end)
	_.each(var_6_0, function(arg_10_0)
		if arg_10_0 > 2 then
			table.insert(var_6_2, string.lower(string.format(var_0_0.ConstPath.BG.ShipRarityEffect, arg_10_0 - 1)))
		end
	end)

	return var_6_2
end

function ResPathSupport.GetShipSkinBgList(arg_11_0)
	local var_11_0 = {
		pg.ship_skin_template[arg_11_0].bg_sp,
		pg.ship_skin_template[arg_11_0].bg,
		pg.ship_skin_template[arg_11_0].rarity_bg
	}
	local var_11_1 = {}

	_.each({
		var_0_0.ConstPath.BG.ShipRarityBG,
		var_0_0.ConstPath.BG.ShipRarityUI
	}, function(arg_12_0)
		_.each(var_11_0, function(arg_13_0)
			if arg_13_0 and #arg_13_0 > 0 then
				table.insert(var_11_1, string.lower(string.format(arg_12_0, arg_13_0, "")))
			end
		end)
	end)

	return var_11_1
end

function ResPathSupport.GetSkillIconList(arg_14_0)
	local var_14_0 = var_0_0.ConstPath.UI.ShipSkillIcon
	local var_14_1 = {}

	_.each(pg.ship_data_template[arg_14_0].buff_list_display, function(arg_15_0)
		local var_15_0 = tostring(getSkillConfig(arg_15_0).icon)

		if var_15_0 and #var_15_0 > 0 then
			table.insert(var_14_1, (string.lower((var_0_0.CombinePath(var_14_0, var_15_0)))))
		end
	end)

	return var_14_1
end

function ResPathSupport.GetSpineCharListByPrefabName(arg_16_0)
	local var_16_0 = var_0_0.ConstPath.SpineChar.Base
	local var_16_1 = {}

	if arg_16_0 and #arg_16_0 > 0 then
		_.each(var_0_0.ConstPath.SpineChar.FixList, function(arg_17_0)
			table.insert(var_16_1, string.lower(string.format(var_16_0, arg_16_0, arg_17_0)))
		end)
	end

	return var_16_1
end

function ResPathSupport.GetSpineQIconListByPrefabName(arg_18_0)
	local var_18_0 = var_0_0.ConstPath.SpineQIcon.Base
	local var_18_1 = {}

	if arg_18_0 and #arg_18_0 > 0 then
		_.each(var_0_0.ConstPath.SpineQIcon.FixList, function(arg_19_0)
			table.insert(var_18_1, string.lower(string.format(var_18_0, arg_18_0, arg_19_0)))
		end)
	end

	return var_18_1
end

function ResPathSupport.GetSpineModelsByPrefabName(arg_20_0)
	local var_20_0 = var_0_0.ConstPath.SpineModel.Base
	local var_20_1 = {}

	if arg_20_0 and #arg_20_0 > 0 then
		_.each(var_0_0.ConstPath.SpineModel.FixList, function(arg_21_0)
			table.insert(var_20_1, string.lower(string.format(var_20_0, arg_20_0, arg_21_0)))
		end)
	end

	return var_20_1
end

function ResPathSupport.GetPaintingListByPaintingName(arg_22_0)
	local var_22_0 = var_0_0.ConstPath.Painting.Base
	local var_22_1 = {}

	if arg_22_0 and #arg_22_0 > 0 then
		_.each(var_0_0.ConstPath.Painting.FixList, function(arg_23_0)
			table.insert(var_22_1, (string.lower(string.format(var_22_0, arg_22_0, arg_23_0))))
		end)
	end

	return var_22_1
end

function ResPathSupport.GetShopPaintingListByPaintingName(arg_24_0)
	local var_24_0 = var_0_0.ConstPath.Painting.Base
	local var_24_1 = {}

	if arg_24_0 and #arg_24_0 > 0 then
		_.each(var_0_0.ConstPath.Painting.ShopFixList, function(arg_25_0)
			table.insert(var_24_1, (string.lower(string.format(var_24_0, arg_24_0, arg_25_0))))
		end)
	end

	return var_24_1
end

function ResPathSupport.GetPaintingFaceListByPaintingName(arg_26_0)
	local var_26_0 = var_0_0.ConstPath.PaintingFace.Base
	local var_26_1 = {}

	if arg_26_0 and #arg_26_0 > 0 then
		_.each(var_0_0.ConstPath.PaintingFace.FixList, function(arg_27_0)
			table.insert(var_26_1, string.lower(string.format(var_26_0, arg_26_0, arg_27_0)))
		end)
	end

	return var_26_1
end

function ResPathSupport.GetPaintingShipYardIconListByPaintingName(arg_28_0)
	local var_28_0 = var_0_0.ConstPath.PaintingShipYardIcon.Base
	local var_28_1 = {}

	if arg_28_0 and #arg_28_0 > 0 then
		_.each(var_0_0.ConstPath.PaintingShipYardIcon.FixList, function(arg_29_0)
			table.insert(var_28_1, string.lower(string.format(var_28_0, arg_28_0, arg_29_0)))
		end)
	end

	return var_28_1
end

function ResPathSupport.GetPaintingSquareIconListByPaintingName(arg_30_0)
	local var_30_0 = var_0_0.ConstPath.PaintingSquareIcon.Base
	local var_30_1 = {}

	if arg_30_0 and #arg_30_0 > 0 then
		_.each(var_0_0.ConstPath.PaintingSquareIcon.FixList, function(arg_31_0)
			table.insert(var_30_1, string.lower(string.format(var_30_0, arg_30_0, arg_31_0)))
		end)
	end

	return var_30_1
end

function ResPathSupport.GetPaintingHeroHrzIconListByPaintingName(arg_32_0)
	local var_32_0 = var_0_0.ConstPath.PaintingHeroHrzIcon.Base
	local var_32_1 = {}

	if arg_32_0 and #arg_32_0 > 0 then
		_.each(var_0_0.ConstPath.PaintingHeroHrzIcon.FixList, function(arg_33_0)
			table.insert(var_32_1, string.lower(string.format(var_32_0, arg_32_0, arg_33_0)))
		end)
	end

	return var_32_1
end

function ResPathSupport.GetShipSkinPaintingList(arg_34_0)
	return var_0_0.GetPaintingListByPaintingName(pg.ship_skin_template[arg_34_0].painting)
end

function ResPathSupport.GetShipSkinPaintingFaceList(arg_35_0)
	return var_0_0.GetPaintingFaceListByPaintingName(pg.ship_skin_template[arg_35_0].painting)
end

function ResPathSupport.GetShipSkinPaintingShipYardIconList(arg_36_0)
	return var_0_0.GetPaintingShipYardIconListByPaintingName(pg.ship_skin_template[arg_36_0].painting)
end

function ResPathSupport.GetShipSkinPaintingSquareIconList(arg_37_0)
	return var_0_0.GetPaintingSquareIconListByPaintingName(pg.ship_skin_template[arg_37_0].painting)
end

function ResPathSupport.GetShipSkinPaintingHeroHrzIconList(arg_38_0)
	return var_0_0.GetPaintingHeroHrzIconListByPaintingName(pg.ship_skin_template[arg_38_0].painting)
end

function ResPathSupport.GetShipSkinSpineQIconList(arg_39_0)
	local var_39_0 = var_0_0.ConstPath.SpineQIcon.Base
	local var_39_1 = pg.ship_skin_template[arg_39_0].painting
	local var_39_2 = {}

	_.each(var_0_0.ConstPath.SpineQIcon.FixList, function(arg_40_0)
		table.insert(var_39_2, string.format(var_39_0, var_39_1, arg_40_0))
	end)

	return var_39_2
end

function ResPathSupport.GetShipSkinSpineShipModelList(arg_41_0)
	local var_41_0 = var_0_0.ConstPath.SpineModel.Base
	local var_41_1 = pg.ship_skin_template[arg_41_0].painting
	local var_41_2 = {}

	_.each(var_0_0.ConstPath.SpineModel.FixList, function(arg_42_0)
		table.insert(var_41_2, string.format(var_41_0, var_41_1, arg_42_0))
	end)

	return var_41_2
end

function ResPathSupport.GetShipSkinSpineCharList(arg_43_0)
	local var_43_0 = var_0_0.ConstPath.SpineChar.Base
	local var_43_1 = pg.ship_skin_template[arg_43_0].painting
	local var_43_2 = {}

	_.each(var_0_0.ConstPath.SpineChar.FixList, function(arg_44_0)
		table.insert(var_43_2, string.format(var_43_0, var_43_1, arg_44_0))
	end)

	return var_43_2
end

function ResPathSupport.GetShipSkinLive2DListByPaintingName(arg_45_0)
	local var_45_0 = var_0_0.ConstPath.Live2D.Base
	local var_45_1 = {}

	if arg_45_0 and #arg_45_0 > 0 then
		_.each(var_0_0.ConstPath.Live2D.FixList, function(arg_46_0)
			table.insert(var_45_1, string.format(var_45_0, arg_45_0, arg_46_0))
		end)
	end

	return var_45_1
end

function ResPathSupport.GetShipSkinLive2DList(arg_47_0)
	return var_0_0.GetShipSkinLive2DListByPaintingName(pg.ship_skin_template[arg_47_0].painting)
end

function ResPathSupport.GetShipSkinSpinePaintingList(arg_48_0)
	local var_48_0 = var_0_0.ConstPath.SpinePainting.Base
	local var_48_1 = pg.ship_skin_template[arg_48_0].painting
	local var_48_2 = {}

	_.each(var_0_0.ConstPath.SpinePainting.FixList, function(arg_49_0)
		table.insert(var_48_2, string.format(var_48_0, var_48_1, arg_49_0))
	end)

	return var_48_2
end

function ResPathSupport.GetShipSkinEffectList(arg_50_0)
	local var_50_0 = {}

	if pg.ship_skin_template[arg_50_0].special_effects and #pg.ship_skin_template[arg_50_0].special_effects > 0 then
		table.insert(var_50_0, var_0_0.CombinePath(var_0_0.ConstPath.UI.Base, pg.ship_skin_template[arg_50_0].special_effects[1]))
	end

	return var_50_0
end

function ResPathSupport.GetShipSkinSoundList(arg_51_0)
	return (pg.ship_skin_template[arg_51_0].bgm and #pg.ship_skin_template[arg_51_0].bgm > 0 or nil) and var_0_0.GetSoundResList(pg.ship_skin_template[arg_51_0].bgm)
end

function ResPathSupport:GetShipAllRes()
	local var_52_0 = self:getSkinId()

	return (var_0_0.MergeLuaArr({
		"spinematerials",
		"ui/lihui_qiehuan01",
		"ui/lihui_qiehuan02",
		"effect/jiehuntexiao"
	}, var_0_0.GetShipRarityBgList(self.configId), var_0_0.GetShipSkinBgList(var_52_0), var_0_0.GetSkillIconList(self.configId), var_0_0.GetShipSkinSoundList(var_52_0), var_0_0.GetShipSkinSpineQIconList(var_52_0), var_0_0.GetShipSkinSpineShipModelList(var_52_0), var_0_0.GetShipSkinSpineCharList(var_52_0), var_0_0.GetShipSkinSpinePaintingList(var_52_0), var_0_0.GetShipSkinPaintingList(var_52_0), var_0_0.GetShipSkinPaintingFaceList(var_52_0), var_0_0.GetShipSkinPaintingShipYardIconList(var_52_0), var_0_0.GetShipSkinPaintingSquareIconList(var_52_0), var_0_0.GetShipSkinPaintingHeroHrzIconList(var_52_0), (var_0_0.GetShipSkinEffectList(var_52_0))))
end
