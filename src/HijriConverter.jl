module HijriConverter
# Main module of the hijri-converter package.
include("ummalqura.jl")
include("helpers.jl")
include("locales.jl")
using .ummalqura
using .helpers
using .locales
using Parameters
using Dates
import Base: isless, isgreater, isequal, !=, <=, >=
import Dates: year, month, day

export Hijri, hijri_today, to_hijri, to_gregorian
export isless, isgreater, iseequal, !=, <=, >=

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
	validate::Bool
end

Hijri(year, month, day) = Hijri(year, month, day, true)

@doc     """Return month name.

        :param language: Language tag for localized month name. Full locale name can
            be used, e.g. ``en-US`` or ``en_US.UTF-8``. Supported languages are
            ``en``, ``ar`` and ``bn``.
        :type language: str
        """
function month_name(date::Hijri, language::String = "en")
        return locales.month_name(locales.get_locale(language), month(date))
end

@doc    """Return month’s index in ummalqura month starts"""
function _month_index(date::Hijri)
        prior_months = ((year(date) - 1) * 12) + month(date) - 1
        index = prior_months - ummalqura.HIJRI_OFFSET
        return index
end

@doc    """Check date values if within valid range."""
function _check_date_(date::Hijri)
        # check year
        min_year, max_year = [d[1] for d in ummalqura.HIJRI_RANGE]
        if min_year > year(date) ||  year(date) > max_year
            throw(DomainError("date out of range"))
        end
        # check month
        if 1 > month(date) || month(date) > 12
            throw(DomainError("month must be in 1..12"))
        end
        # check day
        month_len = month_length(date)
        if 1 > day(date) || day(date) > month_len
            throw(DomainError(string("day must be in 1..", month_len, " for month")))
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
	_check_date_(date)
        jdn = to_julian(date)
        n = helpers.jdn_to_ordinal(jdn)
        return fromordinal(n)
end        

@doc    """Return corresponding Julian day number (JDN)."""
function to_julian(date::Hijri)
        month_starts = ummalqura.MONTH_STARTS
        index = _month_index(date)
	rjd = month_starts[index + 1] + day(date) - 1
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
        len = [month_starts[index] - month_starts[mod1(index - 1, end)] for index in 1:length(month_starts)][1]
        return len
end

#-----------------PART-II--------------------
# ----------------GREGORIAN-------------------

@doc    """Check date values if within valid range."""
function _check_date_(date::Union{Date, DateTime})
        # check year
        min_year, max_year = [d[1] for d in ummalqura.GREGORIAN_RANGE]
        if min_year > year(date) ||  year(date) > max_year
            throw(error("date out of range")) # replace with overflow error
        end
        # check month
        if 1 > month(date) || month(date) > 12
            throw(ValueError("month must be in 1..12"))
        end
        # check day
        month_len = month_length(date) #TODO: fix this
        if 1 > day(date) || day(date) > month_len
            throw(ValueError(string("day must be in 1..", month_len, " for month")))
        end
end

@doc    """Return Hijri object for the corresponding Gregorian date.

        :rtype: Hijri
        """
function to_hijri(date::Union{Date, DateTime})
        _check_range(date)
        jdn = Int(round(datetime2julian(date)))
        rjd = helpers.jdn_to_rjd(jdn)
        month_starts = ummalqura.MONTH_STARTS
        index = helpers.bisect_left(month_starts, rjd) - 1
        months = index + ummalqura.HIJRI_OFFSET - 1
        
        years = floor(months / 12)
        year = years + 1
        month = months - (years * 12) + 1
        day = rjd - month_starts[index] + 2 #TODO: I don't why this is "+2" rather than "+1"
        
        @assert day > 0 && day < 32
        @assert month > 0 && month < 13
        return Hijri(year, month, day, false)
end

@doc    """Return proleptic Gregorian ordinal for the year, month and day.
        January 1 of year 1 is day 1.  Only the year, month and day values
        contribute to the result.
        """
function toordinal(date::Union{Date, DateTime})
        return helpers._ymd2ord(year(date), month(date), day(date))
end

@doc    """Construct a date from a proleptic Gregorian ordinal.
        January 1 of year 1 is day 1.  Only the year, month and day are
        non-zero in the result.
        """
function fromordinal(n)
        y, m, d = helpers._ord2ymd(n)
        return DateTime(y, m, d)
end

@doc    """Check if Gregorian date is within valid range."""
function _check_range(date::Union{Date, DateTime})
        min_date, max_date = ummalqura.GREGORIAN_RANGE
        if min_date > (year(date), month(date), day(date)) || (year(date), month(date), day(date)) > max_date
            throw(error("date out of range")) # replace with OverFlowError
        end
end

@doc    """Return calendar era notation.

        :param language: Language tag for localized notation. Full locale name can
            be used, e.g. ``en-US`` or ``en_US.UTF-8``. Supported languages are
            ``en``, ``ar`` and ``bn``.
        :type language: str
        """
function notation(date::Union{Date,DateTime}, language::String = "en")

        return locales.get_locale(language).gregorian_notation
end

@doc    """Return month name.

        :param language: Language tag for localized month name. Full locale name can
            be used, e.g. ``en-US`` or ``en_US.UTF-8``. Supported languages are
            ``en``, ``ar`` and ``bn``.
        :type language: str
        """
function month_name(date::Union{Date, DateTime}, language::String = "en")

        return gregorian_month_name(locales.get_locale(language), month(date))
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
        return Hijri(year, month, day)
end

@doc    """Construct Hijri object from today's date.

        :rtype: Hijri
        """
function hijri_today() # Gregorian struct is incomplete
        return to_hijri(DateTime(today()))
end

@doc     """Return year as an integer."""
function year(date::Hijri)
        return date.year
end

@doc     """Return month as an integer."""
function month(date::Hijri)
        return date.month
end

@doc     """Return day as an integer."""
function day(date::Hijri)
        return date.day
end

@doc     """Return date in ISO format i.e. ``YYYY-MM-DD``."""
function isoformat(date::T)  where {T<:Union{Hijri, Date, DateTime}}
	year = lpad(year(date), 4, "0")
	month = lpad(month(date), 2, "0")
	day = lpad(day(date), 2, "0")
	
	return string(year, "-", month, "-", day)
end

@doc    """Return date in day-month-year format (``DD/MM/YYYY`` by default).

        :param separator: String that separates the day, month, and year values.
        :type separator: str
        :param padding: Whether to add a leading zero as a padding character to fill
            day and month values when less than 10.
        :type padding: bool
        """
function dmyformat(date::T; separator::String = "/", padding::Bool = true) where {T <: Union{Hijri, Date, DateTime}}

        day = padding ? lpad(day(date), 2, "0") : day(date)
        month = padding ? lpad(month(date), 2, "0") : month(date)
        return string(day, separator, month, separator, year(date))
end

@doc    """Return day name.

        :param language: Language tag for localized day name. Full locale name can
            be used, e.g. ``en-US`` or ``en_US.UTF-8``. Supported languages are
            ``en``, ``ar`` and ``bn``.
        :type language: str
        """
function day_name(date::T, language::String = "en") where {T <: Union{Hijri, Date, DateTime}} #TODO: implement isoweekday for gregorian

        return locales.day_name(locales.get_locale(language), isoweekday(date))
end

function datetuple(date::T) where {T <: Union{Hijri, Date, DateTime}}
	return (year(date), month(date), day(date))
end

# NUMERIC COMPARISONS
function isless(a::Hijri, b::Hijri)
	tuple_a = datetuple(a)
	tuple_b = datetuple(b)
	
	return tuple_a < tuple_b
end

function isgreater(a::Hijri, b::Hijri)
	tuple_a = datetuple(a)
	tuple_b = datetuple(b)
	
	return tuple_a > tuple_b
end

function isequal(a::Hijri, b::Hijri)
	tuple_a = datetuple(a)
	tuple_b = datetuple(b)
	
	return tuple_a == tuple_b
end

function !=(a::Hijri, b::Hijri)
	tuple_a = datetuple(a)
	tuple_b = datetuple(b)
	
	return tuple_a != tuple_b
end

function <=(a::Hijri, b::Hijri)
	tuple_a = datetuple(a)
	tuple_b = datetuple(b)
	
	return tuple_a <= tuple_b
end

function >=(a::Hijri, b::Hijri)
	tuple_a = datetuple(a)
	tuple_b = datetuple(b)
	
	return tuple_a >= tuple_b
end
end
