P101_auto424_attack = 
{
	info_pool = {},

	init = function( effectScript )
		P101_auto424_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P101_auto424_attack.info_pool[effectScript.ID].Attacker)
        
		P101_auto424_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S420_2")
		PreLoadAvatar("S420_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsfsdg" )
		effectScript:RegisterEvent( 18, "sfdg" )
		effectScript:RegisterEvent( 35, "ddddgf" )
		effectScript:RegisterEvent( 36, "dsgfdh" )
	end,

	dsfsdg = function( effectScript )
		SetAnimation(P101_auto424_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	sfdg = function( effectScript )
		AttachAvatarPosEffect(false, P101_auto424_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-90, 110), 1.5, 100, "S420_2")
	end,

	ddddgf = function( effectScript )
		AttachAvatarPosEffect(false, P101_auto424_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.2, 100, "S420_1")
	end,

	dsgfdh = function( effectScript )
			DamageEffect(P101_auto424_attack.info_pool[effectScript.ID].Attacker, P101_auto424_attack.info_pool[effectScript.ID].Targeter, P101_auto424_attack.info_pool[effectScript.ID].AttackType, P101_auto424_attack.info_pool[effectScript.ID].AttackDataList, P101_auto424_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}