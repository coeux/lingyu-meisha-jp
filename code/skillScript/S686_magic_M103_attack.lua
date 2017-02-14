S686_magic_M103_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S686_magic_M103_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S686_magic_M103_attack.info_pool[effectScript.ID].Attacker)
        
		S686_magic_M103_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S576_4")
		PreLoadAvatar("S576_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dcdfd" )
		effectScript:RegisterEvent( 12, "hgfhj" )
		effectScript:RegisterEvent( 22, "sfdsf" )
		effectScript:RegisterEvent( 26, "dsfg" )
	end,

	dcdfd = function( effectScript )
		SetAnimation(S686_magic_M103_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	hgfhj = function( effectScript )
		AttachAvatarPosEffect(false, S686_magic_M103_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-60, 300), 1, 100, "S576_4")
	end,

	sfdsf = function( effectScript )
		AttachAvatarPosEffect(false, S686_magic_M103_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 20), 1.5, 100, "S576_2")
	end,

	dsfg = function( effectScript )
			DamageEffect(S686_magic_M103_attack.info_pool[effectScript.ID].Attacker, S686_magic_M103_attack.info_pool[effectScript.ID].Targeter, S686_magic_M103_attack.info_pool[effectScript.ID].AttackType, S686_magic_M103_attack.info_pool[effectScript.ID].AttackDataList, S686_magic_M103_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
