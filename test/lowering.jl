module TestLowering

using JSON5: JSON, JSONText, json
using Test
using Dates
using FixedPointNumbers: Fixed

@test JSON.json(Date(2016, 8, 3)) == "\"2016-08-03\""

@test JSON.json(:x) == "\"x\""
@test_throws ArgumentError JSON.json(Base)

struct Type151{T}
    x::T
end

@test JSON.parse(JSON.json(Type151)) == string(Type151)

JSON.lower(v::Type151{T}) where {T} = Dict(:type => T, :value => v.x)
@test JSON.parse(JSON.json(Type151(1.0))) == Dict(
    "type" => "Float64",
    "value" => 1.0)

fixednum = Fixed{Int16, 15}(0.1234)
@test JSON.parse(JSON.json(fixednum)) == convert(Float64, fixednum)

# test that the default string-serialization of enums can be overridden by
# `lower` if needed
@enum Fruit apple orange banana
JSON.lower(x::Fruit) = string("Fruit: ", x)
@test JSON.json(apple) == "\"Fruit: apple\""

@enum Vegetable carrot tomato potato
JSON.lower(x::Vegetable) = Dict(string(x) => Int(x))
@test JSON.json(potato) == "{\"potato\":2}"

# test that the default lowering for compound types can be overridden by `propertynames` and
# `getproperty` if needed
struct Type152
    x::Int
end
Base.propertynames(v::Type152) = (:type, fieldnames(Type152)...)
Base.getproperty(v::Type152, s::Symbol) = s == :type ? :Type152 : getfield(v, s)
@test JSON.json(Type152(152)) == "{\"type\":\"Type152\",\"x\":152}"

end
