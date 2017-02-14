S860_magic_H051_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S860_magic_H051_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S860_magic_H051_attack.info_pool[effectScript.ID].Attacker)
        
		S860_magic_H051_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_05103")
		PreLoadAvatar("H051_3_1")
		PreLoadSound("stalk_05101")
		PreLoadAvatar("H051_3_2")
		PreLoadSound("skill_05104")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dcsv" )
		effectScript:RegisterEvent( 9, "drfv" )
		effectScript:RegisterEvent( 35, "gcv" )
		effectScript:RegisterEvent( 37, "xs" )
	end,

	dcsv = function( effectScript )
		SetAnimation(S860_magic_H051_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("skill_05103")
	end,

	drfv = function( effectScript )
		AttachAvatarPosEffect(false, S860_magic_H051_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1.4, 100, "H051_3_1")
		PlaySound("stalk_05101")
	end,

	gcv = function( effectScript )
		AttachAvatarPosEffect(false, S860_magic_H051_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 90), 1.7, 100, "H051_3_2")
		PlaySound("skill_05104")
	end,

	xs = function( effectScript )
			DamageEffect(S860_magic_H051_attack.info_pool[effectScript.ID].Attacker, S860_magic_H051_attack.info_pool[effectScript.ID].Targeter, S860_magic_H051_attack.info_pool[effectScript.ID].AttackType, S860_magic_H051_attack.info_pool[effectScript.ID].AttackDataList, S860_magic_H051_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
