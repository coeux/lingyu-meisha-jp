Buff_514_fire = 
{
	info_pool = {},

	init = function( effectScript )
		Buff_514_fire.info_pool[effectScript.ID] = { Targeter = 0 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(Buff_514_fire.info_pool[effectScript.ID].Attacker)
        
		Buff_514_fire.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("e514")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfdf" )
	end,

	sfdf = function( effectScript )
			AttachBuffEffect( true, Buff_514_fire.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.5, 100, "e514",  effectScript)
	end,

}
