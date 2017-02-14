Buff_313_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_313_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_313_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_313_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e313")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "cdv" )
	end,

	cdv = function( effectScript )
			AttachBuffEffect( false, Buff_313_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "e313",  effectScript)
	end,

}
