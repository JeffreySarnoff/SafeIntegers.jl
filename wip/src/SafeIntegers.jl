# SafeIntegers := reinterpret(SafeIntegers, RoundingIntegers⦃Tim Holy⦄)

module SaferIntegers

export SafeUnsigned, SafeSigned, SafeInteger,
       SafeUInt, SafeUInt8, SafeUInt16, SafeUInt32, SafeUInt64, SafeUInt128,
       SafeInt, SafeInt8, SafeInt16, SafeInt32, SafeInt64, SafeInt128,
       is_safeint

import Base: ==, <, <=, +, -, *, ~, &, |, ⊻, <<, >>, >>>
import Base.Checked: checked_abs, checked_neg, checked_add,
    checked_sub, checked_mul, checked_div, checked_fld,
	checked_cld, checked_rem, checked_mod

include("types.jl")
include("conversions.jl")

Base.signbit(x::SafeSigned) = signbit(Integer(x))
Base.sign(x::SafeSigned)    = sign(Integer(x))
Base.abs(x::SafeSigned)     = abs(Integer(x))
Base.abs2(x::SafeSigned)    = abs2(Integer(x))

Base.signbit(x::SafeUnsigned) = false
Base.sign(x::T) where T<:SafeUnsigned = one(T)
Base.abs(x::SafeUnsigned)     = x
Base.abs2(x::SafeUnsigned)    = x*x

(< )(x::SafeInteger, y::SafeInteger) = Integer(x) <  Integer(y)
(<=)(x::SafeInteger, y::SafeInteger) = Integer(x) <= Integer(y)

Base.count_ones(x::SafeInteger)     = count_ones(Integer(x))
Base.leading_zeros(x::SafeInteger)  = leading_zeros(Integer(x))
Base.trailing_zeros(x::SafeInteger) = trailing_zeros(Integer(x))
Base.ndigits0z(x::SafeInteger)      = Base.ndigits0z(Integer(x))

Base.flipsign(x::SafeSigned, y::SafeSigned) = SafeInteger(flipsign(Integer(x), Integer(y)))
Base.copysign(x::SafeSigned, y::SafeSigned) = SafeInteger(copysign(Integer(x), Integer(y)))
Base.flipsign(x::SafeSigned, y::SafeUnsigned) = x
Base.copysign(x::SafeSigned, y::SafeUnsigned) = signbit(x) ? -x : x

# A few operations preserve the type
(~)(x::SafeInteger) = SafeInteger(~Integer(x))

(&)(x::T, y::T) where {T<:SafeInteger} = SafeInteger(Integer(x) & Integer(y))
(|)(x::T, y::T) where {T<:SafeInteger} = SafeInteger(Integer(x) | Integer(y))
(⊻)(x::T, y::T) where {T<:SafeInteger} = SafeInteger(Integer(x) ⊻ Integer(y))

(>> )(x::SafeInteger, y::Signed)   = SafeInteger(Integer(x) >>  y)
(>>>)(x::SafeInteger, y::Signed)   = SafeInteger(Integer(x) >>> y)
(<< )(x::SafeInteger, y::Signed)   = SafeInteger(Integer(x) <<  y)
(>> )(x::SafeInteger, y::Unsigned) = SafeInteger(Integer(x) >>  y)
(>>>)(x::SafeInteger, y::Unsigned) = SafeInteger(Integer(x) >>> y)
(<< )(x::SafeInteger, y::Unsigned) = SafeInteger(Integer(x) <<  y)

(>> )(x::SafeInteger, y::Int) = SafeInteger(Integer(x) >>  y)
(>>>)(x::SafeInteger, y::Int) = SafeInteger(Integer(x) >>> y)
(<< )(x::SafeInteger, y::Int) = SafeInteger(Integer(x) <<  y)

(-)(x::T) where {T<:SafeInteger} = SafeInteger(checked_neg(Integer(x)))
(+)(x::T, y::T) where {T<:SafeInteger} = SafeInteger(checked_add(Integer(x), Integer(y)))
(-)(x::T, y::T) where {T<:SafeInteger} = SafeInteger(checked_sub(Integer(x), Integer(y)))
(*)(x::T, y::T) where {T<:SafeInteger} = SafeInteger(checked_mul(Integer(x), Integer(y)))

Base.div(x::T, y::T) where {T<:SafeInteger} = SafeInteger(checked_div(Integer(x), Integer(y)))
Base.fld(x::T, y::T) where {T<:SafeInteger} = SafeInteger(checked_fld(Integer(x), Integer(y)))
Base.cld(x::T, y::T) where {T<:SafeInteger} = SafeInteger(checked_cld(Integer(x), Integer(y)))
Base.rem(x::T, y::T) where {T<:SafeInteger} = SafeInteger(checked_rem(Integer(x), Integer(y)))
Base.mod(x::T, y::T) where {T<:SafeInteger} = SafeInteger(checked_mod(Integer(x), Integer(y)))

# rem, mod conversions
@inline Base.rem(x::T, ::Type{T}) where {T<:SafeInteger} = T
@inline Base.rem(x::Integer, ::Type{T}) where {T<:SafeInteger} = SafeInteger(rem(x, itype(T)))
@inline Base.rem(x::BigInt, ::Type{T}) where {T<:SafeInteger} = error("no rounding BigInt available")
@inline Base.mod(x::T, ::Type{T}) where {T<:SafeInteger} = T
@inline Base.mod(x::Integer, ::Type{T}) where {T<:SafeInteger} = SafeInteger(mod(x, itype(T)))
@inline Base.mod(x::BigInt, ::Type{T}) where {T<:SafeInteger} = error("no rounding mod BigInt available")

(+)(x::T, y::U) where {T<:SafeInteger, U<:Integer} = SafeInteger(checked_add(Integer(x), Integer(y)))
(-)(x::T, y::U) where {T<:SafeInteger, U<:Integer} = SafeInteger(checked_sub(Integer(x), Integer(y)))
(*)(x::T, y::U) where {T<:SafeInteger, U<:Integer} = SafeInteger(checked_mul(Integer(x), Integer(y)))
(+)(x::U, y::T) where {T<:SafeInteger, U<:Integer} = SafeInteger(checked_add(Integer(x), Integer(y)))
(-)(x::U, y::T) where {T<:SafeInteger, U<:Integer} = SafeInteger(checked_sub(Integer(x), Integer(y)))
(*)(x::U, y::T) where {T<:SafeInteger, U<:Integer} = SafeInteger(checked_mul(Integer(x), Integer(y)))

Base.div(x::T, y::U) where {T<:SafeInteger, U<:Integer} = SafeInteger(checked_div(Integer(x), Integer(y)))
Base.fld(x::T, y::U) where {T<:SafeInteger, U<:Integer} = SafeInteger(checked_fld(Integer(x), Integer(y)))
Base.cld(x::T, y::U) where {T<:SafeInteger, U<:Integer} = SafeInteger(checked_cld(Integer(x), Integer(y)))
Base.rem(x::T, y::U) where {T<:SafeInteger, U<:Integer} = SafeInteger(checked_rem(Integer(x), Integer(y)))
Base.mod(x::T, y::U) where {T<:SafeInteger, U<:Integer} = SafeInteger(checked_mod(Integer(x), Integer(y)))

Base.div(x::U, y::T) where {T<:SafeInteger, U<:Integer} = SafeInteger(checked_div(Integer(x), Integer(y)))
Base.fld(x::U, y::T) where {T<:SafeInteger, U<:Integer} = SafeInteger(checked_fld(Integer(x), Integer(y)))
Base.cld(x::U, y::T) where {T<:SafeInteger, U<:Integer} = SafeInteger(checked_cld(Integer(x), Integer(y)))
Base.rem(x::U, y::T) where {T<:SafeInteger, U<:Integer} = SafeInteger(checked_rem(Integer(x), Integer(y)))
Base.mod(x::U, y::T) where {T<:SafeInteger, U<:Integer} = SafeInteger(checked_mod(Integer(x), Integer(y)))

# traits
Base.typemin(::Type{T}) where {T<:SafeInteger} = SafeInteger(typemin(itype(T)))
Base.typemax(::Type{T}) where {T<:SafeInteger} = SafeInteger(typemax(itype(T)))
Base.widen(::Type{T}) where {T<:SafeInteger} = stype(widen(itype(T)))

# show

Base.string(x::T) where T<:SafeInteger = string( Integer(x) )
Base.show(io::IO, x::T) where T<:SafeInteger = print(io, string(x) )

Base.hex(n::T, pad::Int=1) where T<:SafeInteger = hex(Integer(n), pad)
Base.bits(n::T) where T<: SafeInteger = bits(Integer(n))

# predicate

const SAFEINTS = Union{SafeUInt8, SafeUInt16, SafeUInt32, SafeUInt64, SafeUInt128,
                       SafeInt8, SafeInt16, SafeInt32, SafeInt64, SafeInt128}
      
is_safeint(::Type{T}) where T<:SAFEINTS = true
is_safeint(::Type{T}) where T = false
is_safeint(x::T) where T = is_safeint(T)

end # module SafeIntegers