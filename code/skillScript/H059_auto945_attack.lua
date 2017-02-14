H059_auto945_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H059_auto945_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H059_auto945_attack.info_pool[effectScript.ID].Attacker)
        
		H059_auto945_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_05903")
		PreLoadSound("stalk_05901")
		PreLoadAvatar("H059_4_1")
		PreLoadAvatar("H059_3_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "hvv" )
		effectScript:RegisterEvent( 18, "vr" )
		effectScript:RegisterEvent( 28, "JK" )
	end,

	hvv = function( effectScript )
		SetAnimation(H059_auto945_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("skill_05903")
		PlaySound("stalk_05901")
	end,

	vr = function( effectScript )
		AttachAvatarPosEffect(false, H059_auto945_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(40, 80), 1.4, 100, "H059_4_1")
	AttachAvatarPosEffect(false, H059_auto945_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -10), 1.4, 100, "H059_3_1")
	end,

	JK = function( effectScript )
			DamageEffect(H059_auto945_attack.info_pool[effectScript.ID].Attacker, H059_auto945_attack.info_pool[effectScript.ID].Targeter, H059_auto945_attack.info_pool[effectScript.ID].AttackType, H059_auto945_attack.info_pool[effectScript.ID].AttackDataList, H059_auto945_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
