Buff_302_cast = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_302_cast.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_302_cast.info_pool[effectScript.ID].Attacker)
        
		Buff_302_cast.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e302")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "wff" )
	end,

	wff = function( effectScript )
			AttachBuffEffect( false, Buff_302_cast.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 20), 1.2, 100, "e302",  effectScript)
	end,

}
