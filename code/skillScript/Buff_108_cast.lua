Buff_108_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_108_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_108_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_108_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e108")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fd" )
	end,

	fd = function( effectScript )
			AttachBuffEffect( false, Buff_108_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "e108",  effectScript)
	end,

}
