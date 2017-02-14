Buff_208_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_208_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_208_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_208_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e208")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sds" )
	end,

	sds = function( effectScript )
			AttachBuffEffect( false, Buff_208_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "e208",  effectScript)
	end,

}
