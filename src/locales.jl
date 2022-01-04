"""Localization for the Hijri month and day names."""
module locales
using Parameters

#@doc   """A Hijri locale object represents locale-specific data and functionality.""" ->
@with_kw struct Locale
    language_tag::String
    month_names::Array{String}
    gregorian_month_names::Array{String}
    day_names::Array{String}
    notation::String
    gregorian_notation::String
end

EnglishLocale = Locale(
    language_tag = "en",
    month_names = [
        "Muharram",
        "Safar",
        "Rabi’ al-Awwal",
        "Rabi’ al-Thani",
        "Jumada al-Ula",
        "Jumada al-Akhirah",
        "Rajab",
        "Sha’ban",
        "Ramadhan",
        "Shawwal",
        "Dhu al-Qi’dah",
        "Dhu al-Hijjah",
    ],
    gregorian_month_names = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December",
    ],
    day_names = [
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday",
    ],
    notation = "AH",
    gregorian_notation = "CE")

ArabicLocale = Locale(
    language_tag = "ar",
    month_names = [
        "محرم",
        "صفر",
        "ربيع الأول",
        "ربيع الثاني",
        "جمادى الأولى",
        "جمادى الآخرة",
        "رجب",
        "شعبان",
        "رمضان",
        "شوال",
        "ذو القعدة",
        "ذو الحجة",
    ],
    gregorian_month_names = [
        "يناير",
        "فبراير",
        "مارس",
        "أبريل",
        "مايو",
        "يونيو",
        "يوليو",
        "أغسطس",
        "سبتمبر",
        "أكتوبر",
        "نوفمبر",
        "ديسمبر",
    ],
    day_names = [
        "الإثنين",
        "الثلاثاء",
        "الأربعاء",
        "الخميس",
        "الجمعة",
        "السبت",
        "الأحد",
    ],
    notation = "هـ",
    gregorian_notation = "م"
)

AzerbaijaniLocale = Locale(
    language_tag = "az",
    month_names = [
        "məhərrəm",
        "səfər",
        "rəbiüləvvəl",
        "rəbiülaxır",
        "cəmadiyələvvəl",
        "cəmadiyəlaxır",
        "rəcəb",
        "şaban",
        "ramazan",
        "şəvval",
        "zilqədə",
        "zilhiccə",
    ],
    gregorian_month_names = [
        "yanvar",
        "fevral",
        "mart",
        "aprel",
        "may",
        "iyun",
        "iyul",
        "avqust",
        "sentyabr",
        "oktyabr",
        "noyabr",
        "dekabr",
    ],
    day_names = [
        "bazar ertəsi",
        "çərşənbə axşamı",
        "çərşənbə",
        "cümə axşamı",
        "cümə",
        "şənbə",
        "bazar",
    ],
    notation = "h.s.", # TODO: Verify this
    gregorian_notation = "b.e." # TODO: Verify this
    )

BengaliLocale = Locale(
    language_tag = "bn",
    month_names = [
        "মুহাররম",
        "সফর",
        "রবিউল আউয়াল",
        "রবিউস সানী",
        "জুমাদাল উলা",
        "জুমাদাস সানী",
        "রজব",
        "শাবান",
        "রমজান",
        "শাওয়াল",
        "জিলক্বদ",
        "জিলহজ",
    ],
    gregorian_month_names = [
        "জানুয়ারি",
        "ফেব্রুয়ারি",
        "মার্চ",
        "এপ্রিল",
        "মে",
        "জুন",
        "ঞ্জুলাই",
        "আগস্ট",
        "সেপ্টেম্বর",
        "অক্টোবর",
        "নভেম্বর",
        "ডিসেম্বর",
    ],
    day_names = [
        "সোমবার",
        "মঙ্গলবার",
        "বুধবার",
        "বৃহস্পতিবার",
        "শুক্রবার",
        "শনিবার",
        "রবিবার",
    ],
    notation = "হিজরি",
    gregorian_notation = "খ্রিস্টাব্দ"
    )

TurkishLocale = Locale(
    language_tag = "tr",
    month_names = [
        "Muharrem",
        "Safer",
        "Rebiülevvel",
        "Rebiülahir",
        "Cemaziyelevvel",
        "Cemaziyelahir",
        "Recep",
        "Şaban",
        "Ramazan",
        "Şevval",
        "Zilkade",
        "Zilhicce",
    ],
    gregorian_month_names = [
        "Ocak",
        "Şubat",
        "Mart",
        "Nisan",
        "Mayıs",
        "Haziran",
        "Temmuz",
        "Ağustos",
        "Eylül",
        "Ekim",
        "Kasım",
        "Aralık",
    ],
    day_names = [
        "Pazartesi",
        "Salı",
        "Çarşamba",
        "Perşembe",
        "Cuma",
        "Cumartesi",
        "Pazar",
    ],
    notation = "H.S.", # TODO: Verify this
    gregorian_notation = "M.S."
    )

_locale_map = Dict{String, Locale}("en" => EnglishLocale, "ar" => ArabicLocale, "az" => AzerbaijaniLocale, "bn" => BengaliLocale, "tr" => TurkishLocale)

@doc  """Return an appropriate :obj:`Locale` corresponding to a locale name.

      :param name: name of the locale.
      :type name: str
      """
function get_locale(name::String)
    language_tag = lowercase(name)[1:2]
    locale_cls = get(_locale_map, language_tag, nothing)

    if locale_cls == nothing
        throw(error(string("Unsupported language: ", language_tag))) #TODO: replace with ValueError
    end
    return locale_cls
end

locale_union = Union{Locale} #TODO: Automate this list
function __init_subclass__(locale::locale_union)
        if cls.language_tag in _locale_map
            throw(error(string("Duplicated language tag: ", cls.language_tag))) #TODO: replace with Lookup Error
        end
        _locale_map[locale.language_tag] = locale
end

@doc    """Return the month name for a specified Hijri month of the year.

        :param month: month of year, in range 1-12.
        :type month: int
        """
function month_name(locale::locale_union, month::Int)

        return locale.month_names[month]
end

@doc     """Return the month name for a specified Gregorian month of the year.

        :param month: month of year, in range 1-12.
        :type month: int
        """
function gregorian_month_name(locale::locale_union, month::Int)
   
        return locale.gregorian_month_names[month]
end

@doc    """Return the day name for a specified day of the week.

        :param day: day of week, where Monday is 1 and Sunday is 7.
        :type day: int
        """
function day_name(locale::locale_union, day::Int)  #TODO: locale should be one of Locale structs
   
        return locale.day_names[day]
end
end
