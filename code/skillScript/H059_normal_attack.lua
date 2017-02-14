H059_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H059_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H059_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H059_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_05901")
		PreLoadSound("attack_05901")
		PreLoadAvatar("H059_2_1")
		PreLoadAvatar("H059_2_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfg" )
		effectScript:RegisterEvent( 22, "gh" )
		effectScript:RegisterEvent( 23, "kli" )
		effectScript:RegisterEvent( 25, "hbr" )
	end,

	dfg = function( effectScript )
		SetAnimation(H059_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("atalk_05901")
		PlaySound("attack_05901")
	end,

	gh = function( effectScript )
		AttachAvatarPosEffect(false, H059_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(30, -10), 1.2, 100, "H059_2_1")
	end,

	kli = function( effectScript )
		AttachAvatarPosEffect(false, H059_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "H059_2_2")
	end,

	hbr = function( effectScript )
			DamageEffect(H059_normal_attack.info_pool[effectScript.ID].Attacker, H059_normal_attack.info_pool[effectScript.ID].Targeter, H059_normal_attack.info_pool[effectScript.ID].AttackType, H059_normal_attack.info_pool[effectScript.ID].AttackDataList, H059_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
