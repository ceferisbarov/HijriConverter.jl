module test_locales

include("../../src/locales.jl")
using .locales
using Test
locale_map = locales._locale_map


function test_locale_data_structure()
        for locale_cls in values(locales._locale_map)
            @test length(locale_cls.language_tag) == 2
            @test all(islowercase, locale_cls.language_tag)
            @test length(locale_cls.month_names) == 12
            @test all(!isempty, locale_cls.month_names)  # not blank or None
#            @test all(!is(nothing), locale_cls.month_names)  # not blank or None
            @test length(locale_cls.gregorian_month_names) == 12
 #           @test all(locale_cls.gregorian_month_names)  # not blank or None
            @test length(locale_cls.day_names) == 7
  #          @test all(locale_cls.day_names)  # not blank or None
            @test locale_cls.notation != nothing
            @test locale_cls.gregorian_notation != nothing
	end
end	

function test_locale_map()
        @test length(locales._locale_map) > 0
        @test "en" in keys(locales._locale_map)
        @test "ar" in keys(locales._locale_map)
        @test "az" in keys(locales._locale_map)
        @test "bn" in keys(locales._locale_map)
end
end

#function test_duplicated_language_tag()
 #       @test_throws LookupError
#
 #           class ExtraLocale(locales.Locale):
  #              language_tag = "en"

