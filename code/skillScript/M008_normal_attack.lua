M008_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M008_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M008_normal_attack.info_pool[effectScript.ID].Attacker)
        
		M008_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("gs0081")
		PreLoadAvatar("M008_daoguang")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ads" )
		effectScript:RegisterEvent( 22, "sdfgdgh" )
		effectScript:RegisterEvent( 26, "dsfdg" )
	end,

	ads = function( effectScript )
		SetAnimation(M008_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("gs0081")
	end,

	sdfgdgh = function( effectScript )
		AttachAvatarPosEffect(false, M008_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, -10), 1.5, 100, "M008_daoguang")
	end,

	dsfdg = function( effectScript )
			DamageEffect(M008_normal_attack.info_pool[effectScript.ID].Attacker, M008_normal_attack.info_pool[effectScript.ID].Targeter, M008_normal_attack.info_pool[effectScript.ID].AttackType, M008_normal_attack.info_pool[effectScript.ID].AttackDataList, M008_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
