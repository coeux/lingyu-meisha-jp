H040_auto755_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H040_auto755_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H040_auto755_attack.info_pool[effectScript.ID].Attacker)
        
		H040_auto755_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S752_1")
		PreLoadSound("skill_04001")
		PreLoadAvatar("S752_2")
		PreLoadSound("skill_04002")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dgfdhjhj" )
		effectScript:RegisterEvent( 15, "dgfdhjj" )
		effectScript:RegisterEvent( 41, "fhgfhj" )
		effectScript:RegisterEvent( 45, "fdgfjj" )
	end,

	dgfdhjhj = function( effectScript )
		SetAnimation(H040_auto755_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	dgfdhjj = function( effectScript )
		AttachAvatarPosEffect(false, H040_auto755_attack.info_pool[effectScript.ID].Attacker, AvatarPos.right_hand, Vector2(0, 150), 1, 100, "S752_1")
		PlaySound("skill_04001")
	end,

	fhgfhj = function( effectScript )
		AttachAvatarPosEffect(false, H040_auto755_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(50, 300), 1.5, 100, "S752_2")
		PlaySound("skill_04002")
	end,

	fdgfjj = function( effectScript )
			DamageEffect(H040_auto755_attack.info_pool[effectScript.ID].Attacker, H040_auto755_attack.info_pool[effectScript.ID].Targeter, H040_auto755_attack.info_pool[effectScript.ID].AttackType, H040_auto755_attack.info_pool[effectScript.ID].AttackDataList, H040_auto755_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
