Buff_613_fire = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_613_fire.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		BuffEffectScriptEnd( effectScript )
		Buff_613_fire.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S613")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "SA" )
	end,

	SA = function( effectScript )
		AttachBuffEffect( true, Buff_613_fire.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S613",  effectScript)
	end,

}
