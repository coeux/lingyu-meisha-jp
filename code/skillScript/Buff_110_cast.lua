Buff_110_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_110_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_110_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_110_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e110")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sdf" )
	end,

	sdf = function( effectScript )
			AttachBuffEffect( false, Buff_110_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "e110",  effectScript)
	end,

}
