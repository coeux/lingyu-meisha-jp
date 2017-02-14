H002_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H002_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H002_normal_attack.info_pool[effectScript.ID].Attacker)
        
		H002_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("atalk_0201")
		PreLoadAvatar("yjdaoguang")
		PreLoadSound("attack_0601")
		PreLoadSound("")
		PreLoadAvatar("yjshouji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dongzuo" )
		effectScript:RegisterEvent( 24, "d" )
		effectScript:RegisterEvent( 25, "shanghai" )
		effectScript:RegisterEvent( 26, "c" )
		effectScript:RegisterEvent( 27, "df" )
	end,

	dongzuo = function( effectScript )
		SetAnimation(H002_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("atalk_0201")
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, H002_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 85), 1.5, 100, "yjdaoguang")
		PlaySound("attack_0601")
	end,

	shanghai = function( effectScript )
			PlaySound("")
	end,

	c = function( effectScript )
		AttachAvatarPosEffect(false, H002_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -20), 1.5, 100, "yjshouji")
	end,

	df = function( effectScript )
			DamageEffect(H002_normal_attack.info_pool[effectScript.ID].Attacker, H002_normal_attack.info_pool[effectScript.ID].Targeter, H002_normal_attack.info_pool[effectScript.ID].AttackType, H002_normal_attack.info_pool[effectScript.ID].AttackDataList, H002_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
