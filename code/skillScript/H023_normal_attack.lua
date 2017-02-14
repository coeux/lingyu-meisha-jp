H023_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H023_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H023_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H023_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("mao_pugong")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dongzuo" )
		effectScript:RegisterEvent( 24, "asfdsg" )
		effectScript:RegisterEvent( 25, "jj" )
	end,

	dongzuo = function( effectScript )
		SetAnimation(H023_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	asfdsg = function( effectScript )
		AttachAvatarPosEffect(false, H023_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 80), 1.5, 100, "mao_pugong")
	end,

	jj = function( effectScript )
			DamageEffect(H023_normal_attack.info_pool[effectScript.ID].Attacker, H023_normal_attack.info_pool[effectScript.ID].Targeter, H023_normal_attack.info_pool[effectScript.ID].AttackType, H023_normal_attack.info_pool[effectScript.ID].AttackDataList, H023_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
