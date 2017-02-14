H026_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H026_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H026_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H026_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H026_pugong_1")
		PreLoadAvatar("H026_pugong_3")
		PreLoadAvatar("H026_pugong_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "gfjjhk" )
		effectScript:RegisterEvent( 15, "dgvfdh" )
		effectScript:RegisterEvent( 24, "dcsfdh" )
		effectScript:RegisterEvent( 28, "dsgdhj" )
		effectScript:RegisterEvent( 30, "dsgdh" )
	end,

	gfjjhk = function( effectScript )
		SetAnimation(H026_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	dgvfdh = function( effectScript )
		AttachAvatarPosEffect(false, H026_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 35), 1, 100, "H026_pugong_1")
	end,

	dcsfdh = function( effectScript )
		AttachAvatarPosEffect(false, H026_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 120), 1.2, 100, "H026_pugong_3")
	end,

	dsgdhj = function( effectScript )
		AttachAvatarPosEffect(false, H026_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 2, 100, "H026_pugong_2")
	end,

	dsgdh = function( effectScript )
			DamageEffect(H026_normal_attack.info_pool[effectScript.ID].Attacker, H026_normal_attack.info_pool[effectScript.ID].Targeter, H026_normal_attack.info_pool[effectScript.ID].AttackType, H026_normal_attack.info_pool[effectScript.ID].AttackDataList, H026_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
