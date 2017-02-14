Buff_316_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_316_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_316_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_316_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e316")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "adas" )
	end,

	adas = function( effectScript )
			AttachBuffEffect( false, Buff_316_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "e316",  effectScript)
	end,

}
