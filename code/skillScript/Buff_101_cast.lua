Buff_101_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_101_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_101_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_101_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e101")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sf" )
	end,

	sf = function( effectScript )
			AttachBuffEffect( false, Buff_101_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 20), 1.2, 100, "e101",  effectScript)
	end,

}
