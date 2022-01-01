module core
# Main module of the hijri-converter package.
include("ummalqura.jl")
include("helpers.jl")
include("locales.jl")
using .ummalqura
using .helpers
using .locales
using Parameters
using Dates

#-----------------PART-I--------------------
# ----------------HIJRI-------------------

@doc  """
      A Hijri object represents a date (year, month and day) in Hijri
      calendar.
      """
@with_kw struct Hijri
	year::Int64
	month::Int64
	day::Int64
	validate::Bool=true
end

Hijri(year, month, day) = Hijri(year, month, day, true)

@doc     """Return month name.

        :param language: Language tag for localized month name. Full locale name can
            be used, e.g. ``en-US`` or ``en_US.UTF-8``. Supported languages are
            ``en``, ``ar`` and ``bn``.
        :type language: str
        """
function month_name(date::Hijri, language::String = "en")
        return locales.month_name(locales.get_locale(language), date.month)
end

@doc    """Return month’s index in ummalqura month starts""" #add arrow???
function _month_index(date::Hijri)
        prior_months = ((date.year - 1) * 12) + date.month - 1
        index = prior_months - ummalqura.HIJRI_OFFSET
        return index
end

@doc    """Check date values if within valid range."""
function _check_date_(date::Hijri)
        # check year
        min_year, max_year = [d[1] for d in ummalqura.HIJRI_RANGE]
        if min_year > date.year ||  date.year > max_year
            throw(error("date out of range")) # replace with overflow error
        end
        # check month
        if 1 > date.month || date.month > 12
            throw(ValueError("month must be in 1..12"))
        end
        # check day
        month_len = month_length(date)
        if 1 > date.day || date.day > month_len
            throw(ValueError(string("day must be in 1..", month_len, " for month")))
        end
end

@doc    """Return calendar era notation.

        :param language: Language tag for localized notation. Full locale name can
            be used, e.g. ``en-US`` or ``en_US.UTF-8``. Supported languages are
            ``en``, ``ar`` and ``bn``.
        :type language: str
        """
function notation(date::Hijri, language::String = "en")

        return locales.get_locale(language).notation
end

@doc    """Return Gregorian object for the corresponding Hijri date.

        :rtype: Gregorian
        """
function to_gregorian(date::Hijri)
        jdn = to_julian(date)
        n = helpers.jdn_to_ordinal(jdn)
        return fromordinal(n)
end        

@doc    """Return corresponding Julian day number (JDN)."""
function to_julian(date::Hijri)
        month_starts = ummalqura.MONTH_STARTS
        index = _month_index(date)
        rjd = month_starts[index] + date.day
        jdn = helpers.rjd_to_jdn(rjd)
        return jdn
end

@doc    """Return day of week, where Monday is 0 and Sunday is 6."""
function weekday(date::Hijri)
        jdn = to_julian(date)
        return Int(jdn % 7)
end

@doc    """Return day of week, where Monday is 1 and Sunday is 7."""
function isoweekday(date::Hijri)
        jdn = to_julian(date)
        return Int(jdn % 7) + 1
end

@doc     """Return number of days in month."""
function month_length(date::Hijri)
        month_starts = ummalqura.MONTH_STARTS
        index = _month_index(date)
        length = month_starts[index + 1] - month_starts[index]
        return length
end

#-----------------PART-II--------------------
# ----------------GREGORIAN-------------------

@doc  """
      A Gregorian object represents a date (year, month and day) in Gregorian
      calendar.
      """
@with_kw struct Gregorian
	 year::Int64
	 month::Int64
	 day::Int64
	 validate::Bool
end

Gregorian(year, month, day) = Gregorian(year, month, day, true)

@doc    """Return Hijri object for the corresponding Gregorian date.

        :rtype: Hijri
        """
function to_hijri(date::Gregorian)
        _check_range(date)
        jdn = to_julian(date)
        rjd = helpers.jdn_to_rjd(jdn)
        month_starts = ummalqura.MONTH_STARTS
        index = helpers.bisect_left(month_starts, rjd) - 1
        months = index + ummalqura.HIJRI_OFFSET
        years = round(months / 12)
        year = years + 1
        month = months - (years * 12) + 1
        day = rjd - month_starts[index] + 1
        return Hijri(year, month, day, false)
end

@doc    """Return proleptic Gregorian ordinal for the year, month and day.
        January 1 of year 1 is day 1.  Only the year, month and day values
        contribute to the result.
        """
function toordinal(date::Gregorian)
        return helpers._ymd2ord(date.year, date.month, date.day)
end

@doc    """Construct a date from a proleptic Gregorian ordinal.
        January 1 of year 1 is day 1.  Only the year, month and day are
        non-zero in the result.
        """
function fromordinal(n)
        y, m, d = helpers._ord2ymd(n)
        return Gregorian(y, m, d)
end

@doc    """Check if Gregorian date is within valid range."""
function _check_range(date::Gregorian)
        min_date, max_date = ummalqura.GREGORIAN_RANGE
        if min_date > (date.year, date.month, date.day) || (date.year, date.month, date.day) > max_date
            throw(error("date out of range")) # replace with OverFlowError
        end
end

@doc    """Return calendar era notation.

        :param language: Language tag for localized notation. Full locale name can
            be used, e.g. ``en-US`` or ``en_US.UTF-8``. Supported languages are
            ``en``, ``ar`` and ``bn``.
        :type language: str
        """
function notation(date::Gregorian, language::String = "en")

        return locales.get_locale(language).gregorian_notation
end

@doc     """Return corresponding Julian day number (JDN)."""
function to_julian(date::Gregorian)
        n = toordinal(date)
        jdn = helpers.ordinal_to_jdn(n)
        return jdn
end

@doc    """Return month name.

        :param language: Language tag for localized month name. Full locale name can
            be used, e.g. ``en-US`` or ``en_US.UTF-8``. Supported languages are
            ``en``, ``ar`` and ``bn``.
        :type language: str
        """
function month_name(date::Gregorian, language::String = "en")

        return gregorian_month_name(locales.get_locale(language), date.month)
end

#-----------------PART-III--------------------
# ----------------COMMON METHODS-------------------

@doc    """Construct Hijri object from an ISO formatted Hijri date
        ``YYYY-MM-DD``.

        :param date_string: Hijri date in ISO format ``YYYY-MM-DD``.
        :type date_string: str
        :rtype: Hijri
        """
function fromisoformat(date_string::String)
        year = parse(Int, date_string[1:4])
        month = parse(Int, date_string[6:7])
        day = parse(Int, date_string[9:10])
        return Hijri(year, month, day, true) #TODO: true should be implicit
end

@doc    """Construct Hijri object from today's date.

        :rtype: Hijri
        """
function hijri_today() # Gregorian struct is incomplete
        return to_hijri(gregorian_today())
end

function gregorian_today()
	today = Dates.today()
	year = Dates.Year(today).value
	month = Dates.Month(today).value
	day = Dates.Day(today).value
	return Gregorian(year, month, day)
end

@doc     """Return year as an integer."""
function year(date::T) where {T<:Union{Hijri, Gregorian}}
        return date.year
end

@doc     """Return month as an integer."""
function month(date::T) where {T<:Union{Hijri, Gregorian}}
        return date.month
end

@doc     """Return day as an integer."""
function day(date::T) where {T<:Union{Hijri, Gregorian}}
        return date.day
end

@doc     """Return date as a tuple of (year, month, day)."""
function datetuple(date::T) where {T<:Union{Hijri, Gregorian}}
        return date.year, date.month, date.day
end

@doc     """Return date in ISO format i.e. ``YYYY-MM-DD``."""
function isoformat(date::T)  where {T<:Union{Hijri, Gregorian}}
        return string(date.year, "-", date.month, "-", date.day)
end


@doc    """Construct Gregorian object from a Python date object.

        :param date_object: Python date object.
        :type date_object: datetime.date
        :rtype: Gregorian
        """
function gregorian_from_date(date_object::Dates.Date)

        year, month, day = Dates.year(date_object), Dates.month(date_object), Dates.day(date_object)
        return Gregorian(year, month, day)
end

@doc    """Return date in day-month-year format (``DD/MM/YYYY`` by default).

        :param separator: String that separates the day, month, and year values.
        :type separator: str
        :param padding: Whether to add a leading zero as a padding character to fill
            day and month values when less than 10.
        :type padding: bool
        """
function dmyformat(date::T, separator::String = "/", padding::Bool = true) where {T <: Union{Gregorian, Hijri}}

        day = padding ? lpad(date.day, 2, "0") : date.day
        month = padding ? lpad(date.month, 2, "0") : date.month
        return string(day, separator, month, separator, date.year)
end

@doc    """Return day name.

        :param language: Language tag for localized day name. Full locale name can
            be used, e.g. ``en-US`` or ``en_US.UTF-8``. Supported languages are
            ``en``, ``ar`` and ``bn``.
        :type language: str
        """
function day_name(date::T, language::String = "en") where {T <: Union{Gregorian, Hijri}} #TODO: implement isoweekday for gregorian

        return day_name(locales.get_locale(language), isoweekday(date))
end

function datetuple(date::T) where {T <: Union{Hijri, Gregorian}}
	return (date.year, date.month, date.day)
end
end
