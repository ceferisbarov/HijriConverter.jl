include("../../src/convert.jl")
using .core
using Test

#@test core.to_hijri(core.Gregorian(2000, 8, 13))
#@test core.Gregorian(1990, 3, 10)


hijri_obj = core.Hijri(1410, 8, 13)

function TestHijri()
#        @test hijri_obj.__repr__() == "Hijri(1410, 8, 13)"

#       @test hijri_obj.__str__() == "1410-08-13"

#        @test self.hijri_obj.__hash__() == hash(("Hijri", 1410, 8, 13))

#    @pytest.mark.parametrize("test_input", ["__gt__", "__ge__", "__lt__", "__le__"])
 #   def test_comparison_notimplemented(self, test_input):
  #      assert getattr(self.hijri_obj, test_input)("1410-08-13") == NotImplemented
end

function test_equality()
        @test hijri_obj == core.Hijri(1410, 8, 13)
        @test hijri_obj != core.Hijri(1410, 8, 14)
        @test hijri_obj != "1410-08-13"
end

function test_ordering()
#        @test hijri_obj > core.Hijri(1410, 8, 12)
 #       @test hijri_obj >= core.Hijri(1410, 8, 13)
  #      @test hijri_obj < core.Hijri(1410, 8, 14)
   #     @test hijri_obj <= core.Hijri(1410, 8, 13)
end

function test_fromisoformat()
        @test core.fromisoformat("1410-08-13") == hijri_obj
end

function test_today()
        @test core.to_gregorian(core.hijri_today()) == core.gregorian_today()
end

function test_year()
        @test hijri_obj.year == 1410
end

function test_month()
        @test hijri_obj.month == 8
end

function test_day()
        @test hijri_obj.day == 13
end

function test_datetuple()
        @test core.datetuple(hijri_obj) == (1410, 8, 13)
end

function test_isoformat()
        @test core.isoformat(hijri_obj) == "1410-08-13"
end

function test_dmyformat()
        @test dmyformat(hijri_obj) == "13/08/1410"
        @test dmyformat(hijri_obj, padding=false) == "13/8/1410"
        @test dmyformat(hijri_obj, separator=".") == "13.08.1410"
end

function test_month_length()
        @test hijri_obj.month_length() == 29
end

function test_month_name()
        @test hijri_obj.month_name() == "Sha’ban"
        @test hijri_obj.month_name("en") == "Sha’ban"
        @test hijri_obj.month_name("en-US") == "Sha’ban"
end

function test_weekday()
        @test weekday(hijri_obj) == 5
end

function test_iso_weekday()
        @test isoweekday(hijri_obj) == 6
end

function test_day_name()
        @test hijri_obj.day_name() == "Saturday"
        @test hijri_obj.day_name("en") == "Saturday"
        @test hijri_obj.day_name("en-US") == "Saturday"
end

function test_notation()
        @test hijri_obj.notation() == "AH"
        @test hijri_obj.notation("en") == "AH"
        @test hijri_obj.notation("en-US") == "AH"
end

function test_to_julian()
        @test hijri_obj.to_julian() == 2447961
end

function test_to_gregorian()
        @test hijri_obj.to_gregorian().datetuple() == (1990, 3, 10)
end

function test_month_index()
        @test hijri_obj._month_index() == 811
end

test_equality()

test_ordering()

test_fromisoformat()

test_today()

test_year()

test_month()

test_day()

test_datetuple()

test_isoformat()

test_dmyformat()

test_month_length()

test_month_name()

test_weekday()

test_iso_weekday()

test_day_name()

test_notation()

test_to_julian()

test_to_gregorian()

test_month_index()
