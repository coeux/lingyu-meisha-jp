H023_auto225_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H023_auto225_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H023_auto225_attack.info_pool[effectScript.ID].Attacker)
        
		H023_auto225_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s0234")
		PreLoadAvatar("S220")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 9, "asfdf" )
		effectScript:RegisterEvent( 31, "q" )
	end,

	a = function( effectScript )
		SetAnimation(H023_auto225_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("s0234")
	end,

	asfdf = function( effectScript )
		AttachAvatarPosEffect(false, H023_auto225_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(230, 30), 3, 100, "S220")
	end,

	q = function( effectScript )
			DamageEffect(H023_auto225_attack.info_pool[effectScript.ID].Attacker, H023_auto225_attack.info_pool[effectScript.ID].Targeter, H023_auto225_attack.info_pool[effectScript.ID].AttackType, H023_auto225_attack.info_pool[effectScript.ID].AttackDataList, H023_auto225_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
