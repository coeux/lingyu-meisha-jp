--avatarManager.lua

--========================================================================
--换装管理者类

AvatarManager =
	{
	};


--初始化
function AvatarManager:Init()
	AvatarManagerLoadSkillEffect();
	self:LoadUIEffect();
end

--加载套装数据
function AvatarManager:LoadFile( path )
	armatureManager:LoadFile(path);
end

--加载UI特效
function AvatarManager:LoadUIEffect()
	  --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/Batter_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/Batter_1_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/chongzhianniu_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/daojishi_output/');
    armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/lihui_output/');
    armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/dianjidimian_output/');
    armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/die_output/');
    armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/die_xiaoguoxian_output/');
    armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/lianji_output/');

    armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/angerball_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/donghua_101_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/donghua_201_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/donghua_301_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/donghua_401_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/fail_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/Gesture_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/gesture1_1_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/gesture1_2_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/gesture2_1_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/gesture2_2_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/gesture3_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/gesture4_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/God_refers_to_the_meaning_output/');
    armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/gonghuiBOSS_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/Heart_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/hunpo_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/jiaoxue_101_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/jiaoxue_201_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/jiaoxue_301_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/chongzhi_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/jinbi_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/zhandouli_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/tili_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/yuanlizi_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/changtiaolizi_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/renwulan_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/event_output/');

    --技能
    armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/chuka_output/');
    armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/shui_output/');
    armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/feng_output/');
    armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/huo_output/');
    armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/lei_output/');

    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/liaotian_1_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/liaotian_2_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/liaotian_3_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/liaotian_4_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/liaotian_5_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/liaotian_6_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/liaotian_7_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/liaotian_8_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/liaotian_9_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/liaotian_10_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/liaotian_11_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/liaotian_12_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/liaotian_13_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/liaotian_14_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/liaotian_15_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/liaotian_16_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/liaotian_17_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/liaotian_18_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/liaotian_19_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/liaotian_20_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/liaotian_21_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/biaoqing_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/miaozhun_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/nengliangcao_1_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/nengliangcao_3_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/nvhuo_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/QTE_yindao_output/');
    armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/S402_2_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/shengliyanhua_output/');
    armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/shenjichuxian_1_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/skill_yindao_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/skill_yindao_1_output/');
    armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/teleport_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/UI_txcx01_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/zhandoushibai_output/');
    armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/zhiyin_output/');
    armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/xinshoujiantou_output/');
    armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/shouchong_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/dengrujiangli_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/qianwangshoumo_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/high_level_gem_1_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/high_level_gem_2_output/');
    --armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/guanqiajiangli_output/');
    armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/zhandouzhong_output/');
	--armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/daxinfeng_output/');
	--armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/chibang_jinfazhen_output/');
	--armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/wing_23000_output/');
	--armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/wing_23010_output/');
	--armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/wing_23020_output/');
	--armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/wing_23030_output/');
	--armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/wing_23040_output/');
	--armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/wing_23050_output/');
	--armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/changjing_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/taskfindpath_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/guanqia_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/combojineng_output/');
	--armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/CJ_huo_1_output/');
	--armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/CJ_huo_2_output/');
	--armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/CJ_huo_3_output/');
	--armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/CJ_shitou_output/');

	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/YZ_baoxiang_1_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/YZ_baoxiang_2_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/YZ_baoxiang_3_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/YZ_baoxiang_4_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/fubenjiemian_output/');
    armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/love_max_output/');
    armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/zhandoushengli_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/hunshijinjie_output/');
    armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/putong_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/zuizhong_output/');
    -- armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/expedition_box_1_output/');
    -- armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/expedition_box_2_output/');
end
