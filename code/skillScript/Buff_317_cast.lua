Buff_317_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_317_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_317_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_317_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e317")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "safg" )
	end,

	safg = function( effectScript )
			AttachBuffEffect( false, Buff_317_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.2, 100, "e317",  effectScript)
	end,

}
