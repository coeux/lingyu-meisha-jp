H034_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H034_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H034_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H034_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H033_daoguang")
		PreLoadSound("attack_03401")
		PreLoadAvatar("S360_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dongzuo" )
		effectScript:RegisterEvent( 21, "sdfdh" )
		effectScript:RegisterEvent( 24, "sdfdhdfg" )
		effectScript:RegisterEvent( 25, "shanghai" )
	end,

	dongzuo = function( effectScript )
		SetAnimation(H034_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	sdfdh = function( effectScript )
		AttachAvatarPosEffect(false, H034_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, 120), 1.8, 100, "H033_daoguang")
		PlaySound("attack_03401")
	end,

	sdfdhdfg = function( effectScript )
		AttachAvatarPosEffect(false, H034_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S360_3")
	end,

	shanghai = function( effectScript )
			DamageEffect(H034_normal_attack.info_pool[effectScript.ID].Attacker, H034_normal_attack.info_pool[effectScript.ID].Targeter, H034_normal_attack.info_pool[effectScript.ID].AttackType, H034_normal_attack.info_pool[effectScript.ID].AttackDataList, H034_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
