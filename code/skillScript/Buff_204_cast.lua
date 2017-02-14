Buff_204_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_204_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_204_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_204_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e204")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "adsf" )
	end,

	adsf = function( effectScript )
			AttachBuffEffect( false, Buff_204_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 20), 1.2, 100, "e204",  effectScript)
	end,

}
