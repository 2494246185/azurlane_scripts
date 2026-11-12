local Fushun3GameVo = class("Fushun3GameVo")

Fushun3GameVo.TimeType = Fushun3GameConst.day_type
Fushun3GameVo.TimeFlag = true

function Fushun3GameVo:ChangeTimeType()
	Fushun3GameVo.TimeType = self

	Fushun3GameVo.SetTimeFlag((Fushun3GameVo.TimeType == Fushun3GameConst.day_type or Fushun3GameVo.TimeType == Fushun3GameConst.sunset_type) and true or false)
end

function Fushun3GameVo.GetTimeTypeData()
	return Clone(Fushun3GameConst.time_data[Fushun3GameVo.TimeType])
end

function Fushun3GameVo:SetTimeFlag()
	Fushun3GameVo.TimeFlag = self
end

function Fushun3GameVo.GetTimeFlag()
	return Fushun3GameVo.TimeFlag
end

function Fushun3GameVo.Clear()
	if Fushun3GameVo.TypeType == Fushun3GameConst.sunset_type then
		Fushun3GameVo.ChangeTimeType(Fushun3GameConst.day_type)
	end
end

return Fushun3GameVo
