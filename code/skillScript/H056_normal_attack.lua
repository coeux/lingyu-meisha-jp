H056_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H056_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H056_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H056_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("H056_2_1")
		PreLoadSound("atalk_05601")
		PreLoadSound("attack_05601")
		PreLoadAvatar("H056_2_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfvg" )
		effectScript:RegisterEvent( 21, "vf" )
		effectScript:RegisterEvent( 23, "vn" )
		effectScript:RegisterEvent( 25, "tfg" )
	end,

	dfvg = function( effectScript )
		SetAnimation(H056_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	vf = function( effectScript )
		AttachAvatarPosEffect(false, H056_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(90, 70), 1.2, 100, "H056_2_1")
		PlaySound("atalk_05601")
		PlaySound("attack_05601")
	end,

	vn = function( effectScript )
		AttachAvatarPosEffect(false, H056_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.8, 100, "H056_2_2")
	end,

	tfg = function( effectScript )
			DamageEffect(H056_normal_attack.info_pool[effectScript.ID].Attacker, H056_normal_attack.info_pool[effectScript.ID].Targeter, H056_normal_attack.info_pool[effectScript.ID].AttackType, H056_normal_attack.info_pool[effectScript.ID].AttackDataList, H056_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
