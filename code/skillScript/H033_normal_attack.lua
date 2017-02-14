H033_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H033_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H033_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H033_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_03301")
		PreLoadAvatar("H033_pugong")
		PreLoadSound("attack_03301")
		PreLoadAvatar("H033_pugong_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dongzuo" )
		effectScript:RegisterEvent( 24, "gfdhg" )
		effectScript:RegisterEvent( 25, "sfdhh" )
		effectScript:RegisterEvent( 27, "shanghai" )
	end,

	dongzuo = function( effectScript )
		SetAnimation(H033_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("stalk_03301")
	end,

	gfdhg = function( effectScript )
		AttachAvatarPosEffect(false, H033_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(90, 50), 1.8, 100, "H033_pugong")
		PlaySound("attack_03301")
	end,

	sfdhh = function( effectScript )
		AttachAvatarPosEffect(false, H033_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "H033_pugong_1")
	end,

	shanghai = function( effectScript )
			DamageEffect(H033_normal_attack.info_pool[effectScript.ID].Attacker, H033_normal_attack.info_pool[effectScript.ID].Targeter, H033_normal_attack.info_pool[effectScript.ID].AttackType, H033_normal_attack.info_pool[effectScript.ID].AttackDataList, H033_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
