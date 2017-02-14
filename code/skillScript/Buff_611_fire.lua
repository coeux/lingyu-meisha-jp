Buff_611_fire = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_611_fire.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		BuffEffectScriptEnd( effectScript )
		Buff_611_fire.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S611")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "A" )
	end,

	A = function( effectScript )
		AttachBuffEffect( true, Buff_611_fire.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S611",  effectScript)
	end,

}
