M103_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M103_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M103_normal_attack.info_pool[effectScript.ID].Attacker)
        
		M103_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("M103_pugong_1")
		PreLoadAvatar("M103_pugong_2")
		PreLoadAvatar("M103_pugong_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sdf" )
		effectScript:RegisterEvent( 27, "sadsf" )
		effectScript:RegisterEvent( 29, "safdf" )
		effectScript:RegisterEvent( 34, "csdfdf" )
		effectScript:RegisterEvent( 35, "fdsdgh" )
	end,

	sdf = function( effectScript )
		SetAnimation(M103_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	sadsf = function( effectScript )
		AttachAvatarPosEffect(false, M103_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 30), 1.5, 100, "M103_pugong_1")
	end,

	safdf = function( effectScript )
		AttachAvatarPosEffect(false, M103_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 0), 1.5, 100, "M103_pugong_2")
	end,

	csdfdf = function( effectScript )
		AttachAvatarPosEffect(false, M103_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "M103_pugong_3")
	end,

	fdsdgh = function( effectScript )
			DamageEffect(M103_normal_attack.info_pool[effectScript.ID].Attacker, M103_normal_attack.info_pool[effectScript.ID].Targeter, M103_normal_attack.info_pool[effectScript.ID].AttackType, M103_normal_attack.info_pool[effectScript.ID].AttackDataList, M103_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
