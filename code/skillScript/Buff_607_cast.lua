Buff_607_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_607_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		BuffEffectScriptEnd( effectScript )
		Buff_607_cast.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S607")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "A" )
	end,

	A = function( effectScript )
		AttachBuffEffect( false, Buff_607_cast.info_pool[effectScript.ID].Targeter, AvatarPos.head, Vector2(0, 0), 1, 100, "S607",  effectScript)
	end,

}
