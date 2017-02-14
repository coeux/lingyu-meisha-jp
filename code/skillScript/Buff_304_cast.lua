Buff_304_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_304_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_304_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_304_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e304")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "awrff" )
	end,

	awrff = function( effectScript )
			AttachBuffEffect( false, Buff_304_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 20), 1.2, 100, "e304",  effectScript)
	end,

}
