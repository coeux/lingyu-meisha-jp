Buff_207_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_207_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_207_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_207_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e207")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sads" )
	end,

	sads = function( effectScript )
			AttachBuffEffect( false, Buff_207_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "e207",  effectScript)
	end,

}
