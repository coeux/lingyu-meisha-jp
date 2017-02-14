H016_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H016_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H016_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H016_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_01601")
		PreLoadAvatar("H016_pugong_1")
		PreLoadAvatar("H016_pugong_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aasgaf" )
		effectScript:RegisterEvent( 17, "sfdh" )
		effectScript:RegisterEvent( 20, "addf" )
		effectScript:RegisterEvent( 21, "gfjh" )
		effectScript:RegisterEvent( 23, "adada" )
		effectScript:RegisterEvent( 24, "zxvadf" )
	end,

	aasgaf = function( effectScript )
		SetAnimation(H016_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	sfdh = function( effectScript )
		PlaySound("atalk_01601")
	end,

	addf = function( effectScript )
		AttachAvatarPosEffect(false, H016_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 60), 2, 100, "H016_pugong_1")
	end,

	gfjh = function( effectScript )
	end,

	adada = function( effectScript )
		AttachAvatarPosEffect(false, H016_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2, 100, "H016_pugong_2")
	end,

	zxvadf = function( effectScript )
			DamageEffect(H016_normal_attack.info_pool[effectScript.ID].Attacker, H016_normal_attack.info_pool[effectScript.ID].Targeter, H016_normal_attack.info_pool[effectScript.ID].AttackType, H016_normal_attack.info_pool[effectScript.ID].AttackDataList, H016_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
