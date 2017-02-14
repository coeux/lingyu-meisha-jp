H049_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H049_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H049_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H049_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("attack_04902")
		PreLoadAvatar("H049_pg1")
		PreLoadAvatar("H049_pg2")
		PreLoadSound("attack_04901")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "hrthlkthre" )
		effectScript:RegisterEvent( 7, "yryhthrth" )
		effectScript:RegisterEvent( 18, "grhythtyh" )
		effectScript:RegisterEvent( 21, "tgyh" )
	end,

	hrthlkthre = function( effectScript )
		SetAnimation(H049_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("attack_04902")
	end,

	yryhthrth = function( effectScript )
		AttachAvatarPosEffect(false, H049_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 150), 2, 100, "H049_pg1")
	end,

	grhythtyh = function( effectScript )
		AttachAvatarPosEffect(false, H049_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 0), 2, 100, "H049_pg2")
		PlaySound("attack_04901")
	end,

	tgyh = function( effectScript )
			DamageEffect(H049_normal_attack.info_pool[effectScript.ID].Attacker, H049_normal_attack.info_pool[effectScript.ID].Targeter, H049_normal_attack.info_pool[effectScript.ID].AttackType, H049_normal_attack.info_pool[effectScript.ID].AttackDataList, H049_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
