Buff_320_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_320_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_320_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_320_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e320")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sdsg" )
	end,

	sdsg = function( effectScript )
			AttachBuffEffect( false, Buff_320_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 20), 1.2, 100, "e320",  effectScript)
	end,

}
