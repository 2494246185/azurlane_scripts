local SpinePaintingDrag = class("SpinePaintingDrag")
local var_0_1 = "spine_painting_idle_init_"
local var_0_2 = "spine_painting_skin_init_"
local var_0_3 = "spine_painting_lite_"

function SpinePaintingDrag:SetPaintingInitIdle(arg_1_1, arg_1_2)
	PlayerPrefs.SetString(var_0_1 .. tostring(self) .. tostring(arg_1_1), arg_1_2)
end

function SpinePaintingDrag:GetPaintingInitIdle(arg_2_1)
	local var_2_0 = PlayerPrefs.GetString(var_0_1 .. tostring(self) .. tostring(arg_2_1))

	if var_2_0 and #var_2_0 > 0 then
		return var_2_0
	end

	return nil
end

function SpinePaintingDrag:SetPaintingInitSkin(arg_3_1, arg_3_2)
	PlayerPrefs.SetString(var_0_2 .. tostring(self) .. tostring(arg_3_1), arg_3_2)
end

function SpinePaintingDrag:GetPaintingInitSkin(arg_4_1)
	local var_4_0 = PlayerPrefs.GetString(var_0_2 .. tostring(self) .. tostring(arg_4_1))

	if var_4_0 and #var_4_0 > 0 then
		return var_4_0
	end

	return nil
end

function SpinePaintingDrag:SetPaintingLite(arg_5_1, arg_5_2)
	PlayerPrefs.SetFloat(var_0_3 .. tostring(self) .. "_" .. tostring(arg_5_1), arg_5_2)
end

function SpinePaintingDrag:GetPaintingLite(arg_6_1)
	local var_6_0 = PlayerPrefs.GetFloat(var_0_3 .. tostring(self) .. "_" .. tostring(arg_6_1))

	if var_6_0 and var_6_0 >= 0 then
		return var_6_0
	end

	return 0.5
end

return SpinePaintingDrag
