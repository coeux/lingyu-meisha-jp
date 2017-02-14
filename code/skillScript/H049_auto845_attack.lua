H049_auto845_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H049_auto845_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H049_auto845_attack.info_pool[effectScript.ID].Attacker)
        
		H049_auto845_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_04902")
		PreLoadAvatar("H049_g1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ffwfwfwfwf" )
		effectScript:RegisterEvent( 20, "iujyhry4" )
		effectScript:RegisterEvent( 38, "rgrege" )
	end,

	ffwfwfwfwf = function( effectScript )
		SetAnimation(H049_auto845_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("skill_04902")
	end,

	iujyhry4 = function( effectScript )
		AttachAvatarPosEffect(false, H049_auto845_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(400, 100), 3, 100, "H049_g1")
	end,

	rgrege = function( effectScript )
			DamageEffect(H049_auto845_attack.info_pool[effectScript.ID].Attacker, H049_auto845_attack.info_pool[effectScript.ID].Targeter, H049_auto845_attack.info_pool[effectScript.ID].AttackType, H049_auto845_attack.info_pool[effectScript.ID].AttackDataList, H049_auto845_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
