Buff_109_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_109_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_109_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_109_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e109")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sad" )
	end,

	sad = function( effectScript )
			AttachBuffEffect( false, Buff_109_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "e109",  effectScript)
	end,

}
