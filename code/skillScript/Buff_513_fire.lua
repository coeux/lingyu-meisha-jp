Buff_513_fire = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_513_fire.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_513_fire.info_pool[effectScript.ID].Attacker)
        
		Buff_513_fire.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e513")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "e" )
	end,

	e = function( effectScript )
			AttachBuffEffect( true, Buff_513_fire.info_pool[effectScript.ID].Targeter, AvatarPos.head, Vector2(0, 0), 1, 100, "e513",  effectScript)
	end,

}
