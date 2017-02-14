Buff_112_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_112_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_112_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_112_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e112")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ads" )
	end,

	ads = function( effectScript )
			AttachBuffEffect( false, Buff_112_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "e112",  effectScript)
	end,

}
