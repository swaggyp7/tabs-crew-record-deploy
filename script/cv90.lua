#include "vehicle_init.lua"

Vehicle = {
	Ammunition_Fire_Threshold = 120,
	Ammunition_Detonation_Threshold = 40,

	Language = "hebrew",

	Engine_Threshold = .985,
}

Weapons = {

	["akanm70b1"]={

		Name = "40mm L/70B",
		Caliber = 40, -- mm
		Accuracy = 0.0001, -- from 0 to 1
		Fire_Rate = 300, -- rounds/min
		Reload_Time = 10, -- s
		Weapon_Sound = "40mm_autocannon",
		Reload_Sound = "reload_40mm_cannon_2",
		Recoiling_Barrel = true,
		Recoil_Distance = .35,

		Shell_Presets = {
			["slpprjm90"]={
				Custom = false, -- If this is true, info about the ammo type will be given to the main script

				Mag_Size = 8,
				Reserve_Ammo = 105,
			},
			["slsgrm90"]={
				Custom = false,

				Mag_Size = 8,
				Reserve_Ammo = 105,
			},
			["kulsgrm90"]={
				Custom = false,

				Mag_Size = 8,
				Reserve_Ammo = 24,
			},
			
		},

	},
	
	["akanm70b2"]={

		Name = "40mm L/70B",
		Caliber = 40, -- mm
		Accuracy = 0.0001, -- from 0 to 1
		Fire_Rate = 300, -- rounds/min
		Reload_Time = 10, -- s
		Weapon_Sound = "40mm_autocannon",
		Reload_Sound = "reload_40mm_cannon_2",
		Recoiling_Barrel = true,
		Recoil_Distance = .35,

		Shell_Presets = {
			["slsgrm90"]={
				Custom = false,

				Mag_Size = 8,
				Reserve_Ammo = 48,
			},
			["slpprjm01"]={
				Custom = false,

				Mag_Size = 8,
				Reserve_Ammo = 48,
			},
			["kulsgrm90"]={
				Custom = false,

				Mag_Size = 8,
				Reserve_Ammo = 24,
			},
			
		},

	},
	
	["akanm70b1lv"]={

		Name = "40mm L/70B",
		Caliber = 40, -- mm
		Accuracy = 0.0001, -- from 0 to 1
		Fire_Rate = 300, -- rounds/min
		Reload_Time = 10, -- s
		Weapon_Sound = "40mm_autocannon",
		Reload_Sound = "reload_40mm_cannon_2",
		Recoiling_Barrel = true,
		Recoil_Distance = .35,

		Shell_Presets = {
			["slpprjm90"]={
				Custom = false, -- If this is true, info about the ammo type will be given to the main script

				Mag_Size = 8,
				Reserve_Ammo = 42,
			},
			["slsgrm90"]={
				Custom = false,

				Mag_Size = 8,
				Reserve_Ammo = 96,
			},
			["kulsgrm90"]={
				Custom = false,

				Mag_Size = 8,
				Reserve_Ammo = 96,
			},
			
		},

	},
	
	["35mmbushmaster3"]={

		Name = "35mm Bushmaster III",
		Caliber = 35, -- mm
		Accuracy = 0.0001, -- from 0 to 1
		Fire_Rate = 200, -- rounds/min
		Reload_Time = 10, -- s
		Weapon_Sound = "bushmaster",
		Interior_Sound = "autocannons/autocannon_interior_shared_0",
		Reload_Sound = "",
		Recoiling_Barrel = true,
		Recoil_Distance = .2,

		Shell_Presets = {
			["35mmapfsdst"]={
				Custom = false, -- If this is true, info about the ammo type will be given to the main script

				Mag_Size = 35,
				Reserve_Ammo = 70,
			},
			["35mmheit"]={
				Custom = false,

				Mag_Size = 35,
				Reserve_Ammo = 35,
			},
			["abmketf"]={
				Custom = false,

				Mag_Size = 35,
				Reserve_Ammo = 0,
			},
			
		},

	},
	
	["mk44bushmaster2"]={

		Name = "MK44 Bushmaster II",
		Caliber = 30, -- mm
		Accuracy = 0.0001, -- from 0 to 1
		Fire_Rate = 201, -- rounds/min
		Reload_Time = 10, -- s
		Weapon_Sound = "30mm_bushmaster_0",
		Interior_Sound = "autocannons/autocannon_interior_shared_0",
		Reload_Sound = "",
		Recoiling_Barrel = true,
		Recoil_Distance = .1,

		Shell_Presets = {
			["mk257"]={
				Custom = false, -- If this is true, info about the ammo type will be given to the main script

				Mag_Size = 80,
				Reserve_Ammo = 160,
			},
			["mk258"]={
				Custom = false,

				Mag_Size = 80,
				Reserve_Ammo = 160,
			},
			["mk266"]={
				Custom = false,

				Mag_Size = 80,
				Reserve_Ammo = 80,
			},
			
		},

	},
	
	["rbs56bill2"]={

		Name = "RBS-56 BILL-2",
		Caliber = 150, -- mm
		Accuracy = 0.0005, -- from 0 to 1
		Fire_Rate = 60, -- rounds/min
		Reload_Time = 20, -- s
		Weapon_Sound = "atgm_launch",
		Reload_Sound = "t72_autoloader",
		Autoloader = true,

		Shell_Presets = {
			["rbs56bill2"]={
				Custom = false, -- If this is true, info about the ammo type will be given to the main script

				Mag_Size = 2,
				Reserve_Ammo = 8,
			},
		},

	},
	
	["akeron"]={

		Name = "AKERON",
		Caliber = 130, -- mm
		Accuracy = 0.0005, -- from 0 to 1
		Fire_Rate = 60, -- rounds/min
		Reload_Time = 20, -- s
		Weapon_Sound = "atgm_launch",
		Reload_Sound = "",
		Autoloader = false,

		Shell_Presets = {
			["spikelr2"]={
				Custom = false, -- If this is true, info about the ammo type will be given to the main script

				Mag_Size = 2,
				Reserve_Ammo = 4,
			},
		},

	},
	
	["mg3"]={
	
		Name = "MG3 7.62mm",
		Caliber = 7.62, -- mm
		Accuracy = 0.004, -- from 0 to 1
		Fire_Rate = 1200, -- rounds/min
		Reload_Time = 4.9, -- s
		Weapon_Sound = "mg/LMG-MG-42-MODERN_0",
		Reload_Sound = "reloads/reload_37mm_cannon_0",
		
		Shell_Presets = {
			["762x51mm"]={
				Custom = true,
				
				Type = "bullet",
				Name = "7.62x51mm NATO",

				Velocity = 850, --m/s
				Propulsion_Type = "ballistic", -- propulsion type
				Mass = 0.0093, -- mass of projectile in kg
				Momentum = 12, --mm of RHA (rolled homogeneous armor)
				Projectile_Caliber = 7.62, --projectile caliber in mm
				Shell_Caliber = 7.62, --shell caliber in mm

				Tracer = true,
				Tracer_Color_R = 1,
				Tracer_Color_G = .4,
				Tracer_Color_B = .3,
				Recoil = 140,

				Spall_Amount = 0,
				Spall_Angle = 0, --cone area of spall from 0 to 1 (0 being no deviation from projectile direction, 1 being sphere)
				Shrapnel_Amount = 0, --number of shrapnel pieces (used for HE shells)
				Explosive_Payload = 0, --(kg) used for HE shells
				
				Mag_Size = 100,
				Reserve_Ammo = 3700,
			},
		},
	},
	
	["m62"]={
	
		Name = "7.62mm M/62",
		Caliber = 7.62, -- mm
		Accuracy = 0.004, -- from 0 to 1
		Fire_Rate = 1200, -- rounds/min
		Reload_Time = 4.9, -- s
		Weapon_Sound = "mg/LMG-MG-42-MODERN_0",
		Reload_Sound = "reloads/reload_37mm_cannon_0",
		
		Shell_Presets = {
			["762x51mm"]={
				Custom = true,
				
				Type = "bullet",
				Name = "7.62x51mm NATO",

				Velocity = 850, --m/s
				Propulsion_Type = "ballistic", -- propulsion type
				Mass = 0.0093, -- mass of projectile in kg
				Momentum = 12, --mm of RHA (rolled homogeneous armor)
				Projectile_Caliber = 7.62, --projectile caliber in mm
				Shell_Caliber = 7.62, --shell caliber in mm

				Tracer = true,
				Tracer_Color_R = 1,
				Tracer_Color_G = .4,
				Tracer_Color_B = .3,
				Recoil = 140,

				Spall_Amount = 0,
				Spall_Angle = 0, --cone area of spall from 0 to 1 (0 being no deviation from projectile direction, 1 being sphere)
				Shrapnel_Amount = 0, --number of shrapnel pieces (used for HE shells)
				Explosive_Payload = 0, --(kg) used for HE shells
				
				Mag_Size = 100,
				Reserve_Ammo = 1000,
			},
		},
	},
	
	["ksp39c"]={

		Name = "ksp m/39c",
		Caliber = 7.62, -- mm
		Accuracy = 0.002, -- from 0 to 1
		Fire_Rate = 600, -- rounds/min
		Reload_Time = 10, -- s
		Weapon_Sound = "small arms/vector/vector_0",
		Reload_Sound = "reloads/reload_37mm_cannon_0",

		Shell_Presets = {
			["762x51"]={
				Custom = false, -- If this is true, info about the ammo type will be given to the main script

				Mag_Size = 250,
				Reserve_Ammo = 4000,
			},
		},

	},

	["ksp58b"]={

		Name = "KSP 58B",
		Caliber = 7.62, -- mm
		Accuracy = 0.004, -- from 0 to 1
		Fire_Rate = 650, -- rounds/min
		Reload_Time = 8, -- s
		Weapon_Sound = "m240",
		Interior_Sound = "mg/lmg_generic_interior_0",
		Reload_Sound = "mgreload",

		Shell_Presets = {
			["762x51"]={
				Custom = false, -- If this is true, info about the ammo type will be given to the main script

				Mag_Size = 250,
				Reserve_Ammo = 2000,
			},
		},

	},

	["ksp58bcoax"]={

		Name = "KSP 58B",
		Caliber = 7.62, -- mm
		Accuracy = 0.004, -- from 0 to 1
		Fire_Rate = 650, -- rounds/min
		Reload_Time = 8, -- s
		Weapon_Sound = "small arms/g36/g36_0",
		Interior_Sound = "mg/lmg_generic_interior_0",
		Reload_Sound = "mgreload",

		Shell_Presets = {
			["762x51"]={
				Custom = false, -- If this is true, info about the ammo type will be given to the main script

				Mag_Size = 250,
				Reserve_Ammo = 2000,
			},
		},

	},
	
	["pkt"]={

		Name = "7.62mm PKT",
		Caliber = 7.62, -- mm
		Accuracy = 0.004, -- from 0 to 1
		Fire_Rate = 700, -- rounds/min
		Reload_Time = 8, -- s
		Weapon_Sound = "lmg_0",
		Interior_Sound = "mg/lmg_generic_interior_0",
		Reload_Sound = "mgreload",

		Shell_Presets = {
			["762x51"]={
				Custom = false, -- If this is true, info about the ammo type will be given to the main script

				Mag_Size = 250,
				Reserve_Ammo = 4000,
			},
		},

	},

	["m2remote"]={

		Name = "M2",
		Caliber = 12.7, -- mm
		Accuracy = 0.0006, -- from 0 to 1
		Fire_Rate = 550, -- rounds/min
		Reload_Time = 10, -- s
		Weapon_Sound = "m2hb_0",
		Reload_Sound = "mgreload",
		Recoiling_Barrel = true,
		Recoil_Distance = .1,

		Shell_Presets = {
			["50bmg"]={
				Custom = false, -- If this is true, info about the ammo type will be given to the main script

				Mag_Size = 250,
				Reserve_Ammo = 1500,
			},
		},

	},

}

function init()
	local v = FindVehicle("TABS")

	VehicleInit(v,Vehicle,Weapons)

	SetTag(v, "TABSINIT")
end