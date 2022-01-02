include("../../src/convert.jl")
using .core
using Test


hijri_obj_1 = core.Hijri(1410, 8, 13)
hijri_obj_2 = core.Hijri(1460, 4, 21)
hijri_obj_3 = core.Hijri(1343, 1, 1)
hijri_obj_4 = core.Hijri(1500, 12, 30)


function TestHijri()
#        @test hijri_obj.__repr__() == "Hijri(1410, 8, 13)"

#       @test hijri_obj.__str__() == "1410-08-13"

#        @test self.hijri_obj.__hash__() == hash(("Hijri", 1410, 8, 13))

#    @pytest.mark.parametrize("test_input", ["__gt__", "__ge__", "__lt__", "__le__"])
 #   def test_comparison_notimplemented(self, test_input):
  #      assert getattr(self.hijri_obj, test_input)("1410-08-13") == NotImplemented
end

function test_equality()
        @test hijri_obj_1 == core.Hijri(1410, 8, 13)
        @test hijri_obj_1 != core.Hijri(1410, 8, 14)
        @test hijri_obj_1 != "1410-08-13"
end

function test_ordering() #TODO: implement comparison
#        @test hijri_obj > core.Hijri(1410, 8, 12)
 #       @test hijri_obj >= core.Hijri(1410, 8, 13)
  #      @test hijri_obj < core.Hijri(1410, 8, 14)
   #     @test hijri_obj <= core.Hijri(1410, 8, 13)
end


function test_fromisoformat()
        @test core.fromisoformat("1410-08-13") == hijri_obj_1
        @test core.fromisoformat("1460-04-21") == hijri_obj_2
        @test core.fromisoformat("1343-01-01") == hijri_obj_3
        @test core.fromisoformat("1500-12-30") == hijri_obj_4
end

function test_today()
        @test core.to_gregorian(core.hijri_today()) == core.gregorian_today()
end

function test_year()
        @test hijri_obj_1.year == 1410
        @test hijri_obj_2.year == 1460
        @test hijri_obj_3.year == 1343
        @test hijri_obj_4.year == 1500
end

function test_month()
        @test hijri_obj_1.month == 8
        @test hijri_obj_2.month == 4
        @test hijri_obj_3.month == 1
        @test hijri_obj_4.month == 12
end

function test_day()
        @test hijri_obj_1.day == 13
        @test hijri_obj_2.day == 21
        @test hijri_obj_3.day == 1
        @test hijri_obj_4.day == 30
end

function test_datetuple()
        @test core.datetuple(hijri_obj_1) == (1410, 8, 13)
end

function test_isoformat()
        @test core.isoformat(hijri_obj_1) == "1410-08-13"
end

function test_dmyformat()
        @test core.dmyformat(hijri_obj_1) == "13/08/1410"
        @test core.dmyformat(hijri_obj_1; padding=false) == "13/8/1410"
        @test core.dmyformat(hijri_obj_1; separator=".") == "13.08.1410"
end

function test_month_length()
        @test core.month_length(hijri_obj_1) == 29
end

function test_month_name()
        @test core.month_name(hijri_obj_1) == "Sha’ban"
        @test core.month_name(hijri_obj_1, "en") == "Sha’ban"
        @test core.month_name(hijri_obj_1, "en-US") == "Sha’ban"
end

function test_weekday()
        @test core.weekday(hijri_obj_1) == 5
end

function test_iso_weekday()
        @test core.isoweekday(hijri_obj_1) == 6
end

function test_day_name()
        @test core.day_name(hijri_obj_1) == "Saturday"
        @test core.day_name(hijri_obj_1, "en") == "Saturday"
        @test core.day_name(hijri_obj_1, "en-US") == "Saturday"
end

function test_notation()
        @test core.notation(hijri_obj_1) == "AH"
        @test core.notation(hijri_obj_1, "en") == "AH"
        @test core.notation(hijri_obj_1, "en-US") == "AH"
end

function test_to_julian()
        @test core.to_julian(hijri_obj_1) == 2447961
end

function test_to_gregorian()
        @test core.datetuple(core.to_gregorian(hijri_obj_1)) == (1990, 3, 10)
end

function test_month_index()
        @test core._month_index(hijri_obj_1) == 811
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
