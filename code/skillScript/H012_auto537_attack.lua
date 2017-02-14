H012_auto537_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H012_auto537_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H012_auto537_attack.info_pool[effectScript.ID].Attacker)
        
		H012_auto537_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01201")
		PreLoadAvatar("H012_xuli")
		PreLoadSound("skill_01201")
		PreLoadSound("")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfdh" )
		effectScript:RegisterEvent( 1, "fdhgj" )
		effectScript:RegisterEvent( 4, "dfghfh" )
		effectScript:RegisterEvent( 20, "dsgdh" )
		effectScript:RegisterEvent( 35, "grtfhgf" )
	end,

	dfdh = function( effectScript )
		SetAnimation(H012_auto537_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("stalk_01201")
	end,

	fdhgj = function( effectScript )
		AttachAvatarPosEffect(false, H012_auto537_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "H012_xuli")
	end,

	dfghfh = function( effectScript )
			PlaySound("skill_01201")
	end,

	dsgdh = function( effectScript )
			PlaySound("")
	end,

	grtfhgf = function( effectScript )
			DamageEffect(H012_auto537_attack.info_pool[effectScript.ID].Attacker, H012_auto537_attack.info_pool[effectScript.ID].Targeter, H012_auto537_attack.info_pool[effectScript.ID].AttackType, H012_auto537_attack.info_pool[effectScript.ID].AttackDataList, H012_auto537_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
