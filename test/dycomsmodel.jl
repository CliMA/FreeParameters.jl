#####
##### AtmosModel
#####

module DycomsModel
##### PlanetParameters
# Physical constants
gas_constant =     8.3144598                      #          "Universal gas constant (J/mol/K)"
light_speed =      2.99792458e8                   #          "Speed of light in vacuum (m/s)"
h_Planck =         6.626e-34                      #          "Planck constant (m^2 kg/s)"
k_Boltzmann =      1.381e-23                      #          "Boltzmann constant (m^2 kg/s^2/K)"
Stefan =           5.670e-8                       #          "Stefan-Boltzmann constant (W/m^2/K^4)"
astro_unit =       1.4959787e11                   #          "Astronomical unit (m)"
k_Karman =         0.4                            #          "Von Karman constant (1)"

# Properties of dry air
molmass_dryair =   28.97e-3                       #          "Molecular weight dry air (kg/mol)"
R_d =              gas_constant/molmass_dryair    #          "Gas constant dry air (J/kg/K)"
kappa_d =          2//7                           #          "Adiabatic exponent dry air"
cp_d =             R_d/kappa_d                    #          "Isobaric specific heat dry air"
cv_d =             cp_d - R_d                     #          "Isochoric specific heat dry air"

# Properties of water
ρ_cloud_liq =      1e3                            #          "Density of liquid water (kg/m^3)"
ρ_cloud_ice =      916.7                          #          "Density of ice water (kg/m^3)"
molmass_water =    18.01528e-3                    #          "Molecular weight (kg/mol)"
molmass_ratio =    molmass_dryair/molmass_water   #          "Molar mass ratio dry air/water"
R_v =              gas_constant/molmass_water     #          "Gas constant water vapor (J/kg/K)"
cp_v =             1859                           #          "Isobaric specific heat vapor (J/kg/K)"
cp_l =             4181                           #          "Isobaric specific heat liquid (J/kg/K)"
cp_i =             2100                           #          "Isobaric specific heat ice (J/kg/K)"
cv_v =             cp_v - R_v                     #          "Isochoric specific heat vapor (J/kg/K)"
cv_l =             cp_l                           #          "Isochoric specific heat liquid (J/kg/K)"
cv_i =             cp_i                           #          "Isochoric specific heat ice (J/kg/K)"
T_freeze =         273.15                         #          "Freezing point temperature (K)"
T_min =            150.0                          #          "Minimum temperature guess in saturation adjustment (K)"
T_max =            1000.0                         #          "Maximum temperature guess in saturation adjustment (K)"
T_icenuc =         233.00                         #          "Homogeneous nucleation temperature (K)"
T_triple =         273.16                         #          "Triple point temperature (K)"
T_0 =              T_triple                       #          "Reference temperature (K)"
LH_v0 =            2.5008e6                       #          "Latent heat vaporization at T_0 (J/kg)"
LH_s0 =            2.8344e6                       #          "Latent heat sublimation at T_0 (J/kg)"
LH_f0 =            LH_s0 - LH_v0                  #          "Latent heat of fusion at T_0 (J/kg)"
e_int_v0 =         LH_v0 - R_v*T_0                #          "Specific internal energy of vapor at T_0 (J/kg)"
e_int_i0 =         LH_f0                          #          "Specific internal energy of ice at T_0 (J/kg)"
press_triple =     611.657                        #          "Triple point vapor pressure (Pa)"

# Properties of sea water
ρ_ocean =          1.035e3                        #          "Reference density sea water (kg/m^3)"
cp_ocean =         3989.25                        #          "Specific heat sea water (J/kg/K)"

# Planetary parameters
planet_radius =    6.371e6                        #          "Mean planetary radius (m)"
day =              86400                          #          "Length of day (s)"
Omega =            7.2921159e-5                   #          "Ang. velocity planetary rotation (1/s)"
grav =             9.81                           #          "Gravitational acceleration (m/s^2)"
year_anom =        365.26*day                     #          "Length of anomalistic year (s)"
orbit_semimaj =    1*astro_unit                   #          "Length of semimajor orbital axis (m)"
TSI =              1362                           #          "Total solar irradiance (W/m^2)"
MSLP =             1.01325e5                      #          "Mean sea level pressure (Pa)"


#####


using StaticArrays
abstract type AtmosConfiguration end
struct AtmosLESConfiguration <: AtmosConfiguration end

abstract type TurbulenceClosure end

abstract type ReferenceState end
struct HydrostaticState{P,F} <: ReferenceState
  temperatureprofile::P
  relativehumidity::F
end

abstract type PrecipitationModel end
struct NoPrecipitation <: PrecipitationModel end

abstract type TemperatureProfile end

struct LinearTemperatureProfile{FT} <: TemperatureProfile
  "minimum temperature (K)"
  T_min::FT
  "surface temperature (K)"
  T_surface::FT
  "lapse rate (K/m)"
  Γ::FT
end


struct SmagorinskyLilly{FT} <: TurbulenceClosure
  "Smagorinsky Coefficient [dimensionless]"
  C_smag::FT
end

abstract type MoistureModel end
Base.@kwdef struct EquilMoist <: MoistureModel
  maxiter::Int = 3
end

abstract type RadiationModel end
struct DYCOMSRadiation{FT} <: RadiationModel
  "mass absorption coefficient `[m^2/kg]`"
  κ::FT
  "Troposphere cooling parameter `[m^(-4/3)]`"
  α_z::FT
  "Inversion height `[m]`"
  z_i::FT
  "Density"
  ρ_i::FT
  "Large scale divergence `[s^(-1)]`"
  D_subsidence::FT
  "Radiative flux parameter `[W/m^2]`"
  F_0::FT
  "Radiative flux parameter `[W/m^2]`"
  F_1::FT
end

abstract type Orientation end
struct SphericalOrientation <: Orientation end
abstract type Source end
struct Gravity <: Source end

struct GeostrophicForcing{FT} <: Source
  f_coriolis::FT
  u_geostrophic::FT
  v_geostrophic::FT
end
struct RayleighSponge{FT} <: Source
  "Maximum domain altitude (m)"
  z_max::FT
  "Altitude at with sponge starts (m)"
  z_sponge::FT
  "Sponge Strength 0 ⩽ α_max ⩽ 1"
  α_max::FT
  "Relaxation velocity components"
  u_relaxation::SVector{3,FT}
  "Sponge exponent"
  γ::FT
end
struct Subsidence{FT} <: Source
  D::FT
end
struct GeostrophicForcing{FT} <: Source
  f_coriolis::FT
  u_geostrophic::FT
  v_geostrophic::FT
end

abstract type BoundaryCondition
end
struct DYCOMS_BC{FT} <: BoundaryCondition
  "Drag coefficient"
  C_drag::FT
  "Latent Heat Flux"
  LHF::FT
  "Sensible Heat Flux"
  SHF::FT
end

function init_dycoms!(bl, state, aux, (x,y,z), t)
    FT = eltype(state)
    return nothing
end

abstract type BalanceLaw end # PDE part
struct AtmosModel{FT,O,RS,T,M,P,R,S,BC,IS} <: BalanceLaw
  orientation::O
  ref_state::RS
  turbulence::T
  moisture::M
  precipitation::P
  radiation::R
  source::S
  # TODO: Probably want to have different bc for state and diffusion...
  boundarycondition::BC
  init_state::IS
end

struct FlatOrientation <: Orientation
  # for Coriolis we could add latitude?
end

function AtmosModel{FT}(::Type{AtmosLESConfiguration};
                         orientation::O=FlatOrientation(),
                         ref_state::RS=HydrostaticState(LinearTemperatureProfile(FT(200),
                                                                                 FT(280),
                                                                                 FT(grav) / FT(cp_d)),
                                                                                 FT(0)),
                         turbulence::T=SmagorinskyLilly{FT}(0.21),
                         moisture::M=EquilMoist(),
                         precipitation::P=NoPrecipitation(),
                         radiation::R=NoRadiation(),
                         source::S=( Gravity(),
                                     Coriolis(),
                                     GeostrophicForcing{FT}(7.62e-5, 0, 0)),
                         # TODO: Probably want to have different bc for state and diffusion...
                         boundarycondition::BC=NoFluxBC(),
                         init_state::IS=nothing) where {FT<:AbstractFloat,O,RS,T,M,P,R,S,BC,IS}
  @assert init_state ≠ nothing

  atmos = (
        orientation,
        ref_state,
        turbulence,
        moisture,
        precipitation,
        radiation,
        source,
        boundarycondition,
        init_state,
       )

  return AtmosModel{FT,typeof.(atmos)...}(atmos...)
end


function get_model()
    FT = Float32
    xmax = 1000
    ymax = 1000
    zmax = 2500
    # Reference state
    T_min   = FT(289)
    T_s     = FT(290.4)
    Γ_lapse = FT(grav/cp_d)
    T       = LinearTemperatureProfile(T_min, T_s, Γ_lapse)
    rel_hum = FT(0)
    ref_state = HydrostaticState(T, rel_hum)

    # Radiation model
    κ             = FT(85)
    α_z           = FT(1)
    z_i           = FT(840)
    ρ_i           = FT(1.13)
    D_subsidence  = FT(0) # 0 for stable testing, 3.75e-6 in practice
    F_0           = FT(70)
    F_1           = FT(22)
    radiation = DYCOMSRadiation{FT}(κ, α_z, z_i, ρ_i, D_subsidence, F_0, F_1)

    # Sources
    f_coriolis    = FT(1.03e-4)
    u_geostrophic = FT(7.0)
    v_geostrophic = FT(-5.5)
    w_ref         = FT(0)
    u_relaxation  = SVector(u_geostrophic, v_geostrophic, w_ref)
    # Sponge
    c_sponge = 1
    # Rayleigh damping
    zsponge = FT(1500.0)
    rayleigh_sponge = RayleighSponge{FT}(zmax, zsponge, c_sponge, u_relaxation, 2)
    # Geostrophic forcing
    geostrophic_forcing = GeostrophicForcing{FT}(f_coriolis, u_geostrophic, v_geostrophic)

    # Boundary conditions
    # SGS Filter constants
    C_smag = FT(0.21) # 0.21 for stable testing, 0.18 in practice
    C_drag = FT(0.0011)
    LHF    = FT(115)
    SHF    = FT(15)
    bc = DYCOMS_BC{FT}(C_drag, LHF, SHF)
    ics = init_dycoms!
    source = (Gravity(),
              rayleigh_sponge,
              Subsidence{FT}(D_subsidence),
              geostrophic_forcing)

    model = AtmosModel{FT}(AtmosLESConfiguration;
                           ref_state=ref_state,
                          turbulence=SmagorinskyLilly{FT}(C_smag),
                            moisture=EquilMoist(5),
                           radiation=radiation,
                              source=source,
                   boundarycondition=bc,
                          init_state=ics)
    return model
end

model = get_model()

end
