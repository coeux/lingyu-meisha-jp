H046_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H046_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H046_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H046_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H046_pugong_1")
		PreLoadSound("attack_04601")
		PreLoadAvatar("H046_pugong_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dongzuo" )
		effectScript:RegisterEvent( 17, "sefdgh" )
		effectScript:RegisterEvent( 19, "fdsfdhh" )
		effectScript:RegisterEvent( 21, "shanghai" )
	end,

	dongzuo = function( effectScript )
		SetAnimation(H046_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	sefdgh = function( effectScript )
		AttachAvatarPosEffect(false, H046_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 75), 2, 100, "H046_pugong_1")
		PlaySound("attack_04601")
	end,

	fdsfdhh = function( effectScript )
		AttachAvatarPosEffect(false, H046_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), -1.5, 100, "H046_pugong_2")
	end,

	shanghai = function( effectScript )
			DamageEffect(H046_normal_attack.info_pool[effectScript.ID].Attacker, H046_normal_attack.info_pool[effectScript.ID].Targeter, H046_normal_attack.info_pool[effectScript.ID].AttackType, H046_normal_attack.info_pool[effectScript.ID].AttackDataList, H046_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
