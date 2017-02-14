Buff_608_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_608_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		BuffEffectScriptEnd( effectScript )
		Buff_608_cast.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S608")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "AS" )
	end,

	AS = function( effectScript )
		AttachBuffEffect( false, Buff_608_cast.info_pool[effectScript.ID].Targeter, AvatarPos.head, Vector2(0, 0), 1, 100, "S608",  effectScript)
	end,

}
