S943_magic_H059_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S943_magic_H059_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S943_magic_H059_attack.info_pool[effectScript.ID].Attacker)
        
		S943_magic_H059_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_05901")
		PreLoadSound("skill_05902")
		PreLoadAvatar("H059_4_1")
		PreLoadAvatar("H059_4_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "hvv" )
		effectScript:RegisterEvent( 18, "vr" )
		effectScript:RegisterEvent( 20, "JK" )
	end,

	hvv = function( effectScript )
		SetAnimation(S943_magic_H059_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_05901")
		PlaySound("skill_05902")
	end,

	vr = function( effectScript )
		AttachAvatarPosEffect(false, S943_magic_H059_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(40, 80), 1.4, 100, "H059_4_1")
	AttachAvatarPosEffect(false, S943_magic_H059_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(-30, -10), 1.6, 100, "H059_4_2")
	end,

	JK = function( effectScript )
			DamageEffect(S943_magic_H059_attack.info_pool[effectScript.ID].Attacker, S943_magic_H059_attack.info_pool[effectScript.ID].Targeter, S943_magic_H059_attack.info_pool[effectScript.ID].AttackType, S943_magic_H059_attack.info_pool[effectScript.ID].AttackDataList, S943_magic_H059_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
