H019_auto415_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H019_auto415_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H019_auto415_attack.info_pool[effectScript.ID].Attacker)
        
		H019_auto415_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_01902")
		PreLoadSound("stalk_01901")
		PreLoadAvatar("H019_xuli")
		PreLoadSound("skill_01901")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfgfhgfh" )
		effectScript:RegisterEvent( 4, "dgfhj" )
		effectScript:RegisterEvent( 14, "dsgfhjj" )
		effectScript:RegisterEvent( 23, "sfgdh" )
	end,

	dfgfhgfh = function( effectScript )
		SetAnimation(H019_auto415_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	dgfhj = function( effectScript )
			PlaySound("skill_01902")
		PlaySound("stalk_01901")
	end,

	dsgfhjj = function( effectScript )
		AttachAvatarPosEffect(false, H019_auto415_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 50), 0.8, 100, "H019_xuli")
	end,

	sfgdh = function( effectScript )
			PlaySound("skill_01901")
	end,

}
